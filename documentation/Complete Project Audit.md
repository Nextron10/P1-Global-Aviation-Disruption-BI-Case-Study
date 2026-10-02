# Complete Project Audit

Audit date: 1 October 2026; documentation finalized 2 October 2026. Status: **Needs human report acceptance**. Repository inspection, live data reconciliation, SQL execution, model tests and proposed-package ETL reproduction are complete within the tested scope. Manual report interactions and accessibility remain separate. Fresh-laptop clone testing is excluded from the agreed final check scope, not passed. No database objects, raw files, commits or remote publication were changed during this audit.

## 1 Executive summary

The source-to-database foundation is reproducible and reconciled. All seven live PostgreSQL tables match all clean CSV values, including Unicode text. All six SQL analyses and post-load validation execute in read-only mode. All 33 Power BI measures execute; metadata checks find no broken relationship endpoints or checked visual field references. Seven ETL scripts reproduce the clean outputs byte-for-byte, including in a separate folder.

One material SQL comparison defect was corrected: event/non-event means previously included dates outside the operational snapshot. The ERD, architecture and both authoritative Word documents were aligned with the current model. Document tables, figure proportions and page numbering were corrected. The reopened model and representative filter checks pass, and saved-state confirmation was completed. The cancellation-reasons table displays its full counts without horizontal scrolling. Four existing native report images are checked snapshots. Descriptive executive findings are independently recomputed and documented separately. Final Word layout is checked through native page images without PDF creation. The report author handles final Power BI screenshots and exports. Manual interaction acceptance and a fresh Git clone are not implied passes.

## 2 Repository architecture map

`Kaggle snapshot -> seven raw CSVs -> seven Python ETL scripts and helpers -> seven clean UTF-8 CSVs -> PostgreSQL aviation_bi.aviation -> nine SQL views and six analyses -> PBIP Import model -> four report pages -> documentation and findings`.

Raw CSVs are source evidence. Python and SQL define executable transformations. PBIP definitions are the report/model authority. Clean data and rendered images are generated outputs. Two Word documents define requirements and implementation; historical Word documents are ignored supporting references, not current authority. Local `.venv`, `.pbi`, `__pycache__`, Git internals and QA files are generated/local infrastructure rather than analytical source files.

The file inventory records paths, sizes, hashes and inspection classifications. New outputs created by this audit are included when the inventory is refreshed. File inspection does not mean every possible runtime state was tested.

## 3 End-to-end data lineage

All seven raw/clean row counts reconcile. Conflict cleaning retains source location and derived nullable country. The estimate table applies only the three documented airline aliases. Direct operational imports retain cancellation and reroute detail. Financial views preserve summary and estimate populations separately. The route view aggregates dated geography combinations and retains cancellation and reroute measures separately.

Airport and airspace exposure are separate reported populations, not one deduplicated flight population. Undated financial data is not attached to the date dimension. Model geography uses separate entity, origin and destination roles. No direct fact-to-fact join is introduced.

## 4 Data audit

| Source | Rows raw / clean / live | Grain and authority | Date scope |
|---|---|---|---|
| airline_losses | 70 / 70 / 70 | One modeled-summary airline; summary loss and counts | Undated |
| airline_losses_estimate | 35 / 35 / 35 | One modeled-estimate airline; daily exposure | Undated |
| airport_disruptions | 227 / 227 / 227 | One simulated airport disruption record | 27 February–7 June 2026 |
| airspace_closures | 84 / 84 / 84 | One simulated closure record | Starts 28 February–7 June; ends through 17 June 2026 |
| conflict_events | 82 / 82 / 82 | One simulated contextual event | 15 December 2025–8 June 2026 |
| flight_cancellations | 2,200 / 2,200 / 2,200 | One simulated cancellation record; operational passengers | 27 February–7 June 2026 |
| flight_reroutes | 1,500 / 1,500 / 1,500 | One simulated reroute record; distance, fuel and delay | 28 February–7 June 2026 |

No exact duplicate rows or negative numerical values were found. There are no repeated date/airline/flight-number keys in the two detailed flight files. The only clean nulls are 42 unresolved conflict-country values. Those records are retained. Candidate uniqueness in this snapshot is not proof of a globally unique flight identifier.

