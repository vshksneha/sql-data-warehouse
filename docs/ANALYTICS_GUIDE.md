# E-Commerce Data Warehouse - Analytics Guide

**Purpose:** Practical queries and examples for analyzing your data warehouse  
**Audience:** Business Analysts, Data Analysts, Power BI/Tableau users  
**Tools:** SQL Server, Any BI Tool

---

## 🎯 Quick Query Reference

### **1. Customer Analytics**

#### 1.1 Top 10 Customers by Revenue

```sql
SELECT TOP 10
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    country,
    total_orders,
    total_sales,
    total_profit,
    avg_order_value,
    customer_segment,
    DATEDIFF(DAY, last_purchase_date, GETDATE()) AS days_since_purchase
FROM gold.customer_metrics
WHERE total_sales > 0
ORDER BY total_sales DESC;
```

**Use Case:** Identify your VIP customers for relationship management

---

#### 1.2 Customer Segmentation Analysis

```sql
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(total_orders) AS total_orders,
    SUM(total_sales) AS segment_revenue,
    SUM(total_profit) AS segment_profit,
    AVG(total_sales) AS avg_customer_revenue,
    AVG(profit_margin_percent) AS avg_profit_margin
FROM gold.customer_metrics
GROUP BY customer_segment
ORDER BY segment_revenue DESC;
```

**Output Example:**

```
Segment    Count  Orders  Revenue      Profit       Avg Revenue  Margin%
VIP        25     750     2,500,000    1,250,000    100,000      50%
Premium    150    2,100   3,000,000    1,350,000    20,000       45%
Standard   2,800  5,600   2,000,000    700,000      714          35%
```

**Use Case:** Understand customer tier distribution and value

---

#### 1.3 Customer Churn Risk Analysis

```sql
SELECT
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    total_orders,
    total_sales,
    customer_segment,
    last_purchase_date,
    DATEDIFF(DAY, last_purchase_date, GETDATE()) AS days_inactive,
    CASE
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) > 180 THEN 'At Risk (>180d)'
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) > 90 THEN 'Watch (90-180d)'
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) > 30 THEN 'Active (1-30d)'
        ELSE 'Very Active (<1m)'
    END AS activity_status
FROM gold.customer_metrics
ORDER BY last_purchase_date ASC;
```

**Use Case:** Identify at-risk customers for retention campaigns

---

#### 1.4 Customer Repeat Purchase Rate

```sql
SELECT
    ROUND((100.0 * COUNT(CASE WHEN total_orders > 1 THEN 1 END)
        / COUNT(DISTINCT customer_id)), 2) AS repeat_customer_pct,
    COUNT(DISTINCT CASE WHEN total_orders > 1 THEN customer_id END) AS repeat_customers,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(CAST(total_orders AS FLOAT)), 2) AS avg_orders_per_customer
FROM gold.customer_metrics;
```

**Expected Output:**

```
Repeat %  Repeat Customers  Total Customers  Avg Orders
45.2%     1,254             2,775            2.8
```

**Use Case:** Measure customer loyalty and retention health

---

#### 1.5 Top 10 Customers by Profit (Not Revenue!)

```sql
SELECT TOP 10
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    total_sales,
    total_profit,
    profit_margin_percent,
    customer_segment
FROM gold.customer_metrics
WHERE total_profit > 0
ORDER BY total_profit DESC;
```

**Use Case:** Identify most profitable customers (not always highest revenue)

---

### **2. Product Analytics**

#### 2.1 Top 20 Products by Revenue

```sql
SELECT TOP 20
    product_id,
    product_name,
    category,
    subcategory,
    units_sold,
    revenue,
    profit,
    profit_margin_percent,
    revenue_rank_by_category
FROM gold.product_metrics
WHERE revenue > 0
ORDER BY revenue DESC;
```

**Use Case:** Identify best-selling and revenue-driving products

---

#### 2.2 Bottom 10 Products by Margin (Underperformers)

```sql
SELECT TOP 10
    product_id,
    product_name,
    category,
    units_sold,
    revenue,
    profit,
    profit_margin_percent
FROM gold.product_metrics
WHERE revenue > 0
ORDER BY profit_margin_percent ASC;
```

**Use Case:** Identify products to discontinue or reprice

---

#### 2.3 Product Category Performance Summary

```sql
SELECT
    category,
    COUNT(DISTINCT product_id) AS num_products,
    SUM(units_sold) AS total_units,
    SUM(revenue) AS category_revenue,
    SUM(profit) AS category_profit,
    AVG(profit_margin_percent) AS avg_margin_percent,
    MAX(profit_margin_percent) AS max_margin,
    MIN(profit_margin_percent) AS min_margin
FROM gold.product_metrics
GROUP BY category
ORDER BY category_revenue DESC;
```

**Output Example:**

```
Category      Products  Units  Revenue      Profit       Avg Margin  Max    Min
Mountain      45        5,200  1,200,000    480,000      40%        65%    15%
Road          38        4,100  1,100,000    495,000      45%        70%    20%
Accessories   92        8,500  700,000      245,000      35%        60%    10%
```

**Use Case:** Portfolio analysis and category strategy

