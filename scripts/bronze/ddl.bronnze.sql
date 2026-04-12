/*
============================================================
Create Bronze Layer Tables (Raw Data Storage)
============================================================

Script Purpose:
    This script creates tables in the Bronze layer to store raw data
    from CRM and ERP source systems. These tables are designed to
    hold unprocessed data as-is for further transformation.

    Source Systems:
    - CRM (Customer, Product, Sales)
    - ERP (Customer, Location, Product Category)

Notes:
    - Minimal constraints are applied (raw ingestion layer).
    - Data types are kept flexible to match source data.

WARNING:
    - Existing tables will be dropped if they already exist.
    - All previous data will be permanently deleted.
*/

-- =============================================
-- 🧹 Drop Existing Tables (if any)
-- =============================================

DROP TABLE IF EXISTS bronze.crm_cust_info;
DROP TABLE IF EXISTS bronze.crm_prd_info;
DROP TABLE IF EXISTS bronze.crm_sales_details;
DROP TABLE IF EXISTS bronze.erp_loc_a101;
DROP TABLE IF EXISTS bronze.erp_cust_az12;
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- =============================================
-- 📥 CRM Tables
-- =============================================

-- Customer Info
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

-- Product Info
CREATE TABLE bronze.crm_prd_info (
    prd_id INT, 
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

-- Sales Details
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- =============================================
-- 📥 ERP Tables
-- =============================================

-- Location Data
CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

-- Customer Data
CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(50),
    ddate DATE,
    gen VARCHAR(50)
);

-- Product Category
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);

-- =============================================
-- ✅ Tables Created Successfully
-- =============================================
