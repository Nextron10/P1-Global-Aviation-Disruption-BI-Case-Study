--   PART 1 — EXECUTIVE KPI SUMMARY
 

SELECT
    (SELECT COUNT(*)
     FROM aviation.flight_cancellations)
        AS total_cancellations,

    (SELECT COUNT(*)
     FROM aviation.flight_reroutes)
        AS total_reroutes,

    (SELECT SUM(flights_affected)
     FROM aviation.airport_disruptions)
        AS airport_flights_affected,

    (SELECT COUNT(*)
     FROM aviation.airspace_closures)
        AS airspace_closures,

    (SELECT SUM(duration_hours)
     FROM aviation.airspace_closures)
        AS airspace_closure_hours,

    (SELECT SUM(estimated_loss_usd)
     FROM aviation.airline_losses)
        AS total_estimated_loss_usd,

    (SELECT COUNT(*)
     FROM aviation.conflict_events)
        AS conflict_events;


/* ============================================================
   PART 2 — EXECUTIVE PRIORITY SNAPSHOT
   ============================================================ */

SELECT
    'Airline' AS priority_area,
    airline AS entity,
    region,
    estimated_loss_usd AS impact_value
FROM aviation.airline_losses
ORDER BY estimated_loss_usd DESC
LIMIT 1;


SELECT
    'Airport' AS priority_area,
    airport_name AS entity,
    region,
    SUM(flights_affected) AS impact_value
FROM aviation.airport_disruptions
GROUP BY airport_name, region
ORDER BY impact_value DESC
LIMIT 1;


SELECT
    'Region' AS priority_area,
    region AS entity,
    SUM(estimated_loss_usd) AS impact_value
FROM aviation.airline_losses
GROUP BY region
ORDER BY impact_value DESC
LIMIT 1;