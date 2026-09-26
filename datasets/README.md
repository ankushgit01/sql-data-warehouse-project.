# Source datasets

The pipeline expects six source CSV files.

## CRM

- `datasets/source_crm/cust_info.csv`
- `datasets/source_crm/prd_info.csv`
- `datasets/source_crm/sales_details.csv`

## ERP

- `datasets/source_erp/CUST_AZ12.csv`
- `datasets/source_erp/LOC_A101.csv`
- `datasets/source_erp/PX_CAT_G1V2.csv`

Keep these filenames unchanged unless `scripts/bronze/load_bronze.sql` is updated as well.
