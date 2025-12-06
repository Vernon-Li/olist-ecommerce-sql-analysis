/*
File: 04_customer_segmentation.sql
Dataset: Olist E-commerce Dataset
Purpose:
- Segment customers based on spending behavior and lifecycle duration
- Measure customer value using total spending and membership length
- Identify high-value and new customer groups for business insights
*/

-- =====================================================
-- Customer Segmentation Analysis
-- =====================================================

-- Step 1: Compute each customer's total spending and their first purchase date
WITH customer_spending AS (
SELECT o.customer_id,
       SUM(oi.price) AS total_spending,
       MIN(o.order_purchase_timestamp) AS first_order
FROM order_items oi
LEFT JOIN orders o
ON oi.order_id = o.order_id
GROUP BY o.customer_id
),
-- Step 2: Retrieve the most recent order date across the entire dataset
max_order_date AS (
    SELECT MAX(order_purchase_timestamp) AS max_date
    FROM orders
),
-- Step 3: Calculate each customer’s membership duration (in months) by comparing their first purchase date with the dataset’s most recent order date
customer_lifespan AS (
SELECT 
    c.customer_id,
    c.total_spending,
    c.first_order,
    m.max_date,
    TIMESTAMPDIFF(MONTH, c.first_order, m.max_date) AS membership_months
FROM customer_spending c
CROSS JOIN max_order_date m
)

-- Step 4: Assign customers into defined membership segments based on their spending level and membership duration, then count customers in each segment
SELECT customer_segment,
       COUNT(customer_id) AS total_customers,
       ROUND(SUM(total_spending), 0) AS total_spending
FROM (
SELECT customer_id,
       total_spending,
       membership_months,
       CASE WHEN membership_months > 12 AND total_spending > 2500 THEN 'VVIP'
            WHEN membership_months > 12 AND total_spending >= 1000 THEN 'VIP'
            WHEN membership_months > 12 AND total_spending < 1000 THEN 'Regular'
            WHEN membership_months < 12 AND total_spending > 500 THEN 'Active New'
            ELSE 'New'
    END AS customer_segment
FROM customer_lifespan ) t
GROUP BY customer_segment
ORDER BY total_customers DESC;