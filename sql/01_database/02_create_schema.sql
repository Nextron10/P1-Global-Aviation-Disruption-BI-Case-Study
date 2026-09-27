/* Create the project schema and record its analytical purpose. */
BEGIN;

CREATE SCHEMA IF NOT EXISTS aviation;
COMMENT ON SCHEMA aviation IS
    'Static, simulated aviation-disruption portfolio data; source-aligned analytical tables.';

COMMIT;
