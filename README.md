# SQL Data Warehouse & Analytics Project

An end-to-end **MySQL 8.0** data warehouse project that integrates CRM and ERP CSV sources using a **Bronze → Silver → Gold** architecture and a **star schema** for analytics.

## Project objectives

- Ingest raw CRM and ERP data into a Bronze layer.
- Clean, standardize, validate, and enrich data in Silver.
- Build analytics-ready Gold dimensions and facts.
- Apply reusable data-quality checks.
- Answer business questions around customer behavior, product performance, and sales trends.

## Architecture

```text
CRM CSVs ─────────┐
                  ├──> Bronze (raw) ──> Silver (cleaned) ──> Gold (analytics)
ERP CSVs ─────────┘                                      ├── dim_customers
                                                        ├── dim_products
                                                        └── fact_sales
```

## Technology stack

| Component | Technology |
|---|---|
| Database | MySQL 8.0+ |
| Language | SQL |
| Architecture | Medallion (Bronze / Silver / Gold) |
| Modeling | Star schema |
| Source format | CSV |
| Version control | Git / GitHub |

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

## Data sources

### CRM
- `cust_info.csv` — customer master data.
- `prd_info.csv` — product master and product history.
- `sales_details.csv` — sales transactions.

### ERP
- `CUST_AZ12.csv` — customer demographic attributes.
- `LOC_A101.csv` — customer location.
- `PX_CAT_G1V2.csv` — product category and subcategory.

## End-to-end execution

Run the scripts in this order:

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

See [docs/runbook.md](docs/runbook.md) for setup, loading, validation, and troubleshooting.

## Engineering practices demonstrated

- Raw-source ingestion with a dedicated Bronze layer.
- Data cleansing and standardization in Silver.
- Latest-record deduplication for customers.
- Date conversion from integer source dates.
- Product validity windows using window functions.
- CRM/ERP customer and location integration.
- Business-rule correction for inconsistent sales and prices.
- Star-schema dimensions and fact modeling.
- Referential-integrity and business-rule validation.
- Reusable SQL analytics on Gold views.

## MySQL note

The project is intentionally implemented for **MySQL 8.0+**. The Bronze load uses `LOAD DATA LOCAL INFILE`. Your MySQL client/server must allow local file loading. See the runbook before the first load.

## About

Built by **Ankush Kumar** as a hands-on Data Engineering portfolio project.
