
/* ============================================================
   VIEW 01 — AIRLINE OPERATIONAL & FINANCIAL
   ============================================================ */

-- Combines airline-level operational and financial measures for Power BI.

CREATE OR REPLACE VIEW aviation.vw_airline_operational_financial AS

SELECT
    a.airline,
    a.country,
    a.airline_type,
    a.region,
    a.estimated_loss_usd,
    a.cancellations_count,
    a.reroutes_count,
    a.revenue_loss_pct,
    e.estimated_daily_loss_usd,
    e.cancelled_flights,
    e.rerouted_flights,
    e.additional_fuel_cost_usd,
    e.passengers_impacted,

    ROUND(
        e.cancelled_flights::NUMERIC
        / NULLIF(e.rerouted_flights, 0),
        2
    ) AS cancellations_per_rerouted_flight,

    ROUND(
        e.passengers_impacted::NUMERIC
        / NULLIF(e.rerouted_flights, 0),
        2
    ) AS passengers_per_rerouted_flight,

    ROUND(
        e.additional_fuel_cost_usd::NUMERIC
        / NULLIF(e.rerouted_flights, 0),
        2
    ) AS fuel_cost_per_rerouted_flight

FROM aviation.airline_losses a

LEFT JOIN aviation.airline_losses_estimate e
    ON a.airline = e.airline;


/* ============================================================
   VIEW 02 — AIRPORT DISRUPTION
   ============================================================ */

-- Provides airport disruption records for Power BI analysis.

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


/* ============================================================
   VIEW 03 — AIRSPACE CLOSURE
   ============================================================ */

-- Provides airspace closure records for Power BI analysis.

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


/* ============================================================`
   VIEW 04 — GEOPOLITICAL DAILY IMPACT
   ============================================================ */

-- Creates a daily view linking military events with aviation disruption.

CREATE OR REPLACE VIEW aviation.vw_geopolitical_daily_impact AS

WITH military_events_daily AS (

    SELECT
        date,
        COUNT(*) AS military_events,

        MAX(
            CASE severity
                WHEN 'Low' THEN 1
                WHEN 'Medium' THEN 2
                WHEN 'High' THEN 3
                WHEN 'Very High' THEN 4
                WHEN 'Critical' THEN 5
            END
        ) AS severity_level

    FROM aviation.conflict_events

    WHERE event_type = 'Military'

    GROUP BY date
),

airport_daily AS (

    SELECT
        date,
        COUNT(*) AS airport_disruptions

    FROM aviation.airport_disruptions

    GROUP BY date
),

airspace_daily AS (

    SELECT
        d.date,
        COUNT(a.country) AS airspace_closures

    FROM (
        SELECT DISTINCT date
        FROM aviation.conflict_events
        WHERE event_type = 'Military'
    ) d

    LEFT JOIN aviation.airspace_closures a
        ON d.date BETWEEN
           a.closure_start_date::DATE
           AND a.closure_end_date::DATE

    GROUP BY d.date
),

cancellation_daily AS (

    SELECT
        date,
        COUNT(*) AS cancellations

    FROM aviation.flight_cancellations

    GROUP BY date
),

reroute_daily AS (

    SELECT
        date,
        COUNT(*) AS reroutes

    FROM aviation.flight_reroutes

    GROUP BY date
)

SELECT
    m.date,
    m.military_events,

    CASE m.severity_level
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
        WHEN 5 THEN 'Critical'
    END AS conflict_severity,

    COALESCE(a.airport_disruptions, 0)
        AS airport_disruptions,

    COALESCE(s.airspace_closures, 0)
        AS airspace_closures,

    COALESCE(c.cancellations, 0)
        AS cancellations,

    COALESCE(r.reroutes, 0)
        AS reroutes

FROM military_events_daily m

LEFT JOIN airport_daily a
    ON m.date = a.date

LEFT JOIN airspace_daily s
    ON m.date = s.date

LEFT JOIN cancellation_daily c
    ON m.date = c.date

LEFT JOIN reroute_daily r
    ON m.date = r.date;


/* ============================================================
   VIEW 05 — REGIONAL VULNERABILITY
   ============================================================ */

-- Combines regional operational, financial and airspace measures.

CREATE OR REPLACE VIEW aviation.vw_regional_vulnerability AS

