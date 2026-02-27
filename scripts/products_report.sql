/*
===============================================================================
GOLD LAYER REPORTING VIEWS
===============================================================================
PURPOSE:
    These views consolidate complex logic, aggregations, and business 
    segmentations into flat, easy-to-query reporting models. 
   
    -- gold.report_products: Product-centric metrics & performance tiers.
===============================================================================
*/

-------------------------------------------------------------------------------
-- PRODUCT REPORT: gold.report_products
-------------------------------------------------------------------------------
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS 
WITH base_query AS (
    /* 1) Base Query: Link Sales to Product Metadata */
    SELECT 
        f.order_number,
        f.customer_key,
        f.order_date,
        f.sales_amount,
        f.quantity,
        f.price,
        p.product_key,
        p.product_number,
        p.product_name,
        p.category,
        p.sub_category,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
), 
product_aggregation AS (
    /* 2) Aggregations: Summarize at Product Level */
    SELECT 
        product_key,
        product_number,
        product_name,
        category,
        sub_category,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount)            AS total_sales,
        SUM(quantity)                AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        MAX(order_date)              AS last_sale_date,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM base_query
    GROUP BY product_key, product_number, product_name, category, sub_category, cost
)
SELECT
    product_key,
    product_number,
    product_name,
    category,
    sub_category,
    cost,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    /* 3) Business Logic: Segmentation & KPI Calculation */
    CASE 
        WHEN total_sales > 150000 THEN 'High-Performers'
        WHEN total_sales BETWEEN 50000 AND 150000 THEN 'Mid-Range'
        ELSE 'Low-Performers'
    END AS product_segment,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_months, -- Logic Fix: Measure from last sale date
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue
FROM product_aggregation;
GO
