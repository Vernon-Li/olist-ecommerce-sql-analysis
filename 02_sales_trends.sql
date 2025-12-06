/*
File: 02_sales_trends.sql
Dataset: Olist E-commerce Dataset
Purpose:
- Analyze sales performance trends over time
- Evaluate monthly and yearly sales patterns
- Track cumulative sales growth and moving averages
*/

-- =====================================================
-- Monthly Sales Performance
-- =====================================================

-- Calculate monthly sales performance, including total sales value, number of unique orders, and total items sold per month
SELECT CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0')) AS order_date,
       ROUND(SUM(price), 2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(oi.order_id) AS total_items
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
GROUP BY CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0'))
ORDER BY CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0'));

-- Extract all orders from 2016-09 to verify the monthly summary logic
SELECT *
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
WHERE o.order_purchase_timestamp >= '2016-09-01'
  AND o.order_purchase_timestamp < '2016-10-01';

-- =====================================================
-- Monthly Running Total & Moving Average
-- =====================================================

-- Calculate running total of sales and moving average price up to the current month
WITH monthly_sales_perf AS(
SELECT CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0')) AS order_date,
       ROUND(SUM(price), 2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(oi.order_id) AS total_items,
       AVG(price) AS avg_price
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
GROUP BY CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0'))
ORDER BY CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0')))
SELECT order_date,
       total_sales,
       total_items,
       ROUND(SUM(total_sales) OVER (ORDER BY order_date), 2) AS running_total_sales,
       ROUND(AVG(avg_price) OVER (ORDER BY order_date), 2) AS moving_average_price
FROM monthly_sales_perf;

-- =====================================================
-- Yearly Sales Performance
-- =====================================================

-- Calculate running total of sales and moving average price up to the current year
WITH yearly_sales_perf AS(
SELECT YEAR(o.order_purchase_timestamp) AS order_date,
       ROUND(SUM(price), 2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(oi.order_id) AS total_items,
       AVG(price) AS avg_price
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY YEAR(o.order_purchase_timestamp)
)

SELECT order_date,
       total_sales,
       total_items,
       ROUND(SUM(total_sales) OVER (ORDER BY order_date), 2) AS running_total_sales,
       ROUND(AVG(avg_price) OVER (ORDER BY order_date), 2) AS moving_average_price
FROM yearly_sales_perf;

-- =====================================================
-- City-Level Sales Performance (Top 30 Cities)
-- =====================================================

-- Generate a city-level sales summary showing each city's total sales, its share of overall sales, and list the top 30 cities by sales
WITH city_sales AS(
SELECT c.customer_state AS state,
       c.customer_city AS city,
       SUM(oi.price) AS total_sales
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
LEFT JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state, c.customer_city
)

SELECT state,
       city,
       ROUND(total_sales, 2) AS total_sales,
       ROUND(SUM(total_sales) OVER (), 2) AS overall_sales,
       CONCAT(ROUND((total_sales / SUM(total_sales) OVER ()) * 100, 2), '%') AS city_sales_pct
FROM city_sales
ORDER BY total_sales DESC
LIMIT 30;

