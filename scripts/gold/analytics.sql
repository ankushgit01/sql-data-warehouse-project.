/* Gold analytics - MySQL 8.0+ */

-- 1. Overall KPI snapshot for fully mapped sales
SELECT
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS active_customers,
    SUM(sales_amount) AS total_revenue,
    SUM(quantity) AS total_units,
    ROUND(
        SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_number), 0), 2
    ) AS avg_order_value
FROM gold.fact_sales
WHERE customer_key IS NOT NULL
  AND product_key IS NOT NULL;

-- 2. Monthly sales trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT order_number) AS orders,
    SUM(sales_amount) AS revenue,
    SUM(quantity) AS units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY sales_month;

-- 3. Top products by revenue
SELECT
    p.product_number,
    p.product_name,
    p.category,
    p.subcategory,
    SUM(f.sales_amount) AS revenue,
    SUM(f.quantity) AS units
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_number, p.product_name, p.category, p.subcategory
ORDER BY revenue DESC
LIMIT 20;

-- 4. Revenue by product category
SELECT
    p.category,
    SUM(f.sales_amount) AS revenue,
    SUM(f.quantity) AS units
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Top customers by lifetime revenue
SELECT
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.country,
    COUNT(DISTINCT f.order_number) AS orders,
    SUM(f.sales_amount) AS lifetime_revenue
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_number, c.first_name, c.last_name, c.country
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- 6. Customer distribution by country
SELECT country, COUNT(*) AS customers
FROM gold.dim_customers
GROUP BY country
ORDER BY customers DESC;

-- 7. Shipping performance
SELECT
    CASE
        WHEN shipping_date IS NULL THEN 'Not shipped'
        WHEN due_date IS NULL THEN 'Due date missing'
        WHEN shipping_date <= due_date THEN 'On time'
        ELSE 'Late'
    END AS shipping_status,
    COUNT(*) AS order_lines
FROM gold.fact_sales
GROUP BY
    CASE
        WHEN shipping_date IS NULL THEN 'Not shipped'
        WHEN due_date IS NULL THEN 'Due date missing'
        WHEN shipping_date <= due_date THEN 'On time'
        ELSE 'Late'
    END
ORDER BY order_lines DESC;

-- 8. Mapping and source-date diagnostics
SELECT
    COUNT(*) AS total_fact_rows,
    SUM(customer_key IS NULL) AS unmapped_customers,
    SUM(product_key IS NULL) AS unmapped_products,
    SUM(order_date IS NULL) AS missing_order_dates
FROM gold.fact_sales;
