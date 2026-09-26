/* Gold quality checks - MySQL 8.0+ */

-- Surrogate-key uniqueness
SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Business-key uniqueness
SELECT customer_number, COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1;

SELECT product_number, COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Fact-to-dimension referential integrity
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;

-- Critical fact fields
SELECT *
FROM gold.fact_sales
WHERE order_number IS NULL
   OR sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL;

-- Measure consistency
SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0
   OR quantity <= 0
   OR price <= 0
   OR ABS(sales_amount - (quantity * price)) > 0.01;

-- Date consistency
SELECT *
FROM gold.fact_sales
WHERE order_date > shipping_date
   OR order_date > due_date;

-- Known source-data exception: invalid source order dates are
-- converted to NULL in Silver rather than being invented.
SELECT *
FROM gold.fact_sales
WHERE order_date IS NULL;
