-- TABLE: aviation.airline_losses

SELECT * FROM aviation.airline_losses;

-- Analysis 1: Financial impact due to operational disruption

SELECT
    airline,
    cancellations_count AS Total_Cancellations,
    reroutes_count AS Total_Reroutes,
    estimated_loss_usd AS Total_Estimated_Loss_USD,
    revenue_loss_pct AS Revenue_Loss_Percentage
FROM aviation.airline_losses
ORDER BY estimated_loss_usd DESC;

-- Analysis 2: Additional financial exposure from daily estimates

SELECT
    airline,
    cancelled_flights AS Daily_Cancelled_Flights,
    rerouted_flights AS Daily_Rerouted_Flights,
    estimated_daily_loss_usd AS Estimated_Daily_Loss_USD,
    additional_fuel_cost_usd AS Additional_Fuel_Cost_USD,
    passengers_impacted AS Daily_Passengers_Impacted
FROM aviation.airline_losses_estimate
ORDER BY estimated_daily_loss_usd DESC;

-- Analysis 3: Financial resilience among airlines with similar operational conditions

SELECT
    a.airline AS Airline_A,
    b.airline AS Airline_B,

    a.cancellations_count AS A_Cancellations,
    b.cancellations_count AS B_Cancellations,

    a.reroutes_count AS A_Reroutes,
    b.reroutes_count AS B_Reroutes,

    a.estimated_loss_usd AS A_Estimated_Loss,
    b.estimated_loss_usd AS B_Estimated_Loss,

    a.revenue_loss_pct AS A_Revenue_Loss,
    b.revenue_loss_pct AS B_Revenue_Loss

FROM aviation.airline_losses a

JOIN aviation.airline_losses b
    ON a.airline < b.airline

WHERE
    ABS(a.cancellations_count - b.cancellations_count)
        / ((a.cancellations_count + b.cancellations_count) / 2.0) <= 0.20

    AND

    ABS(a.reroutes_count - b.reroutes_count)
        / ((a.reroutes_count + b.reroutes_count) / 2.0) <= 0.20

ORDER BY
    A_Estimated_Loss DESC;