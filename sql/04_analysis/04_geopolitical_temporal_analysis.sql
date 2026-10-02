/* Business question
   How do dated aviation metrics differ across military-event and non-event dates?
   Sources/grain: daily baseline; one calendar date per row.
   Population/date scope: intersection of airport, cancellation and reroute
   snapshot date ranges. The current snapshot covers 2026-02-28 to 2026-06-07.
   Calculation: descriptive grouping by event-date indicator.
   Limitation: snapshot date bounds are not proof of complete operational
   observation. Missing records inside the window mean no supplied records,
   not verified absence of disruption. Alignment does not prove causation. */

/* Compare only dates inside every operational dataset's snapshot range. */
WITH coverage AS (
    SELECT
        GREATEST(
            (SELECT MIN(date) FROM aviation.airport_disruptions),
            (SELECT MIN(date) FROM aviation.flight_cancellations),
            (SELECT MIN(date) FROM aviation.flight_reroutes)
        ) AS first_date,
        LEAST(
            (SELECT MAX(date) FROM aviation.airport_disruptions),
            (SELECT MAX(date) FROM aviation.flight_cancellations),
            (SELECT MAX(date) FROM aviation.flight_reroutes)
        ) AS last_date
)
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
CROSS JOIN coverage
WHERE date BETWEEN coverage.first_date AND coverage.last_date
GROUP BY is_military_event_date
ORDER BY is_military_event_date DESC;

/* Keep the wider context timeline. Operational values outside each source's
   snapshot range are unknown, so show NULL rather than a zero observation. */
WITH coverage AS (
    SELECT
        (SELECT MIN(date) FROM aviation.airport_disruptions) AS airport_first,
        (SELECT MAX(date) FROM aviation.airport_disruptions) AS airport_last,
        (SELECT MIN(date) FROM aviation.flight_cancellations) AS cancellation_first,
        (SELECT MAX(date) FROM aviation.flight_cancellations) AS cancellation_last,
        (SELECT MIN(date) FROM aviation.flight_reroutes) AS reroute_first,
        (SELECT MAX(date) FROM aviation.flight_reroutes) AS reroute_last
)
SELECT
    date,
    is_military_event_date,
    military_events,
    conflict_severity,
    CASE WHEN date BETWEEN airport_first AND airport_last
        THEN airport_disruptions END AS airport_disruptions,
    airspace_closures,
    CASE WHEN date BETWEEN cancellation_first AND cancellation_last
        THEN cancellations END AS cancellations,
    CASE WHEN date BETWEEN reroute_first AND reroute_last
        THEN reroutes END AS reroutes,
    (date BETWEEN GREATEST(airport_first, cancellation_first, reroute_first)
        AND LEAST(airport_last, cancellation_last, reroute_last))
        AS is_operational_comparison_date
FROM aviation.vw_geopolitical_daily_impact
CROSS JOIN coverage
ORDER BY date;
