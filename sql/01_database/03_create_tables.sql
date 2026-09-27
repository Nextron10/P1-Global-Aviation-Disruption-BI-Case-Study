/*
Rebuild the seven source-aligned analytical tables.
The source files do not contain proven shared identifiers, so this script does
not invent primary keys or foreign keys between the tables.
*/
BEGIN;

/* Remove the old tables and dependent views before rebuilding the schema. */
DROP TABLE IF EXISTS aviation.flight_reroutes CASCADE;
DROP TABLE IF EXISTS aviation.flight_cancellations CASCADE;
DROP TABLE IF EXISTS aviation.conflict_events CASCADE;
DROP TABLE IF EXISTS aviation.airspace_closures CASCADE;
DROP TABLE IF EXISTS aviation.airport_disruptions CASCADE;
DROP TABLE IF EXISTS aviation.airline_losses_estimate CASCADE;
DROP TABLE IF EXISTS aviation.airline_losses CASCADE;

/* Create the undated modeled airline summary table. */
CREATE TABLE aviation.airline_losses (
    airline TEXT NOT NULL,
    country TEXT NOT NULL,
    airline_type TEXT NOT NULL
        CHECK (airline_type IN ('Cargo', 'Flag Carrier', 'Low Cost', 'Private')),
    estimated_loss_usd NUMERIC(15,2) NOT NULL CHECK (estimated_loss_usd >= 0),
    cancellations_count INTEGER NOT NULL CHECK (cancellations_count >= 0),
    reroutes_count INTEGER NOT NULL CHECK (reroutes_count >= 0),
    revenue_loss_pct NUMERIC(5,2) NOT NULL CHECK (revenue_loss_pct BETWEEN 0 AND 100),
    region TEXT NOT NULL
);

COMMENT ON TABLE aviation.airline_losses IS
    'One row per airline; undated modeled summary population. Not operational flight detail.';

/* Create the undated modeled airline estimate table. */
CREATE TABLE aviation.airline_losses_estimate (
    airline TEXT NOT NULL,
    country TEXT NOT NULL,
    estimated_daily_loss_usd BIGINT NOT NULL CHECK (estimated_daily_loss_usd >= 0),
    cancelled_flights INTEGER NOT NULL CHECK (cancelled_flights >= 0),
    rerouted_flights INTEGER NOT NULL CHECK (rerouted_flights >= 0),
    additional_fuel_cost_usd BIGINT NOT NULL CHECK (additional_fuel_cost_usd >= 0),
    passengers_impacted INTEGER NOT NULL CHECK (passengers_impacted >= 0)
);

COMMENT ON TABLE aviation.airline_losses_estimate IS
    'One row per airline; undated modeled daily-estimate population.';

/* Create the simulated airport disruption detail table. */
CREATE TABLE aviation.airport_disruptions (
    airport_name TEXT NOT NULL,
    iata_code VARCHAR(3) NOT NULL CHECK (char_length(iata_code) = 3),
    country TEXT NOT NULL,
    region TEXT NOT NULL,
    disruption_type TEXT NOT NULL,
    severity_level TEXT NOT NULL
        CHECK (severity_level IN ('Low', 'Moderate', 'High', 'Severe', 'Critical')),
    flights_affected INTEGER NOT NULL CHECK (flights_affected >= 0),
    duration_hours NUMERIC(10,2) NOT NULL CHECK (duration_hours >= 0),
    date DATE NOT NULL
);

COMMENT ON TABLE aviation.airport_disruptions IS
    'One simulated airport disruption record per row; records may repeat an airport on different dates or events.';

/* Create the simulated airspace closure detail table. */
CREATE TABLE aviation.airspace_closures (
    country TEXT NOT NULL,
    region TEXT NOT NULL,
    closure_start_date TIMESTAMP NOT NULL,
    closure_end_date TIMESTAMP NOT NULL,
    duration_hours NUMERIC(10,2) NOT NULL CHECK (duration_hours >= 0),
    airspace_zone TEXT NOT NULL,
    reason TEXT NOT NULL,
    flights_affected INTEGER NOT NULL CHECK (flights_affected >= 0),
    CHECK (closure_end_date >= closure_start_date)
);

COMMENT ON TABLE aviation.airspace_closures IS
    'One simulated airspace closure record per row; timestamps are retained intact.';

/* Create the simulated conflict event context table. */
CREATE TABLE aviation.conflict_events (
    date DATE NOT NULL,
    event_type TEXT NOT NULL,
    event_description TEXT NOT NULL,
    source_location TEXT NOT NULL,
    location_name TEXT NOT NULL,
    country TEXT,
    severity TEXT NOT NULL
        CHECK (severity IN ('Low', 'Medium', 'High', 'Very High', 'Critical')),
    aviation_impact TEXT NOT NULL
);

COMMENT ON TABLE aviation.conflict_events IS
    'One simulated contextual event per row. Country is nullable when the source location is regional, global or otherwise non-country-specific.';

/* Create the simulated cancellation detail table. */
CREATE TABLE aviation.flight_cancellations (
    date DATE NOT NULL,
    airline TEXT NOT NULL,
    flight_number TEXT NOT NULL,
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    origin_country TEXT NOT NULL,
    destination_country TEXT NOT NULL,
    origin_region TEXT NOT NULL,
    destination_region TEXT NOT NULL,
    aircraft_type TEXT NOT NULL,
    passengers_affected INTEGER NOT NULL CHECK (passengers_affected >= 0),
    reason TEXT NOT NULL
);

COMMENT ON TABLE aviation.flight_cancellations IS
    'One simulated detailed cancellation record per row; repeated flight numbers are not assumed to be duplicate events.';

/* Create the simulated reroute detail table. */
CREATE TABLE aviation.flight_reroutes (
    date DATE NOT NULL,
    airline TEXT NOT NULL,
    flight_number TEXT NOT NULL,
    origin TEXT NOT NULL,
    destination TEXT NOT NULL,
    origin_country TEXT NOT NULL,
    destination_country TEXT NOT NULL,
    origin_region TEXT NOT NULL,
    destination_region TEXT NOT NULL,
    original_route TEXT NOT NULL,
    new_route TEXT NOT NULL,
    original_distance_km INTEGER NOT NULL CHECK (original_distance_km >= 0),
    new_distance_km INTEGER NOT NULL CHECK (new_distance_km >= 0),
    additional_distance_km INTEGER NOT NULL CHECK (additional_distance_km >= 0),
    extra_fuel_cost_usd NUMERIC(12,2) NOT NULL CHECK (extra_fuel_cost_usd >= 0),
    delay_hours NUMERIC(8,2) NOT NULL CHECK (delay_hours >= 0),
    CHECK (new_distance_km - original_distance_km = additional_distance_km)
);

COMMENT ON TABLE aviation.flight_reroutes IS
    'One simulated detailed reroute record per row.';

COMMIT;
