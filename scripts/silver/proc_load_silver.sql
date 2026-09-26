/* Silver layer load procedure - MySQL 8.0+ */
USE DataWarehouse;

DROP PROCEDURE IF EXISTS silver.load_silver;
DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info
        (cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
    SELECT cst_id,TRIM(cst_key),TRIM(cst_firstname),TRIM(cst_lastname),
           CASE WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married' ELSE 'n/a' END,
           CASE WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male' ELSE 'n/a' END,
           cst_create_date
    FROM (
        SELECT b.*, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) rn
        FROM bronze.crm_cust_info b WHERE cst_id IS NOT NULL
    ) x WHERE rn=1;

    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info
        (prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
    SELECT prd_id,
           REPLACE(SUBSTRING(TRIM(prd_key),1,5),'-','_'),
           SUBSTRING(TRIM(prd_key),7),
           TRIM(prd_nm),COALESCE(prd_cost,0),
           CASE WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring' ELSE 'n/a' END,
           DATE(prd_start_dt),
           DATE_SUB(DATE(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)),INTERVAL 1 DAY)
    FROM bronze.crm_prd_info;

    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details
        (sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
    SELECT TRIM(sls_ord_num),TRIM(sls_prd_key),sls_cust_id,
           STR_TO_DATE(CAST(sls_order_dt AS CHAR),'%Y%m%d'),
           STR_TO_DATE(CAST(sls_ship_dt AS CHAR),'%Y%m%d'),
           STR_TO_DATE(CAST(sls_due_dt AS CHAR),'%Y%m%d'),
           CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales<>sls_quantity*ABS(sls_price)
                THEN sls_quantity*ABS(sls_price) ELSE sls_sales END,
           sls_quantity,
           CASE WHEN sls_price IS NULL OR sls_price<=0
                THEN ROUND(sls_sales/NULLIF(sls_quantity,0),2) ELSE ABS(sls_price) END
    FROM bronze.crm_sales_details;

    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
    SELECT CASE WHEN UPPER(TRIM(cid)) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid),4) ELSE TRIM(cid) END,
           CASE WHEN ddate>CURRENT_DATE() THEN NULL ELSE ddate END,
           CASE WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
                WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male' ELSE 'n/a' END
    FROM bronze.erp_cust_az12;

    TRUNCATE TABLE silver.erp_loc_a101;
    INSERT INTO silver.erp_loc_a101 (cid,cntry)
    SELECT REPLACE(TRIM(cid),'-',''),
           CASE WHEN UPPER(TRIM(cntry))='DE' THEN 'Germany'
                WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
                WHEN cntry IS NULL OR TRIM(cntry)='' THEN 'n/a'
                ELSE TRIM(cntry) END
    FROM bronze.erp_loc_a101;

    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
    SELECT TRIM(id),TRIM(cat),TRIM(subcat),TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;
END$$
DELIMITER ;
