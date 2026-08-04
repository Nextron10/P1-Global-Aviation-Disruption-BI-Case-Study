\copy aviation.airline_losses
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\airline_losses_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.airline_losses_estimate
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\airline_losses_estimate_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.airport_disruptions
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\airport_disruptions_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.airspace_closures
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\airspace_closures_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.conflict_events
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\conflict_events_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.flight_cancellations
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\flight_cancellations_clean.csv'
WITH (FORMAT csv, HEADER true);

\copy aviation.flight_reroutes
FROM 'A:\Projects Data\P1-Global-Aviation-Disruption-BI-Case-Study\data\clean\flight_reroutes_clean.csv'
WITH (FORMAT csv, HEADER true);