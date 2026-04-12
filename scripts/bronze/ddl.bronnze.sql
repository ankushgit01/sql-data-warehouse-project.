/*
============================================================
Load Data into Bronze Layer (Raw Data Ingestion)
============================================================

Script Purpose:
    This script loads raw CSV data into Bronze layer tables.
    It truncates existing data and reloads fresh data from source files.

    Source Systems:
    - CRM (Customer, Product, Sales)
    - ERP (Customer, Location, Product Category)

    Data is loaded using MySQL's LOAD DATA INFILE for high performance.

WARNING:
    - All existing data in Bronze tables will be deleted (TRUNCATE).
    - Ensure CSV files are placed in the correct MySQL upload directory.
    - Ensure FILE privilege is enabled for LOAD DATA INFILE.
*/

-- =============================================
-- 📥 Load CRM Data
-- =============================================

-- Customer Info
TRUNCATE TABLE bronze.crm_cust_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Product Info
TRUNCATE TABLE bronze.crm_prd_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Sales Details
TRUNCATE TABLE bronze.crm_sales_details;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =============================================
-- 📥 Load ERP Data
-- =============================================

-- ERP Customer
TRUNCATE TABLE bronze.erp_cust_az12;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ERP Location
TRUNCATE TABLE bronze.erp_loc_a101;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ERP Product Category
TRUNCATE TABLE bronze.erp_px_cat_g1v2;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- =============================================
-- ✅ Data Load Completed
-- =============================================
