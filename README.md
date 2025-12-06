# Olist E-commerce Analysis

## Project Overview
This repository contains SQL-based analysis of the Olist E-commerce Dataset. The main goal is to explore the dataset, evaluate product and sales performance, and segment customers for better business insights.

**Dataset:**
The dataset used is the [Olist E-commerce dataset](https://www.kaggle.com/olistbr/brazilian-ecommerce)

**Purpose:**  
- Understand the dataset structure and contents  
- Track sales trends over time  
- Evaluate product and category-level performance  
- Segment customers based on spending and membership duration

---

## File Structure

### 01_data_overview and exploration.sql
**Purpose:**  
- Explore database tables and columns  
- Examine distinct orders, products, payments, and reviews  
- Summarize customer and seller information  
- Identify key metrics for each table (total orders, total items, unique customers, etc.)

### 02_sales_trends.sql
**Purpose:**  
- Analyze monthly and yearly sales performance  
- Calculate cumulative sales growth and moving averages  
- Generate city-level sales summary and top 30 cities by sales

### 03_product_performance.sql
**Purpose:**  
- Evaluate monthly product category performance  
- Calculate deviations from average sales and month-over-month changes  
- Aggregate product-level metrics including total sales, average price, quantity sold, customer reach, and recency  
- Segment products into High-Performer, Mid-Range, and Low-Performer categories

### 04_customer_segmentation.sql
**Purpose:**  
- Compute each customer’s total spending and first purchase date  
- Determine membership duration in months  
- Segment customers into VVIP, VIP, Regular, Active New, and New categories  
- Summarize total customers and total spending per segment

---

### Outcome
- **Data Overview:** Gained clear understanding of tables, columns, and basic statistics  
- **Sales Trends:** Identified growth patterns, top-performing months, and top cities by sales  
- **Product Performance:** Determined top-selling products, category performance, and product segments  
- **Customer Segmentation:** Grouped customers by spending behavior and tenure for targeted strategies
