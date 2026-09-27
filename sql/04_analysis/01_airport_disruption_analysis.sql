/* Business question
   Where and when are detailed airport disruption records concentrated?
   Source/grain: airport_disruptions; one simulated airport disruption record.
   Population/date scope: 227 records, 2026-02-27 through 2026-06-07.
   Calculation: separate event counts, affected-flight sums and duration sums.
   Limitation: affected flights cannot be deduplicated against airspace records. */

SELECT
    region,
    COUNT(*) AS airport_disruption_records,
    COUNT(DISTINCT iata_code) AS distinct_airports,
    SUM(flights_affected) AS reported_airport_flights_affected,
    SUM(duration_hours) AS reported_airport_disruption_hours
FROM aviation.airport_disruptions
GROUP BY region
ORDER BY reported_airport_flights_affected DESC, region;

SELECT
    country,
    COUNT(*) AS airport_disruption_records,
    COUNT(DISTINCT iata_code) AS distinct_airports,
    SUM(flights_affected) AS reported_airport_flights_affected,
    SUM(duration_hours) AS reported_airport_disruption_hours
FROM aviation.airport_disruptions
GROUP BY country
ORDER BY reported_airport_flights_affected DESC, country;

SELECT
    airport_name,
    iata_code,
    country,
    region,
    COUNT(*) AS airport_disruption_records,
    SUM(flights_affected) AS reported_airport_flights_affected,
    SUM(duration_hours) AS reported_airport_disruption_hours,
    MAX(duration_hours) AS longest_reported_disruption_hours
FROM aviation.airport_disruptions
GROUP BY airport_name, iata_code, country, region
ORDER BY reported_airport_flights_affected DESC, airport_name;

SELECT
    date,
    region,
    COUNT(*) AS airport_disruption_records,
    SUM(flights_affected) AS reported_airport_flights_affected
FROM aviation.airport_disruptions
GROUP BY date, region
ORDER BY date, region;
