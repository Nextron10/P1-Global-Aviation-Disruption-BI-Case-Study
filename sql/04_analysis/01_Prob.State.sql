-- Table: aviation.airport_disruptions
Select * FROM aviation.airport_disruptions;

-- Part 1: Concentration of disruptions by region, country, and airport

SELECT region, SUM(flights_affected) as region_disruption_count
 FROM aviation.airport_disruptions
 GROUP BY region
 ORDER BY region_disruption_count DESC;

SELECT country, SUM(flights_affected) as country_disruption_count
 FROM aviation.airport_disruptions
 GROUP BY country
 ORDER BY country_disruption_count DESC;

SELECT airport_name, SUM(flights_affected) as airport_disruption_count
 FROM aviation.airport_disruptions
 GROUP BY airport_name
 ORDER BY airport_disruption_count DESC;


-- Part 2: Evolution of disruptions over time.g

SELECT date,region, sum(flights_affected) as region_disruption_trend
 FROM aviation.airport_disruptions
 GROUP BY date, region
 ORDER BY date;

SELECT date, country, sum(flights_affected) as country_disruption_trend
 FROM aviation.airport_disruptions
 GROUP BY country, date
 ORDER BY date, country;

SELECT date, airport_name, sum(flights_affected) as airport_disruption_trend
 FROM aviation.airport_disruptions
 GROUP BY airport_name, date
 ORDER BY date, airport_name; 


-- Part 3: Factors contributing to disruptions

Select 'Airspace Closure' as Operational_Factor,
Sum(flights_affected) AS total_affected_flights

FROM aviation.airspace_closures

UNION ALL

SELECT 'Airport Disruption' as Operational_Factor,
Sum(flights_affected) AS total_affected_flights
from aviation.airport_disruptions;