The financial union is 73 airlines: 32 overlap, three estimate-only and 38 summary-only. Summary cancellations 6,030 versus detailed records 2,200, and summary reroutes 4,539 versus detailed records 1,500, remain distinct populations. No unsupported reconciliation or deletion was performed.

## 5 Python and ETL audit

All eight Python files parse. Expected schemas, strict dates, nonnegative checks, row preservation, explicit imports and main entry points are present. Every ETL output matches its existing clean CSV bytes. The full proposed public package was copied to a separate temporary folder and all seven scripts ran using Python 3.14.6 and pinned pandas 3.0.3, with byte-equal outputs. This reuses an existing environment; installing dependencies and rebuilding the database from a fresh Git clone on Honey's laptop remains untested.

No confirmed current-data transformation defect requires a Python rewrite. The conflict script's description incorrectly said source text was verbatim, although text trimming occurs first. Its description and dictionary wording now state whitespace normalization; executable Python behavior is unchanged. Validation helpers are adequate for the fixed snapshot but do not constitute a general production ingestion framework.

## 6 SQL audit

The schema has seven source-aligned analytical tables, appropriate required-field and numerical checks, and no declared primary/foreign keys. Loading uses psql client commands, explicit columns, UTF-8, error-stop behavior and one transaction. The loader and rebuild DDL were inspected but deliberately not executed during this audit.

Live connection: `postgres / aviation_bi / transaction_read_only=on`. Seven complete table extracts reconcile to clean CSVs without changing database objects. Post-load validation and all six analysis scripts executed successfully. Count, financial coverage and route-preservation checks pass. Execution is supplemented by independent source recomputation; it is not treated as proof of analytical correctness.

The temporal analysis now compares only the shared 100-day operational snapshot window, 28 February–7 June 2026. It returns 12 military-event dates and 88 other dates, with mean cancellation records 21.08 and 22.07 respectively. Wider context output shows NULL outside each operational source range. These bounds do not establish complete real-world observation or causality.

## 7 Power BI and DAX audit

The current PBIP contains 22 tables, 33 measures, 35 relationships and four pages. Ten imported sources feed ten dimensions and two disconnected helper tables. One closure end-date relationship is inactive; the active date relationship selects closure start dates. All 33 measures execute. The exposure selector is blank when no single factor is selected, and returns the expected separate exposures when selected.

Metadata validation passes for 86 JSON files and 212 checked field references. Representative DAX tests pass for undated financial behavior, airline propagation, entity country, origin/destination geography, severity, estimate-only airlines and empty denominators. These are engine/context tests, not proof that every visible interaction or keyboard path works.

Controls independently confirmed: cancellations 2,200; passengers 575,710; reroutes 1,500; extra distance 2,201,390 km; detailed extra fuel USD 11,658,572.59; delay 4,706.30 hours; summary loss USD 21,414,330,000; estimated daily loss USD 48,840,000; estimate fuel USD 27,606,000; airport exposure 35,844; airspace exposure 35,502; events 82; military events 18.

Estimated passenger/reroute is a population exposure ratio, not aircraft occupancy or passengers specifically on rerouted flights. Closure hours are whole durations of closures selected by start date, not hours prorated into the selected period. Final labels/tooltips should communicate these definitions.

## 8 Documentation audit

The two existing authoritative Word files were revised, not replaced with extra overlapping manuals. Old model counts, import descriptions, deprecated-source usage and pending-defect descriptions were corrected. Full measure and relationship catalogs were added to the technical document. Shared snapshot coverage, passenger-ratio meaning, closure-date behavior and current acceptance limits were recorded.

The old ERD's invented IDs and columns were removed. The editable SVG and PNG show actual PostgreSQL columns and types plus semantic relationship mappings. The final business requirements, technical documentation, separate executive findings and private study guide use consistent Word formatting and are inspected as native page images. No PDF is created by this documentation pass. Historical executive claims remain unverified and unpublished; current descriptive findings were recomputed independently. Earlier Word files and pre-finalization copies remain recoverable in the ignored archive. The Honey guide and old screenshot PDF remain deleted from their public paths. Reproduction instructions are in the technical document; README links resolve. Date coverage distinguishes unavailable observations from measured zero; the user-reported Desktop availability message still needs the author's saved-appearance check.

