# Global Aviation Disruption Assessment 2026

Static, simulated portfolio case study using Python, PostgreSQL, SQL, and Power BI.

## Project purpose

Seven aviation-disruption datasets describe operational records, airport and airspace exposure, financial scenarios, and geopolitical context at different grains. The project demonstrates how to clean and reconcile the datasets without forcing incompatible populations to agree.

The analysis is descriptive. It is not a live monitoring system, a production deployment, an official aviation assessment, or evidence of causality.

## Data source and licensing

- Source: [Kaggle — Global Civil Aviation Disruption 2026 Iran–US War](https://www.kaggle.com/datasets/zkskhurram/global-civil-aviation-disruption2026-iranus-war)
- Snapshot: seven source files downloaded in the first week of August 2026
- Data classification: static simulated and modeled data
- Dataset license: CC BY-SA 4.0
- Repository code license: MIT

This is an independent portfolio project, not an official or endorsed aviation assessment.

## Architecture

![Project architecture](visuals/Architecture/Project%20Architecture.png)

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
| Airspace exposure | `airspace_closures` | 84 closure records | Starts: 28 February–7 June; ends through 17 June 2026 |
| Conflict-event context | `conflict_events` | 82 contextual event records | 15 December 2025–8 June 2026 |

The supplied snapshot contains 6,030 modeled-summary cancellations and 2,200 detailed cancellation records. It also contains 4,539 modeled-summary reroutes and 1,500 detailed reroute records. These are different source populations, not totals that should be forced to match.

The financial estimate table is not an aggregation of the modeled-summary table. Airport-affected and airspace-affected flights cannot be deduplicated because there is no shared flight identifier. Forty-two conflict records remain without a country because the source does not provide a defensible country value.

## Repository structure

```text
.vscode/                 Shared editor configuration
data/raw/                Seven immutable Kaggle source files
data/clean/              Seven reproducible UTF-8 clean files
documentation/           Business requirements, technical reference, and audit records
powerbi/                 Four-page Power BI project in Import mode
python/etl/              Seven dataset ETL scripts
python/utils/            Shared validation and path helpers
sql/01_database/         Database, schema, and source-aligned tables
sql/02_loading/          Transactional UTF-8 reload
sql/03_validation/       Post-load and view reconciliation
sql/04_analysis/         Six business-question analysis files
sql/05_views/            Authoritative, supporting, and compatibility views
visuals/Architecture/    Current project architecture
visuals/ERD/             PostgreSQL structure and Power BI semantic-model diagram
visuals/PowerBI_SS/      Four verified report-page images
```

## Reproduce the clean data

Prerequisites: Python 3.12 or later, PostgreSQL with the `psql` client, and Power BI Desktop with PBIP support. Source-package ETL reproduction was checked using Python 3.14.6 and pandas 3.0.3. Run the following commands from the repository root.

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

The examples use the local `postgres` role. Replace it with your own authorized PostgreSQL role if needed, and enter the password at the prompt. Do not store credentials in the repository. Run these commands from the repository root only when setting up or deliberately rebuilding this project's database.

```powershell
psql -h localhost -U postgres -d postgres -f sql/01_database/01_create_database.sql
psql -h localhost -U postgres -d aviation_bi -f sql/01_database/02_create_schema.sql
psql -h localhost -U postgres -d aviation_bi -f sql/01_database/03_create_tables.sql
psql -h localhost -U postgres -d aviation_bi -f sql/02_loading/01_load_data.psql
psql -h localhost -U postgres -d aviation_bi -f sql/05_views/01_create_views.sql
psql -h localhost -U postgres -d aviation_bi -f sql/03_validation/01_validation.sql
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

The deprecated SQL views remain for compatibility with earlier report versions. The corrected PBIP no longer imports them. New work uses the separate population-specific financial views. Keeping the old SQL objects does not make them authoritative.

## Power BI status

Open `powerbi/Global Aviation Disruption Assessment 2026 DASHBOARD.pbip`. Keep its `.Report` and `.SemanticModel` folders beside the project file. Connect to your local `aviation_bi` database through Power BI's data-source settings, enter your own PostgreSQL credentials, and refresh the imported data.

The report has four pages:

1. Executive Overview
2. Modeled Financial Scenarios
3. Geopolitical & Operational Disruption
4. Regional Risk & Corridor Vulnerability

The semantic model separates financial populations and uses explicit origin and destination geography. Undated financial values do not change with date selections. Airspace date filtering uses closure start dates and sums complete record durations.

The calendar includes conflict context from December 2025, but cancellation and airport records start on 27 February 2026 and reroutes start on 28 February. Earlier blank operational selections mean no records are available in this snapshot, not confirmed zero disruption. Financial scenarios are undated.

Data, SQL and model checks pass within the tested scope. Manual report interaction and accessibility acceptance remain with the report author. Independent setup from a fresh Git clone on another laptop was not tested and is outside the agreed final check scope. See the audit for the verification boundaries.

### Report preview

- [Executive Overview](visuals/PowerBI_SS/01_Executive_Overview.png)
- [Modeled Financial Scenarios](visuals/PowerBI_SS/02_Modeled_Financial_Scenarios.png)
- [Geopolitical and Operational Disruption](visuals/PowerBI_SS/03_Geopolitical_Operational_Disruption.png)
- [Regional Risk and Corridor Vulnerability](visuals/PowerBI_SS/04_Regional_Corridor_Vulnerability.png)

These images show the checked report snapshot. Refresh them after the final Power BI edits; PDF and report exports are managed separately by the report author.

## Documentation

- [Business requirements and analytical framework](documentation/Global%20Aviation%20Disruption%20Assessment%20Business%20Requirements.docx)
- [Technical implementation and validation documentation](documentation/Global%20Aviation%20Disruption%20Assessment%20Technical%20Documentation.docx)
- [Descriptive executive findings and limitations](documentation/Global%20Aviation%20Disruption%20Assessment%20Executive%20Findings.docx)
- [Remediation change log](documentation/Remediation%20Change%20Log.md)
- [Architecture](visuals/Architecture/)
- [Database structure and Power BI semantic model](visuals/ERD/ERD%20-1.png)
- [Editable diagram source](visuals/ERD/ERD%20-1.svg)
- [Technical, business and combined audit](documentation/Complete%20Project%20Audit.md)
- [Audit file inventory](documentation/Audit%20File%20Inventory.csv)

The two core documents define business requirements and technical implementation. Executive findings are a separate descriptive results document, not another implementation manual. Audit evidence and correction history remain separate. Historical documents and private study notes are excluded from GitHub.

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
- Airspace date selection uses closure start date and sums whole closure durations, not hours prorated within the selected period
- Estimated passenger-to-reroute ratios describe population exposure; they are not rerouted-flight occupancy

## Authors

Dhaerya Nauni and Honey Aggarwal
