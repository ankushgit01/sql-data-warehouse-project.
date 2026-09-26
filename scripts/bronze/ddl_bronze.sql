/*
============================================================
Create Bronze Layer Tables
============================================================
Bronze = raw source data.
Target: MySQL 8.0+
Database: bronze
============================================================
*/

CREATE TABLE IF NOT EXISTS bronze.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(100),
    cst_lastname VARCHAR(100),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

CREATE TABLE IF NOT EXISTS bronze.crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(150),
    prd_cost DECIMAL(18,2),
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE IF NOT EXISTS bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales DECIMAL(18,2),
    sls_quantity INT,
    sls_price DECIMAL(18,2)
);

CREATE TABLE IF NOT EXISTS bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS bronze.erp_cust_az12 (
    cid VARCHAR(50),
    ddate DATE,
    gen VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(100),
    subcat VARCHAR(100),
    maintenance VARCHAR(100)
);
