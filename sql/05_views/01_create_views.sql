BEGIN;

/* Authoritative, population-specific financial interfaces. */
CREATE OR REPLACE VIEW aviation.vw_airline_loss_summary AS
SELECT
    airline,
    country,
    airline_type,
    region,
    estimated_loss_usd,
    cancellations_count,
    reroutes_count,
    revenue_loss_pct
FROM aviation.airline_losses;

COMMENT ON VIEW aviation.vw_airline_loss_summary IS
    'Authoritative undated modeled-summary interface; one row per summary airline.';

CREATE OR REPLACE VIEW aviation.vw_airline_loss_estimate AS
SELECT
    airline,
    country,
    estimated_daily_loss_usd,
    cancelled_flights,
    rerouted_flights,
    additional_fuel_cost_usd,
    passengers_impacted
FROM aviation.airline_losses_estimate;

COMMENT ON VIEW aviation.vw_airline_loss_estimate IS
    'Authoritative undated modeled daily-estimate interface; one row per estimate airline.';

/* Deprecated compatibility interface. Do not use for new analysis. */
CREATE OR REPLACE VIEW aviation.vw_airline_operational_financial AS
SELECT
    COALESCE(s.airline, e.airline) AS airline,
    COALESCE(s.country, e.country) AS country,
    s.airline_type,
    s.region,
    s.estimated_loss_usd,
    s.cancellations_count,
    s.reroutes_count,
    s.revenue_loss_pct,
    e.estimated_daily_loss_usd,
    e.cancelled_flights,
    e.rerouted_flights,
    e.additional_fuel_cost_usd,
    e.passengers_impacted,
    ROUND(CAST(e.cancelled_flights AS NUMERIC) / NULLIF(e.rerouted_flights, 0), 2)
        AS cancellations_per_rerouted_flight,
    ROUND(CAST(e.passengers_impacted AS NUMERIC) / NULLIF(e.rerouted_flights, 0), 2)
        AS passengers_per_rerouted_flight,
    ROUND(CAST(e.additional_fuel_cost_usd AS NUMERIC) / NULLIF(e.rerouted_flights, 0), 2)
        AS fuel_cost_per_rerouted_flight,
    (s.airline IS NOT NULL) AS has_summary_data,
    (e.airline IS NOT NULL) AS has_estimate_data
FROM aviation.airline_losses s
FULL OUTER JOIN aviation.airline_losses_estimate e
    ON s.airline = e.airline;

COMMENT ON VIEW aviation.vw_airline_operational_financial IS
    'DEPRECATED Phase 1 compatibility view. Preserves both populations with presence flags; migrate Power BI to population-specific views in Phase 2.';

CREATE OR REPLACE VIEW aviation.vw_airport_disruption AS
SELECT
    airport_name,
    iata_code,
    country,
    region,
    disruption_type,
    severity_level,
    flights_affected,
    duration_hours,
    date
FROM aviation.airport_disruptions;

COMMENT ON VIEW aviation.vw_airport_disruption IS
    'Supporting detail interface; one simulated airport disruption record per row.';

CREATE OR REPLACE VIEW aviation.vw_airspace_closure AS
SELECT
    country,
    region,
    closure_start_date,
    closure_end_date,
    duration_hours,
    airspace_zone,
    reason,
    flights_affected
FROM aviation.airspace_closures;

COMMENT ON VIEW aviation.vw_airspace_closure IS
    'Supporting detail interface; one simulated airspace closure record per row.';

