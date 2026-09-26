/* Silver quality checks - MySQL 8.0+ */
USE DataWarehouse;

SELECT cst_id,COUNT(*) record_count FROM silver.crm_cust_info
GROUP BY cst_id HAVING cst_id IS NULL OR COUNT(*)>1;

SELECT cst_id,cst_key,cst_firstname,cst_lastname FROM silver.crm_cust_info
WHERE cst_key<>TRIM(cst_key) OR cst_firstname<>TRIM(cst_firstname) OR cst_lastname<>TRIM(cst_lastname);

SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single','Married','n/a');
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Female','Male','n/a');

SELECT prd_id,COUNT(*) record_count FROM silver.crm_prd_info
GROUP BY prd_id HAVING prd_id IS NULL OR COUNT(*)>1;
SELECT * FROM silver.crm_prd_info WHERE prd_cost<0 OR prd_cost IS NULL OR prd_end_dt<prd_start_dt;
SELECT DISTINCT prd_line FROM silver.crm_prd_info
WHERE prd_line NOT IN ('Mountain','Road','Other Sales','Touring','n/a');

SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL OR sls_ship_dt IS NULL OR sls_due_dt IS NULL
   OR sls_order_dt>sls_ship_dt OR sls_order_dt>sls_due_dt;
SELECT * FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
   OR sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
   OR ABS(sls_sales-(sls_quantity*sls_price))>0.01;

SELECT * FROM silver.erp_cust_az12 WHERE bdate>CURRENT_DATE();
SELECT DISTINCT gen FROM silver.erp_cust_az12 WHERE gen NOT IN ('Female','Male','n/a');
SELECT * FROM silver.erp_loc_a101 WHERE cntry IS NULL OR TRIM(cntry)='';
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat<>TRIM(cat) OR subcat<>TRIM(subcat) OR maintenance<>TRIM(maintenance);