---

#### 2.4 Products with Growing vs Declining Sales

```sql
-- Compare current period vs previous period
SELECT
    p.product_id,
    p.product_name,
    p.category,
    SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -1, GETDATE())
        THEN f.sales_amount ELSE 0 END) AS current_month_sales,
    SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -2, GETDATE())
        AND f.order_date < DATEADD(MONTH, -1, GETDATE())
        THEN f.sales_amount ELSE 0 END) AS previous_month_sales,
    ROUND(
        (SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END) -
        SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -2, GETDATE())
            AND f.order_date < DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -2, GETDATE())
            AND f.order_date < DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END), 0),
        2
    ) AS growth_percent
FROM gold.dim_products p
LEFT JOIN gold.fact_sales f ON p.product_key = f.product_key
GROUP BY p.product_id, p.product_name, p.category
HAVING ROUND(
        (SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END) -
        SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -2, GETDATE())
            AND f.order_date < DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END)) * 100.0 /
        NULLIF(SUM(CASE WHEN f.order_date >= DATEADD(MONTH, -2, GETDATE())
            AND f.order_date < DATEADD(MONTH, -1, GETDATE())
            THEN f.sales_amount ELSE 0 END), 0),
        2
    ) IS NOT NULL
ORDER BY growth_percent DESC;
```

**Use Case:** Identify growth opportunities and declining products

---

### **3. Fulfillment & Delivery Analytics**

#### 3.1 Daily Fulfillment Performance Dashboard

```sql
SELECT TOP 30
    order_date,
    total_orders,
    on_time_orders,
    late_orders,
    on_time_delivery_rate,
    ROUND(AVG(CAST(avg_shipping_delay_days AS FLOAT)) OVER
        (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2)
        AS avg_delay_7day_ma,
    daily_revenue
FROM gold.fulfillment_metrics
WHERE order_date >= DATEADD(DAY, -30, GETDATE())
ORDER BY order_date DESC;
```

**Use Case:** Daily operational monitoring

---

#### 3.2 Monthly On-Time Delivery Trend

```sql
SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    SUM(total_orders) AS monthly_orders,
    SUM(on_time_orders) AS on_time_orders,
    SUM(late_orders) AS late_orders,
    ROUND(100.0 * SUM(on_time_orders) / NULLIF(SUM(total_orders), 0), 2)
        AS on_time_rate,
    ROUND(AVG(CAST(avg_shipping_delay_days AS FLOAT)), 2)
        AS avg_shipping_delay
FROM gold.fulfillment_metrics
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year DESC, month DESC;
```

**Output Example:**

```
Year  Month  Orders  OnTime  Late  OnTimeRate  AvgDelay
2025  10     1,250   1,187   63    94.96%      -0.5 days
2025  9      1,100   1,034   66    93.82%      +0.2 days
2025  8      980     872     108   88.98%      +1.5 days
```

**Use Case:** Track SLA compliance over time

---

#### 3.3 Late Orders Analysis

```sql
SELECT TOP 20
    fs.order_number,
    dc.first_name + ' ' + dc.last_name AS customer_name,
    dp.product_name,
    fs.order_date,
    fs.shipping_date,
    fs.due_date,
    fs.shipping_delay_days,
    fs.sales_amount,
    dp.category
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
WHERE fs.shipping_delay_days > 0
ORDER BY fs.shipping_delay_days DESC;
```

**Use Case:** Investigate specific late deliveries

---

### **4. Revenue & Profitability Analysis**

#### 4.1 Total Revenue & Profit Dashboard

```sql
SELECT
    CAST(COUNT(DISTINCT fs.order_number) AS NVARCHAR) + ' Orders' AS metric,
    CAST(SUM(fs.sales_amount) AS NVARCHAR) + ' Revenue' AS value
FROM gold.fact_sales fs
UNION ALL
SELECT
    'Total Profit',
    CAST(SUM(fs.profit) AS NVARCHAR)
FROM gold.fact_sales fs
UNION ALL
SELECT
    'Avg Profit Margin %',
    CAST(ROUND(SUM(fs.profit) * 100.0 / NULLIF(SUM(fs.sales_amount), 0), 2) AS NVARCHAR)
FROM gold.fact_sales fs;
```

---

#### 4.2 Revenue by Customer Segment

```sql
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS num_customers,
    SUM(total_orders) AS total_orders,
    SUM(total_sales) AS segment_revenue,
    SUM(total_profit) AS segment_profit,
    ROUND(100.0 * SUM(total_profit) / NULLIF(SUM(total_sales), 0), 2) AS profit_margin_percent
FROM gold.customer_metrics
GROUP BY customer_segment
ORDER BY segment_revenue DESC;
```

---

#### 4.3 Revenue by Order Value Category

```sql
SELECT
    order_value_category,
    COUNT(DISTINCT order_number) AS order_count,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(100.0 * SUM(profit) / NULLIF(SUM(sales_amount), 0), 2) AS profit_margin_percent,
    ROUND(AVG(sales_amount), 2) AS avg_order_value
FROM gold.fact_sales
WHERE order_value_category IS NOT NULL
GROUP BY order_value_category
ORDER BY total_revenue DESC;
```

