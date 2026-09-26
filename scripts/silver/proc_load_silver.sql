/* Silver layer load procedure - MySQL 8.0+ */

DROP PROCEDURE IF EXISTS silver.load_silver;
DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
    /* CRM customer: trim, standardize, and keep the latest record per customer */
    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info
        (cst_id, cst_key, cst_firstname, cst_lastname,
         cst_marital_status, cst_gndr, cst_create_date)
    SELECT
        cst_id,
        TRIM(cst_key),
        TRIM(cst_firstname),
        TRIM(cst_lastname),
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,
        cst_create_date
    FROM (
        SELECT b.*,
               ROW_NUMBER() OVER (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC, cst_key DESC
               ) AS rn
        FROM bronze.crm_cust_info b
        WHERE cst_id IS NOT NULL
    ) x
    WHERE rn = 1;

    /* CRM product: normalize keys and derive product validity windows */
    TRUNCATE TABLE silver.crm_prd_info;

    INSERT INTO silver.crm_prd_info
        (prd_id, cat_id, prd_key, prd_nm, prd_cost,
         prd_line, prd_start_dt, prd_end_dt)
    SELECT
        prd_id,
        REPLACE(SUBSTRING(TRIM(prd_key), 1, 5), '-', '_'),
        SUBSTRING(TRIM(prd_key), 7),
        TRIM(prd_nm),
        COALESCE(prd_cost, 0),
        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END,
        DATE(prd_start_dt),
        DATE_SUB(
            DATE(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt, prd_id
                )
            ),
            INTERVAL 1 DAY
        )
    FROM bronze.crm_prd_info;

    /* CRM sales: convert valid YYYYMMDD values and reconcile sales/price */
    TRUNCATE TABLE silver.crm_sales_details;

    INSERT INTO silver.crm_sales_details
        (sls_ord_num, sls_prd_key, sls_cust_id,
         sls_order_dt, sls_ship_dt, sls_due_dt,
         sls_sales, sls_quantity, sls_price)
    WITH source_data AS (
        SELECT
            TRIM(sls_ord_num) AS sls_ord_num,
            TRIM(sls_prd_key) AS sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            ABS(sls_sales) AS raw_sales,
            sls_quantity,
            ABS(sls_price) AS raw_price
        FROM bronze.crm_sales_details
    ),
    calculated AS (
        SELECT
            *,
            CASE
                WHEN sls_order_dt IS NULL THEN NULL
                WHEN CAST(sls_order_dt AS CHAR) NOT REGEXP '^[0-9]{8}$' THEN NULL
                WHEN sls_order_dt NOT BETWEEN 19000101 AND 20501231 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_order_dt AS CHAR), 5, 2) AS UNSIGNED) NOT BETWEEN 1 AND 12 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_order_dt AS CHAR), 7, 2) AS UNSIGNED) NOT BETWEEN 1 AND
                    CASE
                        WHEN CAST(SUBSTRING(CAST(sls_order_dt AS CHAR), 5, 2) AS UNSIGNED) = 2
                            THEN 28 + IF(
                                MOD(FLOOR(sls_order_dt / 10000), 400) = 0
                                OR (
                                    MOD(FLOOR(sls_order_dt / 10000), 4) = 0
                                    AND MOD(FLOOR(sls_order_dt / 10000), 100) <> 0
                                ),
                                1,
                                0
                            )
                        WHEN CAST(SUBSTRING(CAST(sls_order_dt AS CHAR), 5, 2) AS UNSIGNED) IN (4,6,9,11)
                            THEN 30
                        ELSE 31
                    END THEN NULL
                ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
            END AS clean_order_dt,

            CASE
                WHEN sls_ship_dt IS NULL THEN NULL
                WHEN CAST(sls_ship_dt AS CHAR) NOT REGEXP '^[0-9]{8}$' THEN NULL
                WHEN sls_ship_dt NOT BETWEEN 19000101 AND 20501231 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_ship_dt AS CHAR), 5, 2) AS UNSIGNED) NOT BETWEEN 1 AND 12 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_ship_dt AS CHAR), 7, 2) AS UNSIGNED) NOT BETWEEN 1 AND
                    CASE
                        WHEN CAST(SUBSTRING(CAST(sls_ship_dt AS CHAR), 5, 2) AS UNSIGNED) = 2
                            THEN 28 + IF(
                                MOD(FLOOR(sls_ship_dt / 10000), 400) = 0
                                OR (
                                    MOD(FLOOR(sls_ship_dt / 10000), 4) = 0
                                    AND MOD(FLOOR(sls_ship_dt / 10000), 100) <> 0
                                ),
                                1,
                                0
                            )
                        WHEN CAST(SUBSTRING(CAST(sls_ship_dt AS CHAR), 5, 2) AS UNSIGNED) IN (4,6,9,11)
                            THEN 30
                        ELSE 31
                    END THEN NULL
                ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
            END AS clean_ship_dt,

            CASE
                WHEN sls_due_dt IS NULL THEN NULL
                WHEN CAST(sls_due_dt AS CHAR) NOT REGEXP '^[0-9]{8}$' THEN NULL
                WHEN sls_due_dt NOT BETWEEN 19000101 AND 20501231 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_due_dt AS CHAR), 5, 2) AS UNSIGNED) NOT BETWEEN 1 AND 12 THEN NULL
                WHEN CAST(SUBSTRING(CAST(sls_due_dt AS CHAR), 7, 2) AS UNSIGNED) NOT BETWEEN 1 AND
                    CASE
                        WHEN CAST(SUBSTRING(CAST(sls_due_dt AS CHAR), 5, 2) AS UNSIGNED) = 2
                            THEN 28 + IF(
                                MOD(FLOOR(sls_due_dt / 10000), 400) = 0
                                OR (
                                    MOD(FLOOR(sls_due_dt / 10000), 4) = 0
                                    AND MOD(FLOOR(sls_due_dt / 10000), 100) <> 0
                                ),
                                1,
                                0
                            )
                        WHEN CAST(SUBSTRING(CAST(sls_due_dt AS CHAR), 5, 2) AS UNSIGNED) IN (4,6,9,11)
                            THEN 30
                        ELSE 31
                    END THEN NULL
                ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
            END AS clean_due_dt,

            CASE
                WHEN raw_price IS NULL OR raw_price = 0
                    THEN ROUND(raw_sales / NULLIF(sls_quantity, 0), 2)
                ELSE raw_price
            END AS clean_price
        FROM source_data
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        clean_order_dt,
        clean_ship_dt,
        clean_due_dt,
        CASE
            WHEN raw_sales IS NULL
              OR raw_sales = 0
              OR clean_price IS NULL
              OR ABS(raw_sales - (sls_quantity * clean_price)) > 0.01
                THEN sls_quantity * clean_price
            ELSE raw_sales
        END,
        sls_quantity,
        clean_price
    FROM calculated;

    /* ERP customer: normalize ID, standardize demographics, and keep one row per customer */
    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        cid,
        CASE
            WHEN ddate > CURRENT_DATE() THEN NULL
            ELSE ddate
        END,
        gen
    FROM (
        SELECT
            CASE
                WHEN UPPER(TRIM(cid)) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4)
                ELSE TRIM(cid)
            END AS cid,
            ddate,
            CASE
                WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
                WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
                ELSE 'n/a'
            END AS gen,
            ROW_NUMBER() OVER (
                PARTITION BY
                    CASE
                        WHEN UPPER(TRIM(cid)) LIKE 'NAS%' THEN SUBSTRING(TRIM(cid), 4)
                        ELSE TRIM(cid)
                    END
                ORDER BY ddate DESC, TRIM(cid) DESC
            ) AS rn
        FROM bronze.erp_cust_az12
    ) x
    WHERE rn = 1;

    /* ERP location: normalize IDs/countries and deduplicate business keys */
    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT DISTINCT
        REPLACE(TRIM(cid), '-', ''),
        CASE
            WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
            ELSE TRIM(cntry)
        END
    FROM bronze.erp_loc_a101;

    /* ERP product category: trim source values */
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2
        (id, cat, subcat, maintenance)
    SELECT DISTINCT
        TRIM(id),
        TRIM(cat),
        TRIM(subcat),
        TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;
END$$

DELIMITER ;
