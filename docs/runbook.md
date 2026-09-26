# Runbook

## Prerequisites

- MySQL 8.0+
- MySQL Workbench or MySQL CLI
- Git

## 1. Clone the repository

Use GitHub's Code -> HTTPS option and clone the repository. The current repository name includes a trailing period, so use the exact clone URL shown by GitHub.

Change into the repository directory.

## 2. Verify the datasets

Confirm these six files exist:

datasets/source_crm/cust_info.csv
datasets/source_crm/prd_info.csv
datasets/source_crm/sales_details.csv
datasets/source_erp/CUST_AZ12.csv
datasets/source_erp/LOC_A101.csv
datasets/source_erp/PX_CAT_G1V2.csv

## 3. Enable local file loading

The Bronze loader uses LOAD DATA LOCAL INFILE.

Start the MySQL CLI with:

mysql --local-infile=1 -u <username> -p

## 4. Initialize the layer databases

Run from the repository root:

SOURCE scripts/init_database.sql;

This drops and recreates the bronze, silver, and gold databases. It is intentionally destructive.

## 5. Create Bronze tables and load source files

SOURCE scripts/bronze/ddl_bronze.sql;
SOURCE scripts/bronze/load_bronze.sql;

Then validate row counts:

SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL SELECT 'crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL SELECT 'crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL SELECT 'erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL SELECT 'erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL SELECT 'erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;

## 6. Build Silver

SOURCE scripts/silver/ddl_silver.sql;
SOURCE scripts/silver/proc_load_silver.sql;
CALL silver.load_silver();

The Silver procedure is rerunnable. Deployment recreates the procedure and execution refreshes the target Silver tables.

## 7. Build Gold

SOURCE scripts/gold/ddl_gold.sql;

Gold is implemented as analytical views, so no separate Gold load procedure is required.

## 8. Run quality checks

SOURCE tests/quality_checks_bronze.sql;
SOURCE tests/quality_checks_silver.sql;
SOURCE tests/quality_checks_gold.sql;

Investigate returned rows. These scripts intentionally expose data-quality violations.

## 9. Run analytics

SOURCE scripts/gold/analytics.sql;

## 10. Automated validation

GitHub Actions executes the end-to-end pipeline against MySQL 8.0 and runs tests/ci_validation.sql.

Workflow:
.github/workflows/mysql-validation.yml

## Troubleshooting

### LOAD DATA LOCAL INFILE is denied
Start the client with --local-infile=1 and verify MySQL client/server settings.

### File not found
Run MySQL from the repository root so repository-relative paths resolve correctly.

### Procedure already exists
Run SOURCE scripts/silver/proc_load_silver.sql; again. It contains DROP PROCEDURE IF EXISTS.

### Gold dimension keys are NULL
Run the Gold quality checks and investigate unmatched CRM/ERP business keys.

### CI fails
Open the failed GitHub Actions run. The failing SQL validation identifies a critical data-quality condition.
