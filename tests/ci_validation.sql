/*
============================================================
CI Validation
============================================================
Fails the MySQL process when critical warehouse checks fail.
Known source order-date anomalies are reported but are not
treated as a pipeline failure.
============================================================
*/

DROP PROCEDURE IF EXISTS silver.ci_validation;
DELIMITER $$

CREATE PROCEDURE silver.ci_validation()
BEGIN
    DECLARE bad_checks INT DEFAULT 0;
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM silver.crm_cust_info
    WHERE cst_id IS NULL;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM silver.crm_prd_info
    WHERE prd_id IS NULL OR prd_cost < 0 OR prd_line IS NULL;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM silver.crm_sales_details
    WHERE sls_quantity <= 0
       OR sls_price IS NULL
       OR sls_sales IS NULL
       OR sls_price <= 0
       OR sls_sales <= 0
       OR ABS(sls_sales - (sls_quantity * sls_price)) > 0.01;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM (
        SELECT customer_number
        FROM gold.dim_customers
        GROUP BY customer_number
        HAVING COUNT(*) > 1
    ) duplicates;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM (
        SELECT product_number
        FROM gold.dim_products
        GROUP BY product_number
        HAVING COUNT(*) > 1
    ) duplicates;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM gold.fact_sales
    WHERE customer_key IS NULL
       OR product_key IS NULL
       OR order_number IS NULL
       OR sales_amount IS NULL
       OR quantity IS NULL
       OR price IS NULL;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) INTO v_count
    FROM gold.fact_sales
    WHERE sales_amount <= 0
       OR quantity <= 0
       OR price <= 0
       OR ABS(sales_amount - (quantity * price)) > 0.01;
    SET bad_checks = bad_checks + IF(v_count > 0, 1, 0);

    SELECT COUNT(*) AS source_order_date_exceptions
    FROM gold.fact_sales
    WHERE order_date IS NULL;

    IF bad_checks > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'CI validation failed: critical data-quality checks returned violations.';
    END IF;
END$$

DELIMITER ;

CALL silver.ci_validation();
DROP PROCEDURE silver.ci_validation;
