/* Business question
   What are the defensible control totals and population differences?
   Sources/grain: all seven source-aligned tables, reported independently.
   Population/date scope: each source's documented scope.
   Calculation: one row per metric; no cross-population ratios or additive totals.
   Limitation: values below must retain their population labels in downstream BI. */

SELECT 'Detailed cancellation records' AS metric,
       CAST(COUNT(*) AS NUMERIC) AS value,
       'flight_cancellations; dated simulated detail' AS population
FROM aviation.flight_cancellations
UNION ALL
SELECT 'Detailed passengers affected', SUM(passengers_affected),
       'flight_cancellations; dated simulated detail'
FROM aviation.flight_cancellations
UNION ALL
SELECT 'Detailed reroute records', CAST(COUNT(*) AS NUMERIC),
       'flight_reroutes; dated simulated detail'
FROM aviation.flight_reroutes
UNION ALL
SELECT 'Detailed additional distance km', SUM(additional_distance_km),
       'flight_reroutes; dated simulated detail'
FROM aviation.flight_reroutes
UNION ALL
SELECT 'Detailed extra fuel cost USD', SUM(extra_fuel_cost_usd),
       'flight_reroutes; dated simulated detail'
FROM aviation.flight_reroutes
UNION ALL
SELECT 'Detailed reroute delay hours', SUM(delay_hours),
       'flight_reroutes; dated simulated detail'
FROM aviation.flight_reroutes
UNION ALL
SELECT 'Modeled summary cancellations', SUM(cancellations_count),
       'airline_losses; undated modeled summary'
FROM aviation.airline_losses
UNION ALL
SELECT 'Modeled summary reroutes', SUM(reroutes_count),
       'airline_losses; undated modeled summary'
FROM aviation.airline_losses
UNION ALL
SELECT 'Modeled summary airline loss USD', SUM(estimated_loss_usd),
       'airline_losses; undated modeled summary'
FROM aviation.airline_losses
UNION ALL
SELECT 'Modeled estimated daily loss USD', SUM(estimated_daily_loss_usd),
       'airline_losses_estimate; undated modeled estimate'
FROM aviation.airline_losses_estimate
UNION ALL
SELECT 'Reported airport flights affected', SUM(flights_affected),
       'airport_disruptions; airport records'
FROM aviation.airport_disruptions
UNION ALL
SELECT 'Reported airspace flights affected', SUM(flights_affected),
       'airspace_closures; closure records'
FROM aviation.airspace_closures
ORDER BY metric;
