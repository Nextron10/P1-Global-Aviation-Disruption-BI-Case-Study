-- D. Geopolitical Impact Assessment
-- Military conflict events vs aviation disruption over time

WITH military_events_daily AS (

    SELECT
        date,

        COUNT(*) AS military_events,

        MAX(
            CASE severity
                WHEN 'Low' THEN 1
                WHEN 'Medium' THEN 2
                WHEN 'High' THEN 3
                WHEN 'Very High' THEN 4
                WHEN 'Critical' THEN 5
            END
        ) AS severity_level

    FROM aviation.conflict_events

    WHERE event_type = 'Military'

    GROUP BY date
),

airport_daily AS (

    SELECT
        date,
        COUNT(*) AS airport_disruptions

    FROM aviation.airport_disruptions

    GROUP BY date
),

airspace_daily AS (

    SELECT
        d.date,
        COUNT(a.country) AS airspace_closures

    FROM (
        SELECT DISTINCT date
        FROM aviation.conflict_events
        WHERE event_type = 'Military'
    ) d

    LEFT JOIN aviation.airspace_closures a
        ON d.date BETWEEN
           a.closure_start_date::date
           AND a.closure_end_date::date

    GROUP BY d.date
),

cancellation_daily AS (

    SELECT
        date,
        COUNT(*) AS cancellations

    FROM aviation.flight_cancellations

    GROUP BY date
),

reroute_daily AS (

    SELECT
        date,
        COUNT(*) AS reroutes

    FROM aviation.flight_reroutes

    GROUP BY date
)

SELECT

    m.date,

    m.military_events,

    CASE m.severity_level
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
        WHEN 5 THEN 'Critical'
    END AS conflict_severity,

    COALESCE(a.airport_disruptions, 0)
        AS airport_disruptions,

    COALESCE(s.airspace_closures, 0)
        AS airspace_closures,

    COALESCE(c.cancellations, 0)
        AS cancellations,

    COALESCE(r.reroutes, 0)
        AS reroutes

FROM military_events_daily m

LEFT JOIN airport_daily a
    ON m.date = a.date

LEFT JOIN airspace_daily s
    ON m.date = s.date

LEFT JOIN cancellation_daily c
    ON m.date = c.date

LEFT JOIN reroute_daily r
    ON m.date = r.date

ORDER BY m.date;