## 9 Cross-system consistency audit

Raw -> clean -> live table equality passes. Operational measures and corridor totals match their detailed sources. Summary and estimate measures use separate interfaces and correct populations. Geography and severity dimensions use distinct roles/vocabularies. The diagram is generated from DDL and TMDL rather than documentation assumptions.

The wider geopolitical view remains a compatibility/context source with zero-filled legacy counts; the corrected analysis masks out-of-source-range operational values and restricts comparative means. Do not publish those legacy zero-filled values as verified zero disruption outside source coverage.

## 10 Professional BI and portfolio assessment

This is suitable as a static BI case study once final acceptance and publication artifacts are complete. Its strongest interview evidence is population reconciliation, traceable metrics, clean/live equality and preserving source limitations. It should not claim live monitoring, ICAO endorsement, resilience effectiveness, forecasting or causal conflict effects. A wholesale redesign, invented keys or enterprise orchestration is not justified by this dataset.

## 11 Complete findings table

| ID | Severity | Status | Component/file or object | Finding and evidence | Impact | Correction or recommendation |
|---|---|---|---|---|---|---|
| F01 | HIGH | CONFIRMED — corrected and live-tested | sql/04_analysis/04_geopolitical_temporal_analysis.sql | Wider calendar diluted event/non-event means with out-of-range zeros | Could reverse interpretation | Restrict comparison to shared snapshot window; mask out-of-range contextual values |
| F02 | HIGH | CONFIRMED — corrected and visually checked | Technical Documentation section 10 | Old counts: 20 tables/26 relationships; current 22/35 | Documentation/model mismatch | Counts, sources, defect history and full catalogs updated |
| F03 | HIGH | CONFIRMED — corrected and visually checked | visuals/ERD/ERD -1.png and .svg | Earlier image showed nonexistent keys/columns | Misrepresented database and model | Actual column/type and relationship mappings verified |
| F04 | HIGH | CONFIRMED — resolved | Open Power BI state | After reopening and saving, Desktop reports hasUnsavedChanges=false; source files have updated save timestamps | Earlier saved-state uncertainty is resolved | No further repeated saving is required |
| F05 | HIGH | NEEDS VERIFICATION | Four report pages | Engine filter tests do not test all clicks, highlights or keyboard paths | Interaction/accessibility failures may remain | Manual acceptance across all four pages |
| F06 | MEDIUM | CONFIRMED — clarified in documentation | Estimated Passengers per Estimated Reroute | Estimate passengers are not reroute-specific; El Al has 3,980 passengers and zero reroutes | Ratio could be mistaken for occupancy | Explain as population exposure; verify final tooltip wording |
| F07 | MEDIUM | CONFIRMED — clarified in documentation | Airspace Closure Hours / Closure Start Date | Date filters select starts and whole durations | Could be mistaken for within-period hours | Document start-date cohort and full-duration aggregation |
| F08 | HIGH | CONFIRMED — remaining | Git untracked semantic files/new visual | Required model dependencies are untracked | Friend's clone will miss corrected objects unless included | Review and include all dependencies in the user's release commit |
| F09 | MEDIUM | CONFIRMED — documentation corrected | visuals/PowerBI_SS; Executive Findings.docx | Existing page images are checked snapshots; findings recomputed; final Word layout inspected | Later Desktop edits are not represented automatically by saved images | Author refreshes screenshots and performs final exports; keep human report acceptance separate |
| F10 | MEDIUM | NEEDS VERIFICATION — excluded from final scope | Fresh-clone setup | Proposed-package ETL passes in a separate folder; no remote clone, new dependency install or database rebuild tested | Full fresh-laptop setup remains unproven | Retain this limitation; do not call the source-copy check a fresh-clone pass |
| F11 | LOW | CONFIRMED — corrected | python/etl/05_conflict_events_etl.py:1 and Technical Documentation source_location definition | Source text is trimmed before preservation, despite old verbatim wording | Description overstated byte-level preservation | Corrected description only; no transformation change |
| F12 | MEDIUM | CONFIRMED — corrected | Historical documents and old Honey-guide references | User approved private archival; guide remains deleted from public path | Stale references could mislead a new contributor | Old Word documents retained in ignored _archive; reproduction instructions consolidated in Technical Documentation |
| F13 | LOW | CONFIRMED — corrected | Core Word revision tables and technical architecture figure | Rendered tables overflowed; image proportions were distorted | Poor readability and lost text | Fit tables to page width, preserve image proportions, rerender and inspect |
| F14 | LOW | CONFIRMED — corrected and visually checked | Geopolitical page: Primary Reasons for Flight Cancellations table | Long measure caption caused horizontal scrolling and clipped counts | Full values were not visible initially | Shortened only the display caption to Records; same measure; native capture shows full counts and no horizontal scrollbar |
| F15 | MEDIUM | CONFIRMED — corrected | Three public Word documents and private guide | PDF-based rendering was unavailable; native Word page images provide layout inspection without PDFs | Earlier layout evidence was incomplete | Use native page images, correct footer and table pagination, and inspect final pages |

