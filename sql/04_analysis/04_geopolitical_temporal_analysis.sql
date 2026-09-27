/* Business question
   How do dated aviation metrics differ across military-event and non-event dates?
   Sources/grain: daily baseline from all dated facts; one calendar date per row.
   Population/date scope: complete 2025-12-15 through 2026-06-17 baseline.
   Calculation: descriptive grouping by event-date indicator.
   Limitation: temporal coincidence does not establish conflict causation. */

SELECT
    is_military_event_date,
    COUNT(*) AS calendar_days,
    SUM(military_events) AS military_event_records,
    SUM(airport_disruptions) AS airport_disruption_records,
    SUM(cancellations) AS detailed_cancellation_records,
    SUM(reroutes) AS detailed_reroute_records,
    ROUND(AVG(airport_disruptions), 2) AS mean_airport_records_per_day,
    ROUND(AVG(cancellations), 2) AS mean_cancellations_per_day,
    ROUND(AVG(reroutes), 2) AS mean_reroutes_per_day
FROM aviation.vw_geopolitical_daily_impact
GROUP BY is_military_event_date
ORDER BY is_military_event_date DESC;

SELECT
    date,
    is_military_event_date,
    military_events,
    conflict_severity,
    airport_disruptions,
    airspace_closures,
    cancellations,
    reroutes
FROM aviation.vw_geopolitical_daily_impact
ORDER BY date;