/* Descriptive temporal alignment only; it does not establish causation. */
CREATE OR REPLACE VIEW aviation.vw_geopolitical_daily_impact AS
WITH bounds AS (
    SELECT MIN(day) AS start_date, MAX(day) AS end_date
    FROM (
        SELECT date AS day FROM aviation.conflict_events
        UNION ALL SELECT date FROM aviation.airport_disruptions
        UNION ALL SELECT CAST(closure_start_date AS DATE) FROM aviation.airspace_closures
        UNION ALL SELECT CAST(closure_end_date AS DATE) FROM aviation.airspace_closures
        UNION ALL SELECT date FROM aviation.flight_cancellations
        UNION ALL SELECT date FROM aviation.flight_reroutes
    ) AS all_dates
),
date_spine AS (
    -- generate_series is PostgreSQL's standard way to build a complete day list.
    SELECT CAST(generate_series(start_date, end_date, INTERVAL '1 day') AS DATE) AS date
    FROM bounds
),
military_events_daily AS (
    SELECT
        date,
        COUNT(*) AS military_events,
        MAX(CASE severity
            WHEN 'Low' THEN 1 WHEN 'Medium' THEN 2 WHEN 'High' THEN 3
            WHEN 'Very High' THEN 4 WHEN 'Critical' THEN 5
        END) AS severity_level
    FROM aviation.conflict_events
    WHERE event_type = 'Military'
    GROUP BY date
),
airport_daily AS (
    SELECT date, COUNT(*) AS airport_disruptions
    FROM aviation.airport_disruptions
    GROUP BY date
),
airspace_daily AS (
    SELECT d.date, COUNT(a.country) AS airspace_closures
    FROM date_spine d
    LEFT JOIN aviation.airspace_closures a
        ON d.date BETWEEN CAST(a.closure_start_date AS DATE)
                      AND CAST(a.closure_end_date AS DATE)
    GROUP BY d.date
),
cancellation_daily AS (
    SELECT date, COUNT(*) AS cancellations
    FROM aviation.flight_cancellations
    GROUP BY date
),
reroute_daily AS (
    SELECT date, COUNT(*) AS reroutes
    FROM aviation.flight_reroutes
    GROUP BY date
)
SELECT
    d.date,
    COALESCE(m.military_events, 0) AS military_events,
    CASE m.severity_level
        WHEN 1 THEN 'Low' WHEN 2 THEN 'Medium' WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High' WHEN 5 THEN 'Critical'
    END AS conflict_severity,
    COALESCE(a.airport_disruptions, 0) AS airport_disruptions,
    COALESCE(s.airspace_closures, 0) AS airspace_closures,
    COALESCE(c.cancellations, 0) AS cancellations,
    COALESCE(r.reroutes, 0) AS reroutes,
    (COALESCE(m.military_events, 0) > 0) AS is_military_event_date
FROM date_spine d
LEFT JOIN military_events_daily m ON d.date = m.date
LEFT JOIN airport_daily a ON d.date = a.date
LEFT JOIN airspace_daily s ON d.date = s.date
LEFT JOIN cancellation_daily c ON d.date = c.date
LEFT JOIN reroute_daily r ON d.date = r.date;

COMMENT ON VIEW aviation.vw_geopolitical_daily_impact IS
    'Complete descriptive daily baseline across dated sources. Event-date alignment is contextual and not causal.';

CREATE OR REPLACE VIEW aviation.vw_regional_vulnerability AS
WITH airport AS (
    SELECT
        region,
        COUNT(*) AS airport_disruption_events,
        COUNT(DISTINCT airport_name) AS airports_affected,
        SUM(flights_affected) AS airport_flights_affected,
        SUM(duration_hours) AS airport_disruption_hours
    FROM aviation.airport_disruptions
    GROUP BY region
),
financial AS (
    SELECT region, SUM(estimated_loss_usd) AS modeled_airline_loss_usd
    FROM aviation.airline_losses
    GROUP BY region
),
airspace AS (
    SELECT
        region,
        COUNT(*) AS airspace_closures,
        SUM(duration_hours) AS airspace_closure_hours,
        SUM(flights_affected) AS airspace_flights_affected
    FROM aviation.airspace_closures
    GROUP BY region
)
SELECT
    COALESCE(p.region, f.region, s.region) AS region,
    COALESCE(p.airport_disruption_events, 0) AS airport_disruption_events,
    COALESCE(p.airports_affected, 0) AS airports_affected,
    COALESCE(p.airport_flights_affected, 0) AS airport_flights_affected,
    COALESCE(p.airport_disruption_hours, 0) AS airport_disruption_hours,
    COALESCE(f.modeled_airline_loss_usd, 0) AS estimated_loss_usd,
    COALESCE(s.airspace_closures, 0) AS airspace_closures,
    COALESCE(s.airspace_closure_hours, 0) AS airspace_closure_hours,
    COALESCE(s.airspace_flights_affected, 0) AS airspace_flights_affected
FROM airport p
FULL OUTER JOIN financial f ON p.region = f.region
FULL OUTER JOIN airspace s ON COALESCE(p.region, f.region) = s.region;

