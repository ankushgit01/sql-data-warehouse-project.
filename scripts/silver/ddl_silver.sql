/*
============================================================
Create Silver Layer Tables
============================================================
Silver = cleaned and standardized data.
Target: MySQL 8.0+
Database: silver
============================================================
*/

DROP TABLE IF EXISTS silver.crm_cust_info;
DROP TABLE IF EXISTS silver.crm_prd_info;
DROP TABLE IF EXISTS silver.crm_sales_details;
DROP TABLE IF EXISTS silver.erp_loc_a101;
DROP TABLE IF EXISTS silver.erp_cust_az12;
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

CREATE TABLE silver.crm_cust_info (
    cst_id INT NOT NULL,
    cst_key VARCHAR(50) NOT NULL,
    cst_firstname VARCHAR(100),
    cst_lastname VARCHAR(100),
    cst_marital_status VARCHAR(50) NOT NULL,
    cst_gndr VARCHAR(50) NOT NULL,
    cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (cst_id),
    INDEX idx_crm_cust_key (cst_key)
);

CREATE TABLE silver.crm_prd_info (
    prd_id INT NOT NULL,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50) NOT NULL,
    prd_nm VARCHAR(150),
    prd_cost DECIMAL(18,2) NOT NULL DEFAULT 0,
    prd_line VARCHAR(50) NOT NULL,
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_crm_prd_key (prd_key),
    INDEX idx_crm_prd_id (prd_id)
);

CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50) NOT NULL,
    sls_prd_key VARCHAR(50) NOT NULL,
    sls_cust_id INT NOT NULL,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales DECIMAL(18,2),
    sls_quantity INT,
    sls_price DECIMAL(18,2),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sales_prd_key (sls_prd_key),
    INDEX idx_sales_cust_id (sls_cust_id),
    INDEX idx_sales_order_dt (sls_order_dt)
);

CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(50) NOT NULL,
    cntry VARCHAR(100) NOT NULL,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_erp_loc_cid (cid)
);

CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(50) NOT NULL,
    bdate DATE,
    gen VARCHAR(50) NOT NULL,
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_erp_cust_cid (cid)
);

CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(50) NOT NULL,
    cat VARCHAR(100),
    subcat VARCHAR(100),
    maintenance VARCHAR(100),
    dwh_create_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_erp_cat_id (id)
);
