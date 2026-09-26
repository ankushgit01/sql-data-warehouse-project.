/* Gold analytics - MySQL 8.0+ */
USE DataWarehouse;

SELECT COUNT(DISTINCT order_number) total_orders,
       COUNT(DISTINCT customer_key) active_customers,
       SUM(sales_amount) total_revenue,
       SUM(quantity) total_units,
       ROUND(SUM(sales_amount)/NULLIF(COUNT(DISTINCT order_number),0),2) avg_order_value
FROM gold.fact_sales
WHERE customer_key IS NOT NULL AND product_key IS NOT NULL;

SELECT DATE_FORMAT(order_date,'%Y-%m') sales_month,
       COUNT(DISTINCT order_number) orders,
       SUM(sales_amount) revenue,
       SUM(quantity) units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date,'%Y-%m')
ORDER BY sales_month;

SELECT p.product_number,p.product_name,p.category,p.subcategory,
       SUM(f.sales_amount) revenue,SUM(f.quantity) units
FROM gold.fact_sales f JOIN gold.dim_products p ON f.product_key=p.product_key
GROUP BY p.product_number,p.product_name,p.category,p.subcategory
ORDER BY revenue DESC LIMIT 20;

SELECT p.category,SUM(f.sales_amount) revenue,SUM(f.quantity) units
FROM gold.fact_sales f JOIN gold.dim_products p ON f.product_key=p.product_key
GROUP BY p.category ORDER BY revenue DESC;

SELECT c.customer_number,CONCAT(c.first_name,' ',c.last_name) customer_name,
       c.country,COUNT(DISTINCT f.order_number) orders,SUM(f.sales_amount) lifetime_revenue
FROM gold.fact_sales f JOIN gold.dim_customers c ON f.customer_key=c.customer_key
GROUP BY c.customer_number,c.first_name,c.last_name,c.country
ORDER BY lifetime_revenue DESC LIMIT 20;

SELECT country,COUNT(*) customers
FROM gold.dim_customers GROUP BY country ORDER BY customers DESC;

SELECT CASE WHEN shipping_date IS NULL THEN 'Not shipped'
            WHEN shipping_date<=due_date THEN 'On time' ELSE 'Late' END shipping_status,
       COUNT(*) order_lines
FROM gold.fact_sales
GROUP BY CASE WHEN shipping_date IS NULL THEN 'Not shipped'
              WHEN shipping_date<=due_date THEN 'On time' ELSE 'Late' END
ORDER BY order_lines DESC;
