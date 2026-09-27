/* Business question
   What exposure is represented by the modeled daily-estimate population?
   Source/grain: airline_losses_estimate; one undated estimate row per airline.
   Population/date scope: 35 airlines; no date dimension.
   Calculation: source totals and within-table per-reroute descriptive ratios.
   Limitation: this is not an aggregation of the 70-airline summary population. */

SELECT
    airline,
    country,
    estimated_daily_loss_usd,
    cancelled_flights AS modeled_estimated_cancelled_flights,
    rerouted_flights AS modeled_estimated_rerouted_flights,
    additional_fuel_cost_usd AS modeled_estimated_fuel_cost_usd,
    passengers_impacted AS modeled_estimated_passengers,
    ROUND(CAST(cancelled_flights AS NUMERIC) / NULLIF(rerouted_flights, 0), 2)
        AS estimated_cancellations_per_estimated_reroute,
    ROUND(CAST(passengers_impacted AS NUMERIC) / NULLIF(rerouted_flights, 0), 2)
        AS estimated_passengers_per_estimated_reroute
FROM aviation.airline_losses_estimate
ORDER BY estimated_daily_loss_usd DESC, airline;

SELECT
    COUNT(*) AS estimate_airlines,
    SUM(estimated_daily_loss_usd) AS modeled_estimated_daily_loss_usd,
    SUM(cancelled_flights) AS modeled_estimated_cancelled_flights,
    SUM(rerouted_flights) AS modeled_estimated_rerouted_flights,
    SUM(additional_fuel_cost_usd) AS modeled_estimated_fuel_cost_usd,
    SUM(passengers_impacted) AS modeled_estimated_passengers
FROM aviation.airline_losses_estimate;

SELECT
    COALESCE(s.airline, e.airline) AS airline,
    (s.airline IS NOT NULL) AS in_modeled_summary,
    (e.airline IS NOT NULL) AS in_modeled_estimate
FROM aviation.airline_losses s
FULL OUTER JOIN aviation.airline_losses_estimate e
    ON s.airline = e.airline
WHERE s.airline IS NULL OR e.airline IS NULL
ORDER BY airline;