COMMENT ON VIEW aviation.vw_regional_vulnerability IS
    'Supporting regional comparison. Airport, airspace and modeled-financial populations remain separate and are not deduplicated.';

CREATE OR REPLACE VIEW aviation.vw_route_passenger_impact AS
WITH cancellations AS (
    SELECT
        date,
        origin_region,
        destination_region,
        origin_country,
        destination_country,
        COUNT(*) AS cancelled_flights,
        SUM(passengers_affected) AS passengers_affected
    FROM aviation.flight_cancellations
    GROUP BY date, origin_region, destination_region, origin_country, destination_country
),
reroutes AS (
    SELECT
        date,
        origin_region,
        destination_region,
        origin_country,
        destination_country,
        COUNT(*) AS rerouted_flights,
        SUM(additional_distance_km) AS additional_distance_km,
        SUM(extra_fuel_cost_usd) AS additional_fuel_cost_usd,
        SUM(delay_hours) AS delay_hours
    FROM aviation.flight_reroutes
    GROUP BY date, origin_region, destination_region, origin_country, destination_country
)
SELECT
    COALESCE(c.date, r.date) AS date,
    COALESCE(c.origin_region, r.origin_region) AS origin_region,
    COALESCE(c.destination_region, r.destination_region) AS destination_region,
    COALESCE(c.origin_country, r.origin_country) AS origin_country,
    COALESCE(c.destination_country, r.destination_country) AS destination_country,
    COALESCE(c.cancelled_flights, 0) AS cancelled_flights,
    COALESCE(c.passengers_affected, 0) AS passengers_affected,
    COALESCE(r.rerouted_flights, 0) AS rerouted_flights,
    COALESCE(r.additional_distance_km, 0) AS additional_distance_km,
    COALESCE(r.additional_fuel_cost_usd, 0) AS additional_fuel_cost_usd,
    COALESCE(r.delay_hours, 0) AS delay_hours
FROM cancellations c
FULL OUTER JOIN reroutes r
    ON c.date = r.date
   AND c.origin_region = r.origin_region
   AND c.destination_region = r.destination_region
   AND c.origin_country = r.origin_country
   AND c.destination_country = r.destination_country;

COMMENT ON VIEW aviation.vw_route_passenger_impact IS
    'Daily route-grain supporting view. Cancellation and reroute measures remain distinct and reconcile independently.';

/* Deprecated compatibility object retained until Phase 2 Power BI migration. */
CREATE OR REPLACE VIEW aviation.vw_executive_kpi AS
SELECT
    (SELECT COUNT(*) FROM aviation.flight_cancellations) AS total_flight_cancellations,
    (SELECT COALESCE(SUM(passengers_affected), 0) FROM aviation.flight_cancellations)
        AS passengers_affected,
    (SELECT COUNT(*) FROM aviation.flight_reroutes) AS total_rerouted_flights,
    (SELECT COALESCE(SUM(additional_distance_km), 0) FROM aviation.flight_reroutes)
        AS additional_reroute_distance_km,
    (SELECT COALESCE(SUM(extra_fuel_cost_usd), 0) FROM aviation.flight_reroutes)
        AS additional_fuel_cost_usd,
    (SELECT COALESCE(SUM(flights_affected), 0) FROM aviation.airport_disruptions)
        AS airport_flights_affected,
    (SELECT COUNT(*) FROM aviation.airspace_closures) AS airspace_closure_events,
    (SELECT COALESCE(SUM(duration_hours), 0) FROM aviation.airspace_closures)
        AS airspace_closure_hours,
    (SELECT COALESCE(SUM(flights_affected), 0) FROM aviation.airspace_closures)
        AS airspace_flights_affected,
    (SELECT COALESCE(SUM(estimated_loss_usd), 0) FROM aviation.airline_losses)
        AS total_estimated_airline_loss_usd,
    (SELECT COALESCE(SUM(delay_hours), 0) FROM aviation.flight_reroutes)
        AS total_reroute_delay_hours,
    (SELECT COUNT(*) FROM aviation.conflict_events) AS total_conflict_events,
    (SELECT COUNT(*) FROM aviation.conflict_events WHERE event_type = 'Military')
        AS total_military_events;

COMMENT ON VIEW aviation.vw_executive_kpi IS
    'DEPRECATED Phase 1 compatibility view. Migrate visuals to explicit, population-labelled measures in Phase 2.';

COMMIT;
