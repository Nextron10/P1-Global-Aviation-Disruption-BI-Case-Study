# Global Aviation Disruption Assessment 2026

Static, simulated portfolio case study using Python, PostgreSQL, SQL, and Power BI.

## Project purpose

Seven aviation-disruption datasets describe operational records, airport and airspace exposure, financial scenarios, and geopolitical context at different grains. The project demonstrates how to clean and reconcile the datasets without forcing incompatible populations to agree.

The analysis is descriptive. It is not a live monitoring system, a production deployment, an official aviation assessment, or evidence of causality.

## Data source and licensing

- Source: [Kaggle — Global Civil Aviation Disruption 2026 Iran–US War](https://www.kaggle.com/datasets/zkskhurram/global-civil-aviation-disruption2026-iranus-war)
- Download period: first week of August 2026
- Snapshot: all seven files came from the same latest dataset version available at download time
- Data classification: static simulated and modeled data
- Dataset license: CC BY-SA 4.0
- Repository code license: MIT

The project is not affiliated with, commissioned by, endorsed by, or conducted on behalf of ICAO, an airline, an airport, a government, a civil aviation authority, or a data provider.

## Architecture

![Project architecture](visuals/Architecture/Project%20Architecture.png)

```text
Business framing and requirements
→ Kaggle raw snapshot
→ Python profiling, cleaning, and validation
→ Clean UTF-8 CSV datasets
→ PostgreSQL source-aligned analytical tables
→ SQL analysis and reporting views
→ Power BI semantic model
→ Four report pages
→ Documentation and portfolio findings
```

Population separation is a design principle: detailed records, modeled summaries, and modeled estimates remain distinct.

## Source-of-truth matrix

| Business concept | Authoritative source | Grain and population | Date scope |
|---|---|---|---|
| Detailed cancellations and passengers | `flight_cancellations` | 2,200 simulated cancellation records | 27 February–7 June 2026 |
| Detailed reroutes, distance, fuel, and delay | `flight_reroutes` | 1,500 simulated reroute records | 28 February–7 June 2026 |
| Modeled airline loss and revenue loss | `airline_losses` | 70-airline undated modeled summary | No date supplied |
| Modeled summary cancellations and reroutes | `airline_losses` | 70-airline undated modeled summary | No date supplied |
| Estimated daily exposure | `airline_losses_estimate` | 35-airline undated modeled estimate | No date supplied |
| Airport exposure | `airport_disruptions` | 227 airport disruption records | 27 February–7 June 2026 |
| Airspace exposure | `airspace_closures` | 84 closure records | 28 February–17 June 2026 |
| Conflict-event context | `conflict_events` | 82 contextual event records | 15 December 2025–8 June 2026 |

The supplied snapshot contains 6,030 modeled-summary cancellations and 2,200 detailed cancellation records. It also contains 4,539 modeled-summary reroutes and 1,500 detailed reroute records. These are different source populations, not totals that should be forced to match.

The financial estimate table is not an aggregation of the modeled-summary table. Airport-affected and airspace-affected flights cannot be deduplicated because there is no shared flight identifier. Forty-two conflict records remain without a country because the source does not provide a defensible country value.

## Repository structure

```text
.vscode/                 Shared editor configuration
data/raw/                Seven immutable Kaggle source files
data/clean/              Seven reproducible UTF-8 clean files
documentation/           Authoritative business and technical documentation, plus handoff records
powerbi/                 Four-page PBIP project; semantic-model remediation is pending
python/etl/              Seven dataset ETL scripts
python/utils/            Shared validation and path helpers
sql/01_database/         Database, schema, and source-aligned tables
sql/02_loading/          Transactional UTF-8 reload
sql/03_validation/       Post-load and view reconciliation
sql/04_analysis/         Six business-question analysis files
sql/05_views/            Authoritative, supporting, and compatibility views
visuals/Architecture/    Current project architecture
visuals/ERD/             Existing ERD; replacement follows Power BI remediation
visuals/PowerBI_SS/      Existing dashboard screenshot PDF
```

## Reproduce the clean data

Use Python 3.12 or later. Do not use the Python runtime bundled inside pgAdmin; it belongs to pgAdmin and is not the project interpreter.

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python python/etl/01_airline_losses_etl.py
python python/etl/02_airline_losses_estimate_etl.py
python python/etl/03_airport_disruptions_etl.py
python python/etl/04_airspace_closures_etl.py
python python/etl/05_conflict_events_etl.py
python python/etl/06_flight_cancellations_etl.py
python python/etl/07_flight_reroutes_etl.py
```

Each script resolves paths from the repository, validates the expected schema, preserves its expected row count, and writes one UTF-8 clean CSV.

## Rebuild PostgreSQL

The examples assume that `psql` can authenticate without storing credentials in the repository.

```powershell
psql -d postgres -f sql/01_database/01_create_database.sql
psql -d aviation_bi -f sql/01_database/02_create_schema.sql
psql -d aviation_bi -f sql/01_database/03_create_tables.sql
psql -d aviation_bi -f sql/02_loading/01_load_data.psql
psql -d aviation_bi -f sql/05_views/01_create_views.sql
psql -d aviation_bi -f sql/03_validation/01_validation.sql
```

`03_create_tables.sql` rebuilds only the seven tables in schema `aviation` and their dependent views. `01_load_data.psql` performs the static truncate-and-reload in one transaction, uses explicit column lists, and stops on errors. Recreate the views before running validation.

The `.psql` extension is intentional. The loader contains psql client commands such as `\copy` and `\set`. Run it with psql or the pgAdmin PSQL Tool, not the pgAdmin Query Tool. The remaining SQL files are ordinary PostgreSQL scripts.

## Run SQL analysis

After validation, run the scripts in `sql/04_analysis/` in numeric order:

1. Airport disruption concentration and time pattern
2. Modeled airline financial scenario
3. Modeled airline estimate and population coverage
4. Descriptive geopolitical temporal comparison
5. Regional and route exposure
6. Executive population reconciliation

Each file states its business question, source, grain, population, date scope, calculation, and limitation.

## Reporting views

- Authoritative: `vw_airline_loss_summary`, `vw_airline_loss_estimate`
- Supporting: `vw_airport_disruption`, `vw_airspace_closure`, `vw_geopolitical_daily_impact`, `vw_regional_vulnerability`, `vw_route_passenger_impact`
- Deprecated compatibility: `vw_airline_operational_financial`, `vw_executive_kpi`

The deprecated views remain because the current Power BI model still references them. New work must use the population-specific views. Remove their Power BI dependencies only after each migrated visual passes validation.

## Power BI status

The repository contains a four-page PBIP report in Import mode. The PostgreSQL refresh has been completed, but the semantic-model, DAX, filter, and visual corrections remain Phase 2 work. The report should not be presented as final until the Honey completion guide passes every acceptance check.

## Documentation

- [Business requirements and analytical framework](documentation/Global%20Aviation%20Disruption%20Assessment%20Business%20Requirements.docx)
- [Technical implementation and validation documentation](documentation/Global%20Aviation%20Disruption%20Assessment%20Technical%20Documentation.docx)
- [Power BI completion and GitHub handoff guide for Honey](documentation/Honey%20Power%20BI%20Completion%20Guide.txt)
- [Remediation change log](documentation/Remediation%20Change%20Log.md)
- [Architecture](visuals/Architecture/)
- [ERD — replacement pending](visuals/ERD/)

The business document governs requirements and analytical intent. The technical document governs implementation, lineage, validation, and the current Power BI boundary. The earlier project, cleaning, SQL dictionary, and executive Word files are retained locally for historical comparison but are not part of the GitHub release. The executive findings will be rewritten after the Power BI model is stable.

## GitHub source-control policy

Commit the PBIP source files, including report definitions, semantic-model TMDL, themes, and `.platform` files. Do not commit Power BI `.pbi` folders, local settings, cache files, PBIX/PBIT binaries, virtual environments, credentials, database backups, Word lock files, or document-render output. The project `.gitignore` covers these local artifacts.

## Known limitations

- Static simulated and modeled source data with no external operational verification
- No shared flight or event identifier across all datasets
- Undated financial summary and estimate tables
- Different source-defined populations and regional vocabularies
- Incomplete conflict-event country coverage
- Temporal association does not establish causality
- No forecasting, optimization, official recommendations, or live monitoring
- Power BI semantic-model, ERD, screenshots, and executive findings remain pending

## Authors

Dhaerya Nauni and Honey Aggarwal