## 12 Critical issues

No remaining CRITICAL defect was demonstrated in tested data/calculation paths. This is not proof that every runtime or deployment state is flawless.

## 13 High-priority issues

Complete manual interactions and include required untracked dependencies in the user's commit. Word documentation is finalized. The proposed package contains all current PBIP dependencies, but a Git clone includes only committed files. Do not release on numeric checks alone.

## 14 Medium and low issues

Verify passenger-ratio and closure-date tooltips and report accessibility. Fresh-laptop reproduction is excluded from the agreed final scope, not verified. Source-location normalization and document layout are corrected. Keep supporting views that serve SQL analysis or dimension construction; do not delete them merely because a visual does not directly reference them.

## 15 Strong parts of the project

Immutable source evidence; deterministic ETL; row preservation; complete clean/live equality; explicit population contracts; UTF-8 repair without business-value changes; separate financial sources; role-specific geography/severity; explicit DAX and inspectable PBIP metadata.

## 16 Missing and weak areas

No shared flight identifier or verified real-world coverage. Forty-two conflict countries are unresolved. Financial sources are undated. Manual report/accessibility acceptance remains open. Fresh-clone reproduction was not tested and is outside the agreed final scope. Word layout is checked; descriptive findings are recomputed and written. Unsupported causal or mitigation findings are excluded.

## 17 Overall project score

Provisional portfolio-readiness assessment: **78/100**, not certification. Rubric: engineering/reconciliation 23/25; analytical definitions 21/25; BI validation 16/20; documentation alignment 11/15; release reproducibility 7/15. The score is reviewer judgment; unresolved acceptance checks reduce readiness and are not arithmetic error percentages.

## 18 Recommended remaining order

1. On each report page, test populated and empty selections, cross-filtering, highlights and resets. Confirm default totals return after clearing selections and check the saved date-availability message.
2. Confirm that dates do not change undated financial values; origin and destination filters have their labelled meaning. Check severity, passenger-exposure and closure-start-date tooltips.
3. Test keyboard navigation, accessible names, focus order and readable contrast. Engine tests and screenshots do not prove accessibility.
4. The report author refreshes final screenshots and creates any required Power BI or PDF exports. This documentation pass performs neither export.
5. Review all required source dependencies, editable diagrams, final documents and current images for the user's release commit. Exclude credentials and ignored private/archive/cache/environment files. Fresh-clone testing and password rotation are not remaining acceptance gates in the agreed scope; ordinary credential hygiene still applies.
6. Publish only after the user's acceptance. No commit, push, database rebuild or publication was performed by this audit.

## 19 Questions and unknowns requiring input

The user approved keeping old documents in an ignored archive and owns final report exports. The main PBIP was reopened, saved and model-tested on 1 October; repeated saving is not requested. Manual interaction/accessibility acceptance and the saved appearance of the user-reported date message remain separate author checks. Fresh-laptop testing is excluded from final scope. Current release files and 280 readable reachable history blobs had no matches in the applied credential patterns; this is not a guarantee that every possible secret is absent. The private guide is ignored and does not invent employment history. No password is recorded in this report or project files.
