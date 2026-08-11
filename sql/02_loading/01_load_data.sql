\copy aviation.airline_losses FROM 'data/clean/airline_losses_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.airline_losses_estimate FROM 'data/clean/airline_losses_estimate_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.airport_disruptions FROM 'data/clean/airport_disruptions_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.airspace_closures FROM 'data/clean/airspace_closures_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.conflict_events FROM 'data/clean/conflict_events_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.flight_cancellations FROM 'data/clean/flight_cancellations_clean.csv' WITH (FORMAT csv, HEADER true);
\copy aviation.flight_reroutes FROM 'data/clean/flight_reroutes_clean.csv' WITH (FORMAT csv, HEADER true);