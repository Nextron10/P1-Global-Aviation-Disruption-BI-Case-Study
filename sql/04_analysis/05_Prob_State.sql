
/* ============================================================
   PART 1 — REGION-WISE VULNERABILITY
   Compare operational disruption, financial impact, and airspace restrictions by region.
   ============================================================ */

WITH operational AS (
    SELECT
        region,
        COUNT(*) AS airport_disruption_events,
        COUNT(DISTINCT airport_name) AS airports_affected,
        SUM(flights_affected) AS flights_affected,
        SUM(duration_hours) AS disruption_hours
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
        SUM(duration_hours) AS closure_hours,
        SUM(flights_affected) AS flights_affected
    FROM aviation.airspace_closures
    GROUP BY region
)

SELECT
    COALESCE(o.region, f.region, a.region) AS region,

    COALESCE(o.airport_disruption_events, 0)
        AS airport_disruption_events,

    COALESCE(o.airports_affected, 0)
        AS airports_affected,

    COALESCE(o.flights_affected, 0)
        AS airport_flights_affected,

    COALESCE(o.disruption_hours, 0)
        AS disruption_hours,

    COALESCE(f.estimated_loss_usd, 0)
        AS estimated_loss_usd,

    COALESCE(a.airspace_closures, 0)
        AS airspace_closures,

    COALESCE(a.closure_hours, 0)
        AS airspace_closure_hours,

    COALESCE(a.flights_affected, 0)
        AS airspace_flights_affected

FROM operational o
FULL OUTER JOIN financial f
    ON o.region = f.region
FULL OUTER JOIN airspace a
    ON COALESCE(o.region, f.region) = a.region

ORDER BY
    estimated_loss_usd DESC;


/* ============================================================
   PART 2 — COUNTRY-WISE VULNERABILITY
   Identify countries with significant airport and airspace exposure.
   ============================================================ */

WITH airport AS (
    SELECT
        country,
        region,
        COUNT(DISTINCT airport_name) AS airports_affected,
        SUM(flights_affected) AS airport_flights_affected,
        SUM(duration_hours) AS disruption_hours
    FROM aviation.airport_disruptions
    GROUP BY country, region
),

airspace AS (
    SELECT
        country,
        region,
        COUNT(*) AS airspace_closures,
        SUM(duration_hours) AS closure_hours,
        SUM(flights_affected) AS airspace_flights_affected
    FROM aviation.airspace_closures
    GROUP BY country, region
)

SELECT
    COALESCE(a.country, s.country) AS country,
    COALESCE(a.region, s.region) AS region,

    COALESCE(a.airports_affected, 0) AS airports_affected,
    COALESCE(a.airport_flights_affected, 0)
        AS airport_flights_affected,
    COALESCE(a.disruption_hours, 0)
        AS disruption_hours,

    COALESCE(s.airspace_closures, 0)
        AS airspace_closures,
    COALESCE(s.closure_hours, 0)
        AS airspace_closure_hours,
    COALESCE(s.airspace_flights_affected, 0)
        AS airspace_flights_affected

FROM airport a
FULL OUTER JOIN airspace s
    ON a.country = s.country

ORDER BY
    airport_flights_affected DESC,
    airspace_closure_hours DESC;


/* ============================================================
   PART 3 — AIRPORT-WISE VULNERABILITY
   Identify airports experiencing the greatest disruption.
   ============================================================ */

SELECT
    airport_name,
    iata_code,
    country,
    region,
    COUNT(*) AS disruption_events,
    SUM(flights_affected) AS flights_affected,
    SUM(duration_hours) AS disruption_hours,
    MAX(duration_hours) AS longest_disruption_hours,
    COUNT(*) FILTER (
        WHERE severity_level IN ('High', 'Severe', 'Critical')
    ) AS high_severity_events

FROM aviation.airport_disruptions

GROUP BY
    airport_name,
    iata_code,
    country,
    region

ORDER BY
    flights_affected DESC,
    disruption_hours DESC;


/* ============================================================
   PART 4 — AVIATION CORRIDOR VULNERABILITY
   Identify routes most affected by rerouting.
   ============================================================ */

SELECT
    origin_region,
    destination_region,
    origin_country,
    destination_country,

    COUNT(*) AS rerouted_flights,

    SUM(additional_distance_km)
        AS additional_distance_km,

    SUM(extra_fuel_cost_usd)
        AS extra_fuel_cost_usd,

    SUM(delay_hours)
        AS delay_hours

FROM aviation.flight_reroutes

GROUP BY
    origin_region,
    destination_region,
    origin_country,
    destination_country

ORDER BY
    rerouted_flights DESC,
    additional_distance_km DESC;