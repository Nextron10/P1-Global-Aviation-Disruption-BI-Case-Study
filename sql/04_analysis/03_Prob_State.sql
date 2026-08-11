-- TABLE: aviation.airline_losses_estimate

SELECT * FROM aviation.airline_losses_estimate;


-- Part 1: Rerouting Impact on Operational Disruption


SELECT 
    airline, 
    rerouted_flights, 
    cancelled_flights,
    estimated_daily_loss_usd as Financial_Loss,
    additional_fuel_cost_usd AS Extra_Fuel_Cost, 
    passengers_impacted
FROM aviation.airline_losses_estimate
ORDER BY airline;


-- Part 2: Comparison of Operational Resilience Across Airlines


SELECT
    airline,

    ROUND(
        cancelled_flights::NUMERIC
        / NULLIF(rerouted_flights, 0), 2
    ) AS Cancellations_Per_Rerouted_Flight,

    ROUND(
        passengers_impacted::NUMERIC
        / NULLIF(rerouted_flights, 0), 2
    ) AS Passengers_Impacted_Per_Rerouted_Flight,

    ROUND(
        additional_fuel_cost_usd::NUMERIC
        / NULLIF(rerouted_flights, 0), 2
    ) AS Fuel_Cost_Per_Rerouted_Flight

FROM aviation.airline_losses_estimate
ORDER BY airline;