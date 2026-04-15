/*
===============================================================================
Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    This script performs data quality checks to ensure consistency, accuracy,
    and standardization across the 'silver' layer.

Checks Included:
    - NULL or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization issues
    - Invalid date ranges and sequences
    - Data consistency across related fields

Usage Notes:
    - Execute after loading data into the Silver layer
    - Investigate any returned records (these indicate data issues)
===============================================================================
*/

-- ====================================================================
-- 1. TABLE: silver.crm_cust_info
-- ====================================================================

-- Check: NULLs or Duplicate Primary Keys
-- Expectation: No results
SELECT 
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check: Unwanted Spaces
-- Expectation: No results
SELECT 
    cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check: Data Standardization
SELECT DISTINCT 
    cst_marital_status
FROM silver.crm_cust_info;


-- ====================================================================
-- 2. TABLE: silver.crm_prd_info
-- ====================================================================

-- Check: NULLs or Duplicate Primary Keys
SELECT 
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check: Unwanted Spaces
SELECT 
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check: NULL or Negative Cost
SELECT 
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check: Data Standardization
SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info;

-- Check: Invalid Date Range
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- 3. TABLE: silver.crm_sales_details
-- ====================================================================

-- Check: Invalid Dates (Bronze Source Validation)
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LENGTH(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Check: Invalid Date Order
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check: Sales Consistency
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales != sls_quantity * sls_price
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- 4. TABLE: silver.erp_cust_az12
-- ====================================================================

-- Check: Valid Birthdate Range
SELECT DISTINCT 
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CURRENT_DATE();

-- Check: Gender Standardization
SELECT DISTINCT 
    gen
FROM silver.erp_cust_az12;


-- ====================================================================
-- 5. TABLE: silver.erp_loc_a101
-- ====================================================================

-- Check: Country Standardization
SELECT DISTINCT 
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- 6. TABLE: silver.erp_px_cat_g1v2
-- ====================================================================

-- Check: Unwanted Spaces
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Check: Maintenance Standardization
SELECT DISTINCT 
    maintenance
FROM silver.erp_px_cat_g1v2;
