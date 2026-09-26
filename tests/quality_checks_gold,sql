/* Gold quality checks - MySQL 8.0+ */
USE DataWarehouse;

SELECT customer_key,COUNT(*) duplicate_count
FROM gold.dim_customers GROUP BY customer_key HAVING COUNT(*)>1;

SELECT product_key,COUNT(*) duplicate_count
FROM gold.dim_products GROUP BY product_key HAVING COUNT(*)>1;

SELECT f.* FROM gold.fact_sales f
WHERE f.customer_key IS NULL OR f.product_key IS NULL;

SELECT * FROM gold.fact_sales
WHERE order_number IS NULL OR customer_key IS NULL OR product_key IS NULL OR order_date IS NULL;

SELECT * FROM gold.fact_sales
WHERE sales_amount<=0 OR quantity<=0 OR price<=0
   OR ABS(sales_amount-(quantity*price))>0.01;

SELECT * FROM gold.fact_sales
WHERE order_date>shipping_date OR order_date>due_date;

SELECT product_number,COUNT(*) record_count FROM gold.dim_products
GROUP BY product_number HAVING COUNT(*)>1;

SELECT customer_number,COUNT(*) record_count FROM gold.dim_customers
GROUP BY customer_number HAVING COUNT(*)>1;
