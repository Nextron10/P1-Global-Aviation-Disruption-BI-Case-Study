/* Business question
   Which regions and route corridors have the largest separately reported exposure?
   Sources/grain: regional aggregates plus daily origin/destination-country routes.
   Population/date scope: source-specific scopes retained by column.
   Calculation: sums within each source population.
   Limitation: airport and airspace affected flights are not additive or deduplicated. */

SELECT
    region,
    airport_disruption_events,
    airports_affected,
    airport_flights_affected,
    airport_disruption_hours,
    estimated_loss_usd AS modeled_summary_loss_usd,
    airspace_closures,
    airspace_closure_hours,
    airspace_flights_affected
FROM aviation.vw_regional_vulnerability
ORDER BY modeled_summary_loss_usd DESC, region;

SELECT
    origin_region,
    destination_region,
    origin_country,
    destination_country,
    SUM(cancelled_flights) AS detailed_cancellation_records,
    SUM(passengers_affected) AS detailed_passengers_affected,
    SUM(rerouted_flights) AS detailed_reroute_records,
    SUM(additional_distance_km) AS detailed_additional_distance_km,
    SUM(additional_fuel_cost_usd) AS detailed_extra_fuel_cost_usd,
    SUM(delay_hours) AS detailed_delay_hours
FROM aviation.vw_route_passenger_impact
GROUP BY origin_region, destination_region, origin_country, destination_country
ORDER BY detailed_cancellation_records DESC,
         detailed_reroute_records DESC,
         origin_country,
         destination_country;
