# Global Aviation Disruption Assessment 2026

### Operational & Financial Impact of the 2026 US–Iran Conflict on Global Civil Aviation

**Python · Pandas · PostgreSQL · SQL · Power BI · ETL · Data Cleaning · Data Visualization · Business Intelligence · KPI Development**

## About the Project

The **Global Aviation Disruption Assessment 2026** is an end-to-end Data Analytics and Business Intelligence project examining the operational, financial, and geopolitical impact of the 2026 US–Iran conflict on global civil aviation.

The project integrates aviation datasets to analyze flight cancellations, rerouting, airport disruptions, airspace closures, airline losses, passenger impact, and regional vulnerability.

> **This is a simulated educational and portfolio case study and is not affiliated with ICAO.**

## Business Questions

- **Operational Disruption** — Where were cancellations, rerouting, airport disruptions, and airspace restrictions concentrated?
- **Financial Impact** — Which airlines experienced the greatest financial exposure?
- **Operational Resilience** — How did airlines perform under similar disruption conditions?
- **Geopolitical Impact** — How did military conflict events relate to aviation disruption?
- **Regional Vulnerability** — Which countries, regions, airports, and aviation corridors were most exposed?
- **Decision Support** — What insights can support aviation contingency planning?

## Data

Seven datasets sourced from Kaggle were integrated:

- `airline_losses` — Airline financial and operational impact
- `airline_losses_estimate` — Estimated daily financial exposure
- `airport_disruptions` — Airport disruption
- `airspace_closures` — Airspace restrictions
- `flight_cancellations` — Cancellations and passenger impact
- `flight_reroutes` — Rerouting, distance, fuel cost, and delays
- `conflict_events` — Geopolitical and military events

## Analytics Workflow

**Business Requirements → Data Profiling & Validation → Python ETL & Data Cleaning → PostgreSQL → SQL Analysis & KPI Development → Power BI → Insights**

### Python / ETL

- Data profiling and validation
- Duplicate and missing-value checks
- Text and whitespace validation
- Date and entity standardization
- Dataset-specific transformations
- Clean dataset generation

[ETL Scripts](python/etl/) · [Utilities](python/utils/)

### SQL Analysis

The PostgreSQL Database and SQL layers cover:

- Executive KPI analysis
- Airline financial impact
- Operational resilience
- Airport vulnerability
- Regional and country vulnerability
- Aviation corridor analysis
- Operational trends
- Geopolitical impact

## Key KPIs

- Flight Cancellations
- Passengers Affected
- Rerouted Flights
- Additional Reroute Distance
- Additional Fuel Cost
- Airport Flights Affected
- Airspace Closure Events
- Estimated Airline Loss
- Revenue Loss %
- Estimated Daily Loss
- Conflict Events
- Reroute Delay Hours

**Derived Measures:** Cancellations per Rerouted Flight · Passengers per Rerouted Flight · Fuel Cost per Rerouted Flight

## Power BI

The completed Power BI dashboard provides the visualization and reporting layer for the project's analytical outputs and KPIs.
[Power BI Files](powerbi/) · [Dashboard Screenshots](visuals/PowerBI/)

## Documentation

- [Project Documentation](documentation/Project_Documentation.pdf)
- [Final Case Study](documentation/Final_Case_Study.pdf)
- [Python Cleaning Log](documentation/Python_Cleaning_Log.pdf)
- [SQL Data Dictionary](documentation/SQL_Data_Dictionary.pdf)
- [Power BI DAX & Data Model](documentation/PowerBI_DAX_Data_Model.pdf)

Supporting visuals: [Architecture](visuals/Architecture/) · [ERD](visuals/ERD/)

## Authors

**Dhaerya Nauni & Honey Aggarwal**

## Disclaimer

This project is a simulated educational and portfolio case study. The scenario involving ICAO and the 2026 US–Iran conflict is fictional and is not affiliated with, endorsed by, commissioned by, or conducted on behalf of ICAO.

The findings should not be interpreted as official ICAO analysis or real-world operational guidance.