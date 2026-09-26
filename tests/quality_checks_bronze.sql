/* Bronze quality checks - MySQL 8.0+ */

SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL SELECT 'crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL SELECT 'crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL SELECT 'erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL SELECT 'erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL SELECT 'erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;

SELECT * FROM bronze.crm_cust_info WHERE cst_id IS NULL;
SELECT * FROM bronze.crm_prd_info WHERE prd_id IS NULL;
SELECT * FROM bronze.crm_sales_details WHERE sls_ord_num IS NULL;

SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM bronze.crm_sales_details
WHERE (sls_order_dt IS NOT NULL AND (sls_order_dt < 19000101 OR sls_order_dt > 20500101))
   OR (sls_ship_dt IS NOT NULL AND (sls_ship_dt < 19000101 OR sls_ship_dt > 20500101))
   OR (sls_due_dt IS NOT NULL AND (sls_due_dt < 19000101 OR sls_due_dt > 20500101));
