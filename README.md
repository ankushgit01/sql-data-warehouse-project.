# SQL Data Warehouse & Analytics Project

An end-to-end **MySQL 8.0** data warehouse project integrating CRM and ERP CSV sources through a **Bronze → Silver → Gold** architecture and a **star schema** for analytics.

## Objectives

- Ingest raw CRM and ERP data into Bronze.
- Clean, standardize, validate, and enrich data in Silver.
- Build analytics-ready Gold dimensions and facts.
- Apply reusable data-quality checks.
- Analyze customer behavior, product performance, and sales trends.

## Architecture

```text
CRM CSVs ─────────┐
                  ├──> Bronze (raw) ──> Silver (cleaned) ──> Gold (analytics)
ERP CSVs ─────────┘                                      ├── dim_customers
                                                        ├── dim_products
                                                        └── fact_sales
```

## Technology

- MySQL 8.0+
- SQL
- Medallion architecture
- Star schema
- CSV source data
- Git/GitHub

## Repository structure

```text
datasets/
├── source_crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
└── source_erp/
    ├── CUST_AZ12.csv
    ├── LOC_A101.csv
    └── PX_CAT_G1V2.csv

docs/
├── data_model.md
└── runbook.md

scripts/
├── init_database.sql
├── bronze/
│   ├── ddl_bronze.sql
│   └── load_bronze.sql
├── silver/
│   ├── ddl_silver.sql
│   └── proc_load_silver.sql
└── gold/
    ├── ddl_gold.sql
    └── analytics.sql

tests/
├── quality_checks_bronze.sql
├── quality_checks_silver.sql
└── quality_checks_gold.sql
```

## Execution order

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

See [docs/runbook.md](docs/runbook.md) for setup and [docs/data_model.md](docs/data_model.md) for the model.

## Engineering practices

- Raw ingestion with a dedicated Bronze layer.
- Cleansing and standardization in Silver.
- Latest-record customer deduplication with window functions.
- YYYYMMDD date conversion.
- Product validity windows.
- CRM/ERP integration.
- Sales and price business-rule validation.
- Star-schema analytical modeling.
- Referential-integrity and business-rule checks.
- Reusable analytical SQL.

## MySQL note

The project is intentionally implemented for **MySQL 8.0+**. Bronze uses `LOAD DATA LOCAL INFILE`; enable local file loading as described in the runbook.

## About

Built by **Ankush Kumar** as a Data Engineering portfolio project.
