/*
============================================================
Load Bronze Layer
============================================================
Uses MySQL LOAD DATA LOCAL INFILE.

Run the MySQL client from the repository root so the relative
paths resolve correctly.

Source-date handling:
- CRM customer create dates are loaded through a user variable.
- MySQL strict mode rejects the source value 0000-00-00 when
  loading directly into a DATE column, so that known source
  anomaly is converted to NULL during ingestion.
============================================================
*/

TRUNCATE TABLE bronze.crm_cust_info;
LOAD DATA LOCAL INFILE 'datasets/source_crm/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    @cst_create_date
)
SET cst_create_date =
    CASE
        WHEN NULLIF(TRIM(@cst_create_date), '') IS NULL
          OR TRIM(@cst_create_date) = '0000-00-00'
            THEN NULL
        ELSE STR_TO_DATE(TRIM(@cst_create_date), '%Y-%m-%d')
    END;

TRUNCATE TABLE bronze.crm_prd_info;
LOAD DATA LOCAL INFILE 'datasets/source_crm/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE bronze.crm_sales_details;
LOAD DATA LOCAL INFILE 'datasets/source_crm/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE bronze.erp_cust_az12;
LOAD DATA LOCAL INFILE 'datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE bronze.erp_loc_a101;
LOAD DATA LOCAL INFILE 'datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE 'datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