---

#### 4.4 Weekly Revenue Trend (Last 12 Weeks)

```sql
SELECT
    DATEPART(WEEK, fs.order_date) AS week_num,
    YEAR(fs.order_date) AS year_num,
    MIN(fs.order_date) AS week_start,
    MAX(fs.order_date) AS week_end,
    COUNT(DISTINCT fs.order_number) AS weekly_orders,
    SUM(fs.sales_amount) AS weekly_revenue,
    SUM(fs.profit) AS weekly_profit
FROM gold.fact_sales fs
WHERE fs.order_date >= DATEADD(WEEK, -12, GETDATE())
GROUP BY DATEPART(WEEK, fs.order_date), YEAR(fs.order_date)
ORDER BY year_num DESC, week_num DESC;
```

---

### **5. Category Performance**

#### 5.1 Full Category Analysis

```sql
SELECT
    category,
    order_count,
    total_revenue,
    total_profit,
    profit_margin_percent,
    avg_order_value,
    ROUND(100.0 * total_revenue /
        (SELECT SUM(total_revenue) FROM gold.revenue_by_category), 2)
        AS revenue_pct_of_total
FROM gold.revenue_by_category
ORDER BY total_revenue DESC;
```

---

#### 5.2 Compare Categories (Revenue vs Profit)

```sql
SELECT
    category,
    total_revenue,
    ROUND(100.0 * total_revenue /
        (SELECT SUM(total_revenue) FROM gold.revenue_by_category), 2)
        AS revenue_pct,
    total_profit,
    ROUND(100.0 * total_profit /
        (SELECT SUM(total_profit) FROM gold.revenue_by_category), 2)
        AS profit_pct,
    profit_margin_percent
FROM gold.revenue_by_category
ORDER BY total_revenue DESC;
```

**Use Case:** Identify categories where revenue ≠ profit (margin mismatch)

---

## 🔍 Advanced Analytics

### **6.1 RFM (Recency, Frequency, Monetary) Analysis**

```sql
-- Identify best customers using RFM model
SELECT
    customer_id,
    first_name + ' ' + last_name AS customer_name,
    DATEDIFF(DAY, last_purchase_date, GETDATE()) AS recency_days,
    total_orders AS frequency,
    total_sales AS monetary,
    CASE
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) <= 30
         AND total_orders >= 5
         AND total_sales > 10000 THEN 'Champions'
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) <= 90
         AND total_orders >= 3 THEN 'Loyal'
        WHEN total_orders = 1 THEN 'New'
        WHEN DATEDIFF(DAY, last_purchase_date, GETDATE()) > 180 THEN 'At Risk'
        ELSE 'Potential'
    END AS customer_value_segment
FROM gold.customer_metrics
ORDER BY total_sales DESC;
```

---

### **6.2 Product Cross-Sell Opportunities**

```sql
-- Products frequently bought together
WITH product_pairs AS (
    SELECT
        f1.product_key AS product1_key,
        f2.product_key AS product2_key,
        COUNT(DISTINCT CONCAT(f1.order_number, f2.order_number)) AS times_together
    FROM gold.fact_sales f1
    INNER JOIN gold.fact_sales f2
        ON f1.order_number = f2.order_number
        AND f1.product_key < f2.product_key
    GROUP BY f1.product_key, f2.product_key
)
SELECT TOP 20
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    pp.times_together
FROM product_pairs pp
LEFT JOIN gold.dim_products p1 ON pp.product1_key = p1.product_key
LEFT JOIN gold.dim_products p2 ON pp.product2_key = p2.product_key
WHERE pp.times_together > 0
ORDER BY pp.times_together DESC;
```

**Use Case:** Bundle/cross-sell recommendations

---

## 📊 Recommended Visualizations

| Metric                        | Chart Type     | Filters                 |
| ----------------------------- | -------------- | ----------------------- |
| Revenue by Category           | Bar/Pie        | Date range              |
| Time Trend Revenue            | Line           | Category, Year          |
| Customer Segment Distribution | Donut          | -                       |
| Top 10 Products               | Horizontal Bar | Category                |
| On-Time % Trend               | Line with KPI  | Date range              |
| Profit Margin by Product      | Scatter        | -                       |
| Geographic Distribution       | Map            | (if location available) |

---

## 💡 Tips & Best Practices

1. **Use Views, Not Tables:** Always query Gold/Silver views, not Bronze
2. **Filter by Date:** Add date filters to all time-series queries
3. **Handle NULLs:** Use `ISNULL()` or `COALESCE()` for safety
4. **Aggregate Appropriately:** Use `SUM()` for sales, `AVG()` for rates
5. **Label Clearly:** Use `AS` aliases for report readability

---

## 📁 Query Repository

Save these queries to your **shared drive** or **SQL Server Agent** jobs for regular reporting.

**Example Schedule:**

- Daily: Fulfillment metrics, revenue
- Weekly: Customer/product performance
- Monthly: Full category analysis, trend reports

---

**Document Version:** 1.0  
**Last Updated:** March 22, 2026  
**Next Update:** Q2 2026 (based on user feedback)