WITH operational AS (

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

    SELECT
        region,
        SUM(estimated_loss_usd) AS estimated_loss_usd

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
    COALESCE(o.region, f.region, a.region) AS region,

    COALESCE(o.airport_disruption_events, 0)
        AS airport_disruption_events,

    COALESCE(o.airports_affected, 0)
        AS airports_affected,

    COALESCE(o.airport_flights_affected, 0)
        AS airport_flights_affected,

    COALESCE(o.airport_disruption_hours, 0)
        AS airport_disruption_hours,

    COALESCE(f.estimated_loss_usd, 0)
        AS estimated_loss_usd,

    COALESCE(a.airspace_closures, 0)
        AS airspace_closures,

    COALESCE(a.airspace_closure_hours, 0)
        AS airspace_closure_hours,

    COALESCE(a.airspace_flights_affected, 0)
        AS airspace_flights_affected

FROM operational o

FULL OUTER JOIN financial f
    ON o.region = f.region

FULL OUTER JOIN airspace a
    ON COALESCE(o.region, f.region) = a.region;


/* ============================================================
   VIEW 06 — ROUTE & PASSENGER IMPACT
   ============================================================ */

-- Aggregates cancellation and rerouting activity at route level.

CREATE OR REPLACE VIEW aviation.vw_route_passenger_impact AS

WITH cancellations AS (

    SELECT
        origin_region,
        destination_region,
        origin_country,
        destination_country,
        COUNT(*) AS cancelled_flights,
        SUM(passengers_affected) AS passengers_affected

    FROM aviation.flight_cancellations

    GROUP BY
        origin_region,
        destination_region,
        origin_country,
        destination_country
),

reroutes AS (

    SELECT
        origin_region,
        destination_region,
        origin_country,
        destination_country,
        COUNT(*) AS rerouted_flights,
        SUM(additional_distance_km) AS additional_distance_km,
        SUM(extra_fuel_cost_usd) AS additional_fuel_cost_usd,
        SUM(delay_hours) AS delay_hours

    FROM aviation.flight_reroutes

    GROUP BY
        origin_region,
        destination_region,
        origin_country,
        destination_country
)

SELECT
    COALESCE(c.origin_region, r.origin_region)
        AS origin_region,

    COALESCE(c.destination_region, r.destination_region)
        AS destination_region,

    COALESCE(c.origin_country, r.origin_country)
        AS origin_country,

    COALESCE(c.destination_country, r.destination_country)
        AS destination_country,

    COALESCE(c.cancelled_flights, 0)
        AS cancelled_flights,

    COALESCE(c.passengers_affected, 0)
        AS passengers_affected,

    COALESCE(r.rerouted_flights, 0)
        AS rerouted_flights,

    COALESCE(r.additional_distance_km, 0)
        AS additional_distance_km,

    COALESCE(r.additional_fuel_cost_usd, 0)
        AS additional_fuel_cost_usd,

    COALESCE(r.delay_hours, 0)
        AS delay_hours

FROM cancellations c

FULL OUTER JOIN reroutes r

    ON c.origin_region = r.origin_region
    AND c.destination_region = r.destination_region
    AND c.origin_country = r.origin_country
    AND c.destination_country = r.destination_country;


/* ============================================================
   VIEW 07 — EXECUTIVE KPI
   ============================================================ */

-- Creates the single-row executive KPI dataset for Power BI.

CREATE OR REPLACE VIEW aviation.vw_executive_kpi AS

SELECT

    (SELECT COUNT(*)
     FROM aviation.flight_cancellations)
        AS total_flight_cancellations,

    (SELECT COALESCE(SUM(passengers_affected), 0)
     FROM aviation.flight_cancellations)
        AS passengers_affected,

    (SELECT COUNT(*)
     FROM aviation.flight_reroutes)
        AS total_rerouted_flights,

    (SELECT COALESCE(SUM(additional_distance_km), 0)
     FROM aviation.flight_reroutes)
        AS additional_reroute_distance_km,

    (SELECT COALESCE(SUM(extra_fuel_cost_usd), 0)
     FROM aviation.flight_reroutes)
        AS additional_fuel_cost_usd,

    (SELECT COALESCE(SUM(flights_affected), 0)
     FROM aviation.airport_disruptions)
        AS airport_flights_affected,

    (SELECT COUNT(*)
     FROM aviation.airspace_closures)
        AS airspace_closure_events,

    (SELECT COALESCE(SUM(duration_hours), 0)
     FROM aviation.airspace_closures)
        AS airspace_closure_hours,

    (SELECT COALESCE(SUM(flights_affected), 0)
     FROM aviation.airspace_closures)
        AS airspace_flights_affected,

    (SELECT COALESCE(SUM(estimated_loss_usd), 0)
     FROM aviation.airline_losses)
        AS total_estimated_airline_loss_usd,

    (SELECT COALESCE(SUM(delay_hours), 0)
     FROM aviation.flight_reroutes)
        AS total_reroute_delay_hours,

    (SELECT COUNT(*)
     FROM aviation.conflict_events)
        AS total_conflict_events,

    (SELECT COUNT(*)
     FROM aviation.conflict_events
     WHERE event_type = 'Military')
        AS total_military_events;