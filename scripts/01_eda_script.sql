/*
===============================================================================
Exploratory Data Analysis (EDA) Script
===============================================================================
PURPOSE:
    To explore the Gold Layer data, understand its distributions, 
    identify key business metrics, and perform ranking/magnitude analysis.
    This script serves as Phase 1 of the Analytics cycle.

SCOPE:
    - Metadata Exploration
    - Dimension & Date Profiling
    - Measure Analysis (Total Sales, Orders, Customers)
    - Magnitude Analysis (Category & Geography)
    - Ranking Analysis (Top/Bottom Performers)
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. Metadata Exploration
-------------------------------------------------------------------------------
-- View all objects in the Gold Layer
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'gold';

-- Explore columns and data types for the Customer Dimension
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


-------------------------------------------------------------------------------
-- 2. Dimension Exploration (Unique Values)
-------------------------------------------------------------------------------
-- Explore distinct countries in our customer base
SELECT DISTINCT country FROM gold.dim_customers;

-- Explore product hierarchy (Category -> Sub-Category -> Product)
SELECT DISTINCT category, sub_category, product_name 
FROM gold.dim_products
ORDER BY 1, 2, 3;


-------------------------------------------------------------------------------
-- 3. Date Exploration & Profiling
-------------------------------------------------------------------------------
-- Profile Customer Age Distribution
SELECT 
    MIN(birthdate) AS oldest_birthdate, 
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;

-- Profile Order Date Range (Data Lifecycle)
SELECT 
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_span_years,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_span_months
FROM gold.fact_sales;


-------------------------------------------------------------------------------
-- 4. Key Performance Indicators (KPI) Summary
-------------------------------------------------------------------------------
-- Generate a comprehensive business health report
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Avg Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Unique Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Unique Products' AS measure_name, COUNT(DISTINCT product_name) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customer Base' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Active Customers (Purchased)' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales;


-------------------------------------------------------------------------------
-- 5. Magnitude Analysis (Volume & Value)
-------------------------------------------------------------------------------
-- Total Customers by Country
SELECT country, COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total Revenue by Category
SELECT p.category, SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Average Cost per Category (Product Profitability Baseline)
SELECT category, AVG(cost) AS avg_product_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_product_cost DESC;


-------------------------------------------------------------------------------
-- 6. Ranking Analysis (Using Window Functions)
-------------------------------------------------------------------------------
-- Top 5 Products by Revenue
SELECT TOP 5 
    product_name, 
    SUM(sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY product_name
ORDER BY total_revenue DESC;

-- Top 10 High-Value Customers (Revenue Generation)
SELECT TOP 10
    c.customer_key,
    c.first_name + ' ' + c.last_name AS full_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Bottom 3 Customers by Order Frequency (Low Engagement)
SELECT TOP 3
    c.first_name + ' ' + c.last_name AS full_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders ASC;
