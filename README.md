# Global Aviation Disruption Assessment 2026
### Operational & Financial Impact of the 2026 US–Iran Conflict on Global Civil Aviation

**Python · Pandas · PostgreSQL · SQL · Power BI · DAX · Data Analytics · ETL · Data Cleaning · Data Visualization · Business Intelligence · KPI Development · Git · GitHub**

---

## About the Project

The **Global Aviation Disruption Assessment 2026** is an end-to-end Data Analytics and Business Intelligence project examining how geopolitical conflict affected global civil aviation.

The project integrates operational, financial, and geopolitical datasets to assess flight cancellations, rerouting, airport disruptions, airspace closures, airline financial losses, passenger impact, and regional vulnerability. The analysis transforms fragmented aviation data into **decision-ready insights** for understanding disruption, financial exposure, operational resilience, and crisis preparedness.

> **This is a simulated educational and portfolio case study and is not affiliated with ICAO.**

## Business Questions

The analysis focuses on six key areas:

- **Operational Disruption** — Where were cancellations, rerouting, airport disruptions, and airspace restrictions concentrated?
- **Financial Impact** — Which airlines experienced the greatest financial exposure?
- **Operational Resilience** — How did airlines perform under similar disruption conditions?
- **Geopolitical Impact** — How did military conflict events relate to aviation disruption over time?
- **Regional Vulnerability** — Which countries, regions, airports, and aviation corridors were most exposed?
- **Decision Support** — What insights can support future aviation contingency planning?

## Data

Seven datasets sourced from Kaggle are integrated into the analytical workflow:

| Dataset | Focus |
| `airline_losses` | Airline financial and operational impact |
| `airline_losses_estimate` | Estimated daily financial exposure |
| `airport_disruptions` | Airport disruption |
| `airspace_closures` | Airspace restrictions |
| `flight_cancellations` | Cancellations and passenger impact |
| `flight_reroutes` | Rerouting, distance, fuel cost and delays |
| `conflict_events` | Geopolitical and military events |

## Analytics Workflow

Business Requirements  
↓  
Data Profiling & Validation  
↓  
Python ETL & Data Cleaning  
↓  
PostgreSQL Database  
↓  
SQL Analysis & KPI Development  
↓  
Power BI Dashboard

### Python / ETL

The Python layer performs:
- Data profiling
- Duplicate and missing-value checks
- Text and whitespace validation
- Date standardization
- Entity standardization
- Dataset-specific transformations
- Clean dataset generation

ETL scripts: [`python/etl/`](python/etl/)  
Reusable utilities: [`python/utils/`](python/utils/)

### PostgreSQL / SQL

The PostgreSQL and SQL layers provide the foundation for data validation, analytical queries, KPI calculations, and reporting.
The analysis covers:

- Executive KPI analysis
- Airline financial impact
- Operational resilience
- Airport vulnerability
- Regional and country vulnerability
- Aviation corridor analysis
- Operational disruption trends
- Geopolitical impact

## Key KPIs

The analytical framework includes:

- Total Flight Cancellations
- Passengers Affected
- Total Rerouted Flights
- Additional Reroute Distance
- Additional Fuel Cost
- Airport Flights Affected
- Airport Disruption Hours
- Airspace Closure Events
- Airspace Closure Hours
- Airspace Flights Affected
- Estimated Airline Loss
- Revenue Loss %
- Estimated Daily Loss
- Conflict Events
- Military Events
- Reroute Delay Hours

### Derived Measures

- **Cancellations per Rerouted Flight**
- **Passengers per Rerouted Flight**
- **Fuel Cost per Rerouted Flight**

## Power BI

The dashboards are built on the completed data preparation, PostgreSQL database, SQL analysis, and KPI framework.

## Documentation

Detailed project documentation is available in [`docs/`](docs/):

## Authors: **Dhaerya Nauni & Honey Aggarwal**

## Disclaimer

This project is a simulated educational and portfolio case study.

The scenario involving ICAO and the 2026 US–Iran conflict is fictional and is not affiliated with, endorsed by, commissioned by, or conducted on behalf of ICAO.

The findings should not be interpreted as official ICAO analysis or real-world operational guidance.
