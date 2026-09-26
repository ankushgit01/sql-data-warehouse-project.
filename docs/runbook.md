# Runbook

## Prerequisites

- MySQL 8.0+
- MySQL Workbench or MySQL CLI
- Git

## 1. Clone the repository

Use GitHub's **Code -> HTTPS** option and clone the repository.

> Note: the GitHub repository currently has a trailing period in its name. GitHub shows the exact clone URL; use that URL until the repository is manually renamed.

Change into the repository directory.

## 2. Verify the datasets

Confirm these six files exist:

```
datasets/source_crm/cust_info.csv
datasets/source_crm/prd_info.csv
datasets/source_crm/sales_details.csv
datasets/source_erp/CUST_AZ12.csv
datasets/source_erp/LOC_A101.csv
datasets/source_erp/PX_CAT_G1V2.csv
```

## 3. Enable local file loading

The Bronze loader uses `LOAD DATA LOCAL INFILE`.

Start the MySQL CLI with:

```bash
mysql --local-infile=1 -u <username> -p
```

Your MySQL server must also allow local infile loading.

## 4. Initialize the layer databases

Run from the repository root:

```sql
SOURCE scripts/init_database.sql;
```

This drops and recreates the `bronze`, `silver`, and `gold` databases. It is intentionally destructive.

## 5. Create Bronze tables and load source files

```sql
SOURCE scripts/bronze/ddl_bronze.sql;
SOURCE scripts/bronze/load_bronze.sql;
```

Then validate row counts:

```sql
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL SELECT 'crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL SELECT 'crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL SELECT 'erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL SELECT 'erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL SELECT 'erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;
```

Expected source snapshot row counts are approximately:

- CRM customers: 18.5k
- CRM products: 397
- CRM sales: 60.4k
- ERP customers: 18.5k
- ERP locations: 18.5k
- ERP categories: 37

Exact counts should be taken from the checked-in CSV files rather than hard-coded as a test.

## 6. Build Silver

```sql
SOURCE scripts/silver/ddl_silver.sql;
SOURCE scripts/silver/proc_load_silver.sql;
CALL silver.load_silver();
```

The Silver procedure is rerunnable: deployment recreates the procedure and execution refreshes the target Silver tables.

## 7. Build Gold

```sql
SOURCE scripts/gold/ddl_gold.sql;
```

Gold is implemented as analytical views, so no separate Gold load procedure is required.

## 8. Run quality checks

```sql
SOURCE tests/quality_checks_bronze.sql;
SOURCE tests/quality_checks_silver.sql;
SOURCE tests/quality_checks_gold.sql;
```

Investigate returned rows. These scripts intentionally expose data-quality violations.

## 9. Run analytics

```sql
SOURCE scripts/gold/analytics.sql;
```

## 10. Automated validation

GitHub Actions executes the end-to-end pipeline against MySQL 8.0 and runs `tests/ci_validation.sql`.

Workflow:

`.github/workflows/mysql-validation.yml`

## Troubleshooting

### LOAD DATA LOCAL INFILE is denied

Start the client with `--local-infile=1` and verify the MySQL server has `local_infile` enabled.

### Zero-date error

The checked-in CRM customer source contains `0000-00-00`. The Bronze loader catches this known source anomaly and stores it as `NULL`.

### File not found

Run MySQL from the repository root so repository-relative paths resolve correctly.

### Procedure already exists

Run `SOURCE scripts/silver/proc_load_silver.sql;` again. It contains `DROP PROCEDURE IF EXISTS`.

### Gold dimension keys are NULL

Run the Gold quality checks and investigate unmatched CRM/ERP business keys.

### CI fails

Open the failed GitHub Actions run and inspect the failing SQL step. The CI procedure deliberately fails only on critical data-quality violations; known source-date anomalies are reported separately.
