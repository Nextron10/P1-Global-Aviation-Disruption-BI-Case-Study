/* Business question
   Which airlines and regions have the highest modeled financial exposure?
   Source/grain: airline_losses; one undated modeled-summary row per airline.
   Population/date scope: 70 airlines; no date dimension.
   Calculation: rank source-provided loss and summary disruption values.
   Limitation: values are modeled, not audited accounts or operational facts. */

SELECT
    airline,
    country,
    airline_type,
    region,
    estimated_loss_usd AS modeled_total_loss_usd,
    cancellations_count AS modeled_summary_cancellations,
    reroutes_count AS modeled_summary_reroutes,
    revenue_loss_pct AS modeled_revenue_loss_pct
FROM aviation.airline_losses
ORDER BY modeled_total_loss_usd DESC, airline;

SELECT
    region,
    COUNT(*) AS summary_airlines,
    SUM(estimated_loss_usd) AS modeled_total_loss_usd,
    SUM(cancellations_count) AS modeled_summary_cancellations,
    SUM(reroutes_count) AS modeled_summary_reroutes,
    ROUND(AVG(revenue_loss_pct), 2) AS mean_modeled_revenue_loss_pct
FROM aviation.airline_losses
GROUP BY region
ORDER BY modeled_total_loss_usd DESC, region;

SELECT
    airline_type,
    COUNT(*) AS summary_airlines,
    SUM(estimated_loss_usd) AS modeled_total_loss_usd
FROM aviation.airline_losses
GROUP BY airline_type
ORDER BY modeled_total_loss_usd DESC, airline_type;
