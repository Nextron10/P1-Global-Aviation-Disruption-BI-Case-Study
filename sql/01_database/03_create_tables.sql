DROP TABLE IF EXISTS aviation.flight_reroutes CASCADE;
DROP TABLE IF EXISTS aviation.flight_cancellations CASCADE;
DROP TABLE IF EXISTS aviation.conflict_events CASCADE;
DROP TABLE IF EXISTS aviation.airspace_closures CASCADE;
DROP TABLE IF EXISTS aviation.airport_disruptions CASCADE;
DROP TABLE IF EXISTS aviation.airline_losses_estimate CASCADE;
DROP TABLE IF EXISTS aviation.airline_losses CASCADE;

CREATE TABLE aviation.airline_losses (
    airline TEXT,
    country TEXT,
    airline_type TEXT,
    estimated_loss_usd NUMERIC(15,2),
    cancellations_count INTEGER,
    reroutes_count INTEGER,
    revenue_loss_pct NUMERIC(5,2),
    region TEXT
);

CREATE TABLE aviation.airline_losses_estimate (
    airline TEXT,
    country TEXT,
    estimated_daily_loss_usd INTEGER,
    cancelled_flights INTEGER,
    rerouted_flights INTEGER,
    additional_fuel_cost_usd INTEGER,
    passengers_impacted INTEGER
);

CREATE TABLE aviation.airport_disruptions (
    airport_name TEXT,
    iata_code CHAR(3),
    country TEXT,
    region TEXT,
    disruption_type TEXT,
    severity_level TEXT,
    flights_affected INTEGER,
    duration_hours NUMERIC(6,2),
    date DATE
);

CREATE TABLE aviation.airspace_closures (
    country TEXT,
    region TEXT,
    closure_start_date TIMESTAMP,
    closure_end_date TIMESTAMP,
    duration_hours INTEGER,
    airspace_zone TEXT,
    reason TEXT,
    flights_affected INTEGER
);

CREATE TABLE aviation.conflict_events (
    date DATE,
    event_type TEXT,
    event_description TEXT,
    severity TEXT,
    aviation_impact TEXT,
    location_name TEXT,
    country TEXT
);

CREATE TABLE aviation.flight_cancellations (
    date DATE,
    airline TEXT,
    flight_number TEXT,
    origin TEXT,
    destination TEXT,
    origin_country TEXT,
    destination_country TEXT,
    origin_region TEXT,
    destination_region TEXT,
    aircraft_type TEXT,
    passengers_affected INTEGER,
    reason TEXT
);

CREATE TABLE aviation.flight_reroutes (
    date DATE,
    airline TEXT,
    flight_number TEXT,
    origin TEXT,
    destination TEXT,
    origin_country TEXT,
    destination_country TEXT,
    origin_region TEXT,
    destination_region TEXT,
    original_route TEXT,
    new_route TEXT,
    original_distance_km INTEGER,
    new_distance_km INTEGER,
    additional_distance_km INTEGER,
    extra_fuel_cost_usd NUMERIC(12,2),
    delay_hours NUMERIC(5,2)
);
