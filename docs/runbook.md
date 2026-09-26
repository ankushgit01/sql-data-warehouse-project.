# Runbook

## Prerequisites

- MySQL 8.0+
- MySQL Workbench or MySQL CLI
- Git

## 1. Verify datasets

The repository contains:

```text
datasets/source_crm/cust_info.csv
datasets/source_crm/prd_info.csv
datasets/source_crm/sales_details.csv
datasets/source_erp/CUST_AZ12.csv
datasets/source_erp/LOC_A101.csv
datasets/source_erp/PX_CAT_G1V2.csv
```

## 2. Enable local file loading

The Bronze loader uses `LOAD DATA LOCAL INFILE`. Start the MySQL CLI with:

```bash
mysql --local-infile=1 -u <username> -p
```

If your server policy disables local loading, enable it according to your MySQL installation.

## 3. Initialize

From the repository root:

```sql
SOURCE scripts/init_database.sql;
```

> This is destructive: it drops and recreates `DataWarehouse`.

## 4. Bronze

```sql
USE DataWarehouse;
SOURCE scripts/bronze/ddl_bronze.sql;
SOURCE scripts/bronze/load_bronze.sql;
```

Then check row counts:

```sql
SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT COUNT(*) FROM bronze.crm_prd_info;
SELECT COUNT(*) FROM bronze.crm_sales_details;
SELECT COUNT(*) FROM bronze.erp_cust_az12;
SELECT COUNT(*) FROM bronze.erp_loc_a101;
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2;
```

## 5. Silver

```sql
SOURCE scripts/silver/ddl_silver.sql;
SOURCE scripts/silver/proc_load_silver.sql;
CALL silver.load_silver();
```

The procedure is rerunnable because it drops and recreates itself during deployment and truncates target Silver tables before loading.

## 6. Gold

```sql
SOURCE scripts/gold/ddl_gold.sql;
```

Gold is implemented as analytical views, so there is no separate Gold load step.

## 7. Quality checks

```sql
SOURCE tests/quality_checks_bronze.sql;
SOURCE tests/quality_checks_silver.sql;
SOURCE tests/quality_checks_gold,sql;
```

Investigate returned rows. The validation scripts are designed to expose unexpected records rather than hide them.

## 8. Analytics

```sql
SOURCE scripts/gold/analytics.sql;
```

The analytics script covers overall KPIs, monthly sales, top products, categories, top customers, country distribution, and shipping status.

## Troubleshooting

### `LOAD DATA LOCAL INFILE` is denied
Use a client started with `--local-infile=1` and check the server/client configuration.

### File not found
Run the MySQL client from the repository root so the relative paths resolve correctly, or replace the paths with absolute paths.

### Procedure already exists
Run `SOURCE scripts/silver/proc_load_silver.sql;` again. It contains `DROP PROCEDURE IF EXISTS`.

### Gold rows have NULL dimension keys
Run the Gold referential-integrity check and investigate unmatched CRM/ERP business keys.
