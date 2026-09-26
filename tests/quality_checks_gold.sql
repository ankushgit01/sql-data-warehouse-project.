/* Gold quality checks - MySQL 8.0+ */

SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
   OR product_key IS NULL;

SELECT *
FROM gold.fact_sales
WHERE order_number IS NULL
   OR order_date IS NULL
   OR sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL;

SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0
   OR quantity <= 0
   OR price <= 0
   OR ABS(sales_amount - (quantity * price)) > 0.01;

SELECT *
FROM gold.fact_sales
WHERE order_date > shipping_date
   OR order_date > due_date;

SELECT product_number, COUNT(*) AS record_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

SELECT customer_number, COUNT(*) AS record_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING COUNT(*) > 1;
