SELECT
    (SELECT COUNT(*) FROM aviation.airline_losses) AS airline_losses,
    (SELECT COUNT(*) FROM aviation.airline_losses_estimate) AS airline_losses_estimate,
    (SELECT COUNT(*) FROM aviation.airport_disruptions) AS airport_disruptions,
    (SELECT COUNT(*) FROM aviation.airspace_closures) AS airspace_closures,
    (SELECT COUNT(*) FROM aviation.conflict_events) AS conflict_events,
    (SELECT COUNT(*) FROM aviation.flight_cancellations) AS flight_cancellations,
    (SELECT COUNT(*) FROM aviation.flight_reroutes) AS flight_reroutes;