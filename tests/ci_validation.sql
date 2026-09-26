/*
============================================================
CI Validation
============================================================
Fails the MySQL process when critical warehouse checks fail.
Used by GitHub Actions.
============================================================
*/

USE DataWarehouse;

DELIMITER $$

CREATE PROCEDURE tests_ci_validation()
BEGIN
    DECLARE bad_checks INT DEFAULT 0;

    SELECT COUNT(*) INTO @v
    FROM silver.crm_cust_info
    WHERE cst_id IS NULL;
    SET bad_checks = bad_checks + IF(@v > 0, 1, 0);

    SELECT COUNT(*) INTO @v
    FROM silver.crm_prd_info
    WHERE prd_id IS NULL OR prd_cost < 0 OR prd_line IS NULL;
    SET bad_checks = bad_checks + IF(@v > 0, 1, 0);

    SELECT COUNT(*) INTO @v
    FROM silver.crm_sales_details
    WHERE sls_order_dt IS NULL
       OR sls_ship_dt IS NULL
       OR sls_due_dt IS NULL
       OR sls_quantity <= 0
       OR sls_price <= 0
       OR sls_sales <= 0
       OR ABS(sls_sales - (sls_quantity * sls_price)) > 0.01;
    SET bad_checks = bad_checks + IF(@v > 0, 1, 0);

    SELECT COUNT(*) INTO @v
    FROM gold.fact_sales
    WHERE customer_key IS NULL
       OR product_key IS NULL
       OR order_date IS NULL;
    SET bad_checks = bad_checks + IF(@v > 0, 1, 0);

    SELECT COUNT(*) INTO @v
    FROM gold.fact_sales
    WHERE sales_amount <= 0
       OR quantity <= 0
       OR price <= 0
       OR ABS(sales_amount - (quantity * price)) > 0.01;
    SET bad_checks = bad_checks + IF(@v > 0, 1, 0);

    IF bad_checks > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'CI validation failed: one or more critical data-quality checks returned violations.';
    END IF;
END$$

DELIMITER ;

CALL tests_ci_validation();
DROP PROCEDURE tests_ci_validation;
