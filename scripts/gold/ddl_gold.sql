/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate key
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM is the primary source for gender
        ELSE COALESCE(ca.gen, 'n/a')  			   -- Fallback to ERP data
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter out all historical data
GO

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price,
    sd.profit_amount AS profit,
    sd.shipping_delay_days AS shipping_delay_days,
    sd.order_value_category AS order_value_category
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO

-- =============================================================================
-- Analytics View: Customer Performance Metrics (RFM-style)
-- =============================================================================
IF OBJECT_ID('gold.customer_metrics', 'V') IS NOT NULL
    DROP VIEW gold.customer_metrics;
GO

CREATE VIEW gold.customer_metrics AS
SELECT
    dc.customer_key,
    dc.customer_id,
    dc.first_name,
    dc.last_name,
    dc.country,
    COUNT(DISTINCT fs.order_number) AS total_orders,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.profit) AS total_profit,
    AVG(fs.sales_amount) AS avg_order_value,
    MAX(fs.order_date) AS last_purchase_date,
    CASE 
        WHEN SUM(fs.sales_amount) > 100000 THEN 'VIP'
        WHEN SUM(fs.sales_amount) > 50000 THEN 'Premium'
        ELSE 'Standard'
    END AS customer_segment,
    ROUND(
        SUM(fs.profit) * 100.0 / NULLIF(SUM(fs.sales_amount), 0), 
        2
    ) AS profit_margin_percent
FROM gold.dim_customers dc
LEFT JOIN gold.fact_sales fs
    ON dc.customer_key = fs.customer_key
GROUP BY dc.customer_key, dc.customer_id, dc.first_name, dc.last_name, dc.country;
GO

-- =============================================================================
-- Analytics View: Product Performance KPIs
-- =============================================================================
IF OBJECT_ID('gold.product_metrics', 'V') IS NOT NULL
    DROP VIEW gold.product_metrics;
GO

CREATE VIEW gold.product_metrics AS
SELECT
    dp.product_key,
    dp.product_id,
    dp.product_name,
    dp.category,
    dp.subcategory,
    COUNT(DISTINCT fs.order_number) AS units_sold,
    SUM(fs.sales_amount) AS revenue,
    SUM(fs.profit) AS profit,
    AVG(fs.sales_amount) AS avg_sale_price,
    dp.cost AS product_cost,
    SUM(fs.profit) / NULLIF(SUM(fs.sales_amount), 0) * 100 AS profit_margin_percent,
    RANK() OVER (PARTITION BY dp.category ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank_by_category
FROM gold.dim_products dp
LEFT JOIN gold.fact_sales fs
    ON dp.product_key = fs.product_key
GROUP BY dp.product_key, dp.product_id, dp.product_name, dp.category, dp.subcategory, dp.cost;
GO

-- =============================================================================
-- Analytics View: Order Fulfillment KPIs
-- =============================================================================
IF OBJECT_ID('gold.fulfillment_metrics', 'V') IS NOT NULL
    DROP VIEW gold.fulfillment_metrics;
GO

CREATE VIEW gold.fulfillment_metrics AS
SELECT
    CAST(fs.order_date AS DATE) AS order_date,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN fs.shipping_delay_days <= 0 THEN 1 ELSE 0 END) AS on_time_orders,
    SUM(CASE WHEN fs.shipping_delay_days > 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN fs.shipping_delay_days <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS on_time_delivery_rate,
    AVG(CAST(fs.shipping_delay_days AS FLOAT)) AS avg_shipping_delay_days,
    SUM(fs.sales_amount) AS daily_revenue
FROM gold.fact_sales fs
WHERE fs.order_date IS NOT NULL
GROUP BY CAST(fs.order_date AS DATE);
GO

-- =============================================================================
-- Analytics View: Revenue Summary by Category
-- =============================================================================
IF OBJECT_ID('gold.revenue_by_category', 'V') IS NOT NULL
    DROP VIEW gold.revenue_by_category;
GO

CREATE VIEW gold.revenue_by_category AS
SELECT
    dp.category,
    COUNT(DISTINCT fs.order_number) AS order_count,
    SUM(fs.sales_amount) AS total_revenue,
    SUM(fs.profit) AS total_profit,
    ROUND(
        SUM(fs.profit) * 100.0 / NULLIF(SUM(fs.sales_amount), 0), 
        2
    ) AS profit_margin_percent,
    AVG(fs.sales_amount) AS avg_order_value
FROM gold.dim_products dp
LEFT JOIN gold.fact_sales fs
    ON dp.product_key = fs.product_key
GROUP BY dp.category;
