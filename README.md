# SQL Data Warehouse & Analytics Project

[![MySQL Warehouse Validation](https://github.com/ankushgit01/sql-data-warehouse-project./actions/workflows/mysql-validation.yml/badge.svg)](https://github.com/ankushgit01/sql-data-warehouse-project./actions/workflows/mysql-validation.yml)

An end-to-end MySQL 8.0+ data warehouse project integrating CRM and ERP CSV sources through a Bronze -> Silver -> Gold architecture and a star-schema-style analytical layer.

## Project objectives

- Ingest raw CRM and ERP source data into Bronze.
- Clean, standardize, and reconcile data in Silver.
- Build analytics-ready Gold dimensions and fact data.
- Validate data quality at every layer.
- Answer business questions about customers, products, sales, and shipping performance.
- Automatically validate the pipeline with GitHub Actions.

## Architecture

CRM CSVs
  |
  +--> bronze --> silver --> gold
                              +--> dim_customers
                              +--> dim_products
                              +--> fact_sales

MySQL design note: MySQL uses databases as the layer namespaces in this project. `bronze`, `silver`, and `gold` are separate databases rather than nested schemas.

## Technology stack

| Component | Technology |
|---|---|
| Database | MySQL 8.0+ |
| Language | SQL |
| Architecture | Medallion (Bronze / Silver / Gold) |
| Modeling | Star-schema-style analytical model |
| Source format | CSV |
| Version control | Git / GitHub |
| CI validation | GitHub Actions |

## Repository structure

```
datasets/
  source_crm/
    cust_info.csv
    prd_info.csv
    sales_details.csv
  source_erp/
    CUST_AZ12.csv
    LOC_A101.csv
    PX_CAT_G1V2.csv

docs/
  data_model.md
  data_quality.md
  runbook.md

scripts/
  init_database.sql
  bronze/
    ddl_bronze.sql
    load_bronze.sql
  silver/
    ddl_silver.sql
    proc_load_silver.sql
  gold/
    ddl_gold.sql
    analytics.sql

tests/
  ci_validation.sql
  quality_checks_bronze.sql
  quality_checks_silver.sql
  quality_checks_gold.sql

.github/
  workflows/
    mysql-validation.yml
```

## Source data

CRM:
- `cust_info.csv` — customer master data.
- `prd_info.csv` — product master/history data.
- `sales_details.csv` — sales transaction data.

ERP:
- `CUST_AZ12.csv` — customer demographics.
- `LOC_A101.csv` — customer location.
- `PX_CAT_G1V2.csv` — product category metadata.

## Pipeline

### Bronze

Stores source data with minimal structural transformation using `LOAD DATA LOCAL INFILE`.

The CRM customer source contains the MySQL-incompatible zero date `0000-00-00`. The loader converts that known source anomaly to `NULL` so the pipeline works in MySQL strict mode without inventing a date.

### Silver

Applies data cleansing and standardization, including:

- whitespace cleanup
- customer deduplication
- status and gender normalization
- product category/key normalization
- product validity-window derivation
- YYYYMMDD-to-DATE conversion
- sales/price reconciliation
- ERP identifier normalization
- ERP customer/location/category deduplication
- future birth-date protection

### Gold

Creates analytics-ready views:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

The product dimension exposes the latest row for each product business key. Historical product versions remain available in Silver.

## Execution order

Run from the repository root:

1. `scripts/init_database.sql`
2. `scripts/bronze/ddl_bronze.sql`
3. `scripts/bronze/load_bronze.sql`
4. `scripts/silver/ddl_silver.sql`
5. `scripts/silver/proc_load_silver.sql`
6. `CALL silver.load_silver();`
7. `scripts/gold/ddl_gold.sql`
8. `tests/quality_checks_bronze.sql`
9. `tests/quality_checks_silver.sql`
10. `tests/quality_checks_gold.sql`
11. `scripts/gold/analytics.sql`

See `docs/runbook.md` for exact setup instructions.

## Data quality

The project includes:

- Bronze source/key checks
- Silver cleansing and business-rule checks
- Gold referential-integrity checks
- Automated CI validation that fails when critical quality rules are violated
- Explicit reporting of known source-date anomalies instead of silently hiding them

See `docs/data_quality.md` for the rules and handling strategy.

## Analytics included

- overall warehouse KPIs
- monthly sales trends
- top products by revenue
- revenue by category
- top customers by lifetime revenue
- customer distribution by country
- shipping performance
- data-quality mapping visibility

## Reproducibility

The Bronze loader uses repository-relative CSV paths and `LOAD DATA LOCAL INFILE`. Run the MySQL client from the repository root with local file loading enabled.

GitHub Actions runs the complete pipeline against MySQL 8.0 and executes the critical CI quality checks on pushes and pull requests to `main`.

## Design limitations

The Gold surrogate keys are generated with `ROW_NUMBER()`, so they are deterministic for the current source snapshot but are not persistent warehouse keys across arbitrary source changes. This project intentionally models a reproducible latest-snapshot portfolio pipeline rather than a production SCD/metadata platform.

## About

Built by Ankush Kumar as a Data Engineering portfolio project.
