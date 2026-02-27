/*
===============================================================================
Advanced Analytics Script
===============================================================================
PURPOSE:
    To perform deep-dive analysis on business performance, trends, 
    and customer behavior. 
    
SCOPE:
    - Change Over Time Analysis (Monthly/Yearly Trends)
    - Cumulative Analysis (Running Totals & Moving Averages)
    - Performance Analysis (Year-over-Year Growth)
    - Part-to-Whole Analysis (Category Contributions)
    - Data Segmentation (Product Cost Ranges & Customer Tiering)
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. Change Over Time Analysis
-------------------------------------------------------------------------------
-- Analyze monthly trends to identify seasonality and growth patterns
SELECT 
    DATETRUNC(MONTH, order_date) AS order_month,
    SUM(sales_amount)            AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity)                AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date);


-------------------------------------------------------------------------------
-- 2. Cumulative Analysis
-------------------------------------------------------------------------------
-- Calculate Running Total of Sales to track goal progress over time
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
    AVG(total_sales) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_3_month_avg
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount)            AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t;


-------------------------------------------------------------------------------
-- 3. Performance Analysis (Year-over-Year)
-------------------------------------------------------------------------------
-- Compare current product sales to the previous year and the product's lifetime average
WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE
        WHEN current_sales > LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Increase'
        WHEN current_sales < LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) THEN 'Decrease'
        ELSE 'No Change'
    END AS py_status,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg
FROM yearly_product_sales
ORDER BY product_name, order_year;


-------------------------------------------------------------------------------
-- 4. Part-to-Whole Analysis
-------------------------------------------------------------------------------
-- Identify which categories contribute the most to the total revenue
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS pct_of_total
FROM category_sales
ORDER BY total_sales DESC;


-------------------------------------------------------------------------------
-- 5. Data Segmentation
-------------------------------------------------------------------------------
-- Segment Products by Cost Range
WITH product_segments AS (
    SELECT
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT cost_range, COUNT(*) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Segment Customers by Spending & Lifespan (VIP, Regular, New)
WITH customer_metrics AS (
    SELECT
        f.customer_key,
        SUM(f.sales_amount) AS total_spending,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months
    FROM gold.fact_sales f
    GROUP BY f.customer_key
)
SELECT 
    customer_segment, 
    COUNT(*) AS total_customers 
FROM (
    SELECT
        customer_key,
        CASE
            WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_metrics
) t
GROUP BY customer_segment
ORDER BY total_customers DESC;
