/*
This file checks the database after loading and after creating the views.
The Python ETL layer performs the raw-to-clean data-quality checks.
*/

/* 1. Load completeness: expected row counts from the August 2026 snapshot. */
WITH actual AS (
    SELECT 'airline_losses' AS object_name, CAST(COUNT(*) AS BIGINT) AS actual_rows FROM aviation.airline_losses
    UNION ALL SELECT 'airline_losses_estimate', COUNT(*) FROM aviation.airline_losses_estimate
    UNION ALL SELECT 'airport_disruptions', COUNT(*) FROM aviation.airport_disruptions
    UNION ALL SELECT 'airspace_closures', COUNT(*) FROM aviation.airspace_closures
    UNION ALL SELECT 'conflict_events', COUNT(*) FROM aviation.conflict_events
    UNION ALL SELECT 'flight_cancellations', COUNT(*) FROM aviation.flight_cancellations
    UNION ALL SELECT 'flight_reroutes', COUNT(*) FROM aviation.flight_reroutes
),
expected(object_name, expected_rows) AS (
    VALUES
        ('airline_losses', CAST(70 AS BIGINT)),
        ('airline_losses_estimate', 35),
        ('airport_disruptions', 227),
        ('airspace_closures', 84),
        ('conflict_events', 82),
        ('flight_cancellations', 2200),
        ('flight_reroutes', 1500)
)
SELECT
    e.object_name,
    e.expected_rows,
    a.actual_rows,
    (e.expected_rows = a.actual_rows) AS passed
FROM expected e
JOIN actual a USING (object_name)
ORDER BY e.object_name;

/* 2. Material control totals, kept population-specific. */
SELECT
    (SELECT SUM(cancellations_count) FROM aviation.airline_losses)
        AS modeled_summary_cancellations,
    (SELECT COUNT(*) FROM aviation.flight_cancellations)
        AS detailed_cancellation_records,
    (SELECT SUM(reroutes_count) FROM aviation.airline_losses)
        AS modeled_summary_reroutes,
    (SELECT COUNT(*) FROM aviation.flight_reroutes)
        AS detailed_reroute_records,
    (SELECT SUM(passengers_affected) FROM aviation.flight_cancellations)
        AS detailed_passengers_affected,
    (SELECT SUM(additional_distance_km) FROM aviation.flight_reroutes)
        AS detailed_additional_distance_km,
    (SELECT SUM(extra_fuel_cost_usd) FROM aviation.flight_reroutes)
        AS detailed_extra_fuel_cost_usd,
    (SELECT SUM(delay_hours) FROM aviation.flight_reroutes)
        AS detailed_delay_hours,
    (SELECT SUM(estimated_loss_usd) FROM aviation.airline_losses)
        AS modeled_summary_loss_usd,
    (SELECT SUM(estimated_daily_loss_usd) FROM aviation.airline_losses_estimate)
        AS modeled_estimated_daily_loss_usd;

/* 3. Conflict location preservation and intentional nullable geography. */
SELECT
    COUNT(*) AS conflict_rows,
    SUM(CASE WHEN source_location IS NULL OR source_location = '' THEN 1 ELSE 0 END)
        AS missing_source_location,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS unresolved_country_rows
FROM aviation.conflict_events;

/* 4. Financial population coverage. Expect 70 summary, 35 estimate, 73 union. */
SELECT
    COUNT(*) AS union_airlines,
    SUM(CASE WHEN has_summary_data THEN 1 ELSE 0 END) AS summary_airlines,
    SUM(CASE WHEN has_estimate_data THEN 1 ELSE 0 END) AS estimate_airlines,
    SUM(CASE WHEN has_summary_data AND has_estimate_data THEN 1 ELSE 0 END)
        AS overlapping_airlines,
    SUM(CASE WHEN NOT has_summary_data THEN 1 ELSE 0 END) AS estimate_only_airlines,
    SUM(CASE WHEN NOT has_estimate_data THEN 1 ELSE 0 END) AS summary_only_airlines
FROM aviation.vw_airline_operational_financial;

/* 5. View row/aggregate preservation. Every comparison should pass. */
SELECT
    (SELECT COUNT(*) FROM aviation.vw_airline_loss_summary)
        = (SELECT COUNT(*) FROM aviation.airline_losses) AS summary_rows_pass,
    (SELECT COUNT(*) FROM aviation.vw_airline_loss_estimate)
        = (SELECT COUNT(*) FROM aviation.airline_losses_estimate) AS estimate_rows_pass,
    (SELECT COUNT(*) FROM aviation.vw_airport_disruption)
        = (SELECT COUNT(*) FROM aviation.airport_disruptions) AS airport_rows_pass,
    (SELECT COUNT(*) FROM aviation.vw_airspace_closure)
        = (SELECT COUNT(*) FROM aviation.airspace_closures) AS airspace_rows_pass,
    (SELECT SUM(cancelled_flights) FROM aviation.vw_route_passenger_impact)
        = (SELECT COUNT(*) FROM aviation.flight_cancellations) AS route_cancellations_pass,
    (SELECT SUM(passengers_affected) FROM aviation.vw_route_passenger_impact)
        = (SELECT SUM(passengers_affected) FROM aviation.flight_cancellations) AS route_passengers_pass,
    (SELECT SUM(rerouted_flights) FROM aviation.vw_route_passenger_impact)
        = (SELECT COUNT(*) FROM aviation.flight_reroutes) AS route_reroutes_pass,
    (SELECT SUM(additional_distance_km) FROM aviation.vw_route_passenger_impact)
        = (SELECT SUM(additional_distance_km) FROM aviation.flight_reroutes) AS route_distance_pass;

/* 6. The daily view must include non-event dates and cover the complete date spine. */
SELECT
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS calendar_days,
    SUM(CASE WHEN is_military_event_date THEN 1 ELSE 0 END) AS military_event_dates,
    SUM(CASE WHEN NOT is_military_event_date THEN 1 ELSE 0 END)
        AS non_military_event_dates
FROM aviation.vw_geopolitical_daily_impact;
