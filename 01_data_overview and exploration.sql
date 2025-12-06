/*
File: 01_data_overview and exploration.sql
Dataset: Olist E-commerce Dataset
Purpose:
- Explore database structure and key tables
- Understand core dimensions, measures, and date ranges
- Validate basic data integrity and key metrics
*/

-- =====================================================
-- Database Structure Overview
-- =====================================================

-- explore all objects in the database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- explore all columns in the database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'olist';

-- =====================================================
-- Orders Overview
-- =====================================================

-- total number of unique orders
SELECT DISTINCT order_id
FROM orders;

-- distinct order statuses
SELECT DISTINCT order_status
FROM orders;

-- identify the date of the first and last order
SELECT MIN(order_purchase_timestamp),
       MAX(order_purchase_timestamp),
       TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS order_range_months
FROM orders;

-- =====================================================
-- Order Items Overview
-- =====================================================

-- total number of order items
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- identufy the max, min, avg order value
SELECT MAX(total_order_value) AS max_order_value,
       MIN(total_order_value) AS min_order_value,
       AVG(total_order_value) AS avg_order_value
FROM (
    SELECT order_id,
           SUM(price) AS total_order_value
FROM order_items
GROUP BY order_id) AS t;

-- =====================================================
-- Reviews Overview
-- =====================================================

-- the total number of reviews
SELECT *
FROM order_reviews;

-- the avg review_score
SELECT AVG(review_score)
FROM order_reviews;

-- =====================================================
-- Payments Overview
-- =====================================================

-- Check the number of payments and payment methods for each order
SELECT DISTINCT order_id,
       payment_sequential,
       payment_type,
       payment_installments,
       payment_value
FROM order_payments
ORDER BY order_id;

-- Calculates the percentage of orders that are paid with multiple payment methods and the percentage of orders paid in installments
WITH order_multi AS (
SELECT 
    order_id,
    MAX(payment_sequential >= 2) AS multi_payments,
    MAX(payment_installments >= 2) AS multi_installments
FROM order_payments
GROUP BY order_id)
SELECT CONCAT(ROUND((SUM(multi_payments) / COUNT(*))*100, 2), '%') AS pct_multi_payments,
       CONCAT(ROUND((SUM(multi_installments) / COUNT(*))*100, 2), '%') AS pct_multi_installments
FROM order_multi;

-- =====================================================
-- Customers Overview
-- =====================================================

-- Identify customer_unique_id values that appear more than once
SELECT customer_unique_id,
       COUNT(*) AS cnt
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;

-- Count the number of unique customer cities and states
SELECT COUNT(DISTINCT customer_city),
       COUNT(DISTINCT customer_state)
FROM customers;

-- =====================================================
-- Products Overview
-- =====================================================

-- Join products with the English category lookup table to retrieve the translated category names
SELECT *
FROM products p
LEFT JOIN product_category pc
ON p.product_category_name = pc.product_category_name;

-- =====================================================
-- Sellers Overview
-- =====================================================

-- Count the number of unique sellers, cities, and states
SELECT COUNT(DISTINCT seller_id),
       COUNT(DISTINCT seller_city),
       COUNT(DISTINCT seller_state)
FROM sellers;