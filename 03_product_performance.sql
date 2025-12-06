/*
File: 03_product_performance.sql
Dataset: Olist E-commerce Dataset
Purpose:
-- Evaluate product and category-level sales performance
-- Includes monthly category trends and product-level KPIs
-- Designed for e-commerce sales analysis and portfolio presentation
*/

-- =====================================================
-- PART 1: Monthly Product Category Performance
-- =====================================================

-- Generates a monthly sales report by product category
-- Shows:
-- 1. Monthly total sales, orders, items sold, and average price
-- 2. Deviation from each category's historical average sales
-- 3. Month-over-month (MoM) sales changes and growth rates
WITH monthly_product_sales AS(
SELECT CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0')) AS order_date,
       pc.product_category_name_english AS product_cate,
       ROUND(SUM(price), 2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(oi.order_id) AS total_items,
       ROUND(AVG(price), 2) AS avg_price
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
LEFT JOIN products p
ON oi.product_id = p.product_id
LEFT JOIN product_category pc
ON p.product_category_name = pc.product_category_name
GROUP BY CONCAT(YEAR(o.order_purchase_timestamp), '-', LPAD(MONTH(o.order_purchase_timestamp), 2, '0')), 
         pc.product_category_name_english
)
         
SELECT order_date,
       product_cate,
       total_sales,
       ROUND(AVG(total_sales) OVER (PARTITION BY product_cate), 2) AS avg_price,
       ROUND(total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_cate), 2), 2) AS diff_avg,
       CASE WHEN ROUND(total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_cate), 2), 2) > 0 THEN 'Above Avg'
            WHEN ROUND(total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_cate), 2), 2) < 0 THEN 'Below Avg'
            ELSE 'Avg'
	    END AS avg_change,
        LAG(total_sales) OVER (PARTITION BY product_cate ORDER BY order_date) AS pm_sales,
        ROUND(total_sales - LAG(total_sales) OVER (PARTITION BY product_cate ORDER BY order_date), 2) AS diff_pm,
        CONCAT(ROUND(((total_sales - LAG(total_sales) OVER (PARTITION BY product_cate ORDER BY order_date)) / LAG(total_sales) OVER (PARTITION BY product_cate ORDER BY order_date)) * 100, 2), '%') AS diff_pm_pct
FROM monthly_product_sales
WHERE product_cate IS NOT NULL
ORDER BY product_cate, order_date;

-- =====================================================
-- PART 2: Product-Level Performance Report
-- =====================================================

-- Creates a product-level KPI view
-- Used for product segmentation and lifecycle analysis
-- Metrics include sales, orders, customers, pricing, and recency
/*
PRODUCT_REPORT
*/
CREATE VIEW product_report AS
-- CTE#1: Retrieve the most recent order date across the entire dataset
WITH max_order_date AS (
SELECT MAX(order_purchase_timestamp) AS max_date
FROM orders
),
-- CTE#2: Aggregate product-level metrics
product_report AS (
SELECT oi.product_id,
	   pc.product_category_name_english AS eng_category,
       ROUND(SUM(oi.price), 2) AS total_sales,
       COUNT(DISTINCT oi.order_id) AS total_orders,
       COUNT(oi.order_id) AS total_quantity_sold,
       ROUND(AVG(price), 2) AS avg_price,
       COUNT(DISTINCT o.customer_id) AS total_customers,
       MAX(o.order_purchase_timestamp) AS last_order_date,
       TIMESTAMPDIFF(MONTH, MAX(o.order_purchase_timestamp), MAX(m.max_date)) AS recency_in_months
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN product_category pc
    ON p.product_category_name = pc.product_category_name
LEFT JOIN orders o
    ON oi.order_id = o.order_id
CROSS JOIN max_order_date m
GROUP BY oi.product_id,
         pc.product_category_name_english
)

-- Final output with segmenting and metrics
SELECT product_id,
       eng_category,
       total_sales,
       total_orders,
       total_quantity_sold,
       avg_price,
       total_customers,
       last_order_date,
       recency_in_months,
       CASE WHEN total_sales >= 10000 THEN 'High-Performer'
            WHEN total_sales >= 3000 THEN 'Mid-Range'
            ELSE 'Low-Performer'
		END AS product_segments,
	   CASE WHEN total_orders = 0 THEN 0
            ELSE ROUND((total_sales / total_orders), 2)
		END AS avg_order_revenue
FROM product_report
ORDER BY total_sales DESC;