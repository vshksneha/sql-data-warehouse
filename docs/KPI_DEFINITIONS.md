# E-Commerce Data Warehouse - KPI Definitions

**Purpose:** Define all Key Performance Indicators (KPIs) with calculations, interpretation, and business use cases  
**Audience:** Business Analysts, Data Scientists, Decision Makers  
**Update Frequency:** As business requirements evolve

---

## 📊 KPI Index

1. [Customer KPIs](#customer-kpis)
2. [Product KPIs](#product-kpis)
3. [Financial KPIs](#financial-kpis)
4. [Fulfillment KPIs](#fulfillment-kpis)
5. [Category KPIs](#category-kpis)

---

## 👥 Customer KPIs

### **1.1 Total Orders**

**Definition:** The total number of distinct orders placed by a customer  
**Formula:** `COUNT(DISTINCT order_number)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales
GROUP BY customer_id;
```

**Interpretation:**

- **High (>10 orders):** Loyal, repeat customer
- **Medium (3-10 orders):** Regular customer
- **Low (1-2 orders):** Occasional customer

**Business Use:** Identify high-activity customers for retention programs

---

### **1.2 Total Sales Amount**

**Definition:** The sum of all sales revenue from a customer  
**Formula:** `SUM(sales_amount)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
GROUP BY customer_id;
```

**Interpretation:**

- **VIP Tier:** > $100,000
- **Premium Tier:** $50,000 - $100,000
- **Standard Tier:** < $50,000

**Business Use:** Customer lifetime value (CLV) analysis, tier classification

---

### **1.3 Total Profit**

**Definition:** The total profit (margin) generated from all customer orders  
**Formula:** `SUM(profit_amount)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.customer_metrics`

**Calculation (from Silver):**

```
profit_amount = sales_amount - (product_cost × quantity)
```

**Example:**

```
Order 1: Sales = $1000, Cost = 100×$5 = $500, Profit = $500
Order 2: Sales = $2000, Cost = 200×$4 = $800, Profit = $1200
Total Profit = $1700
```

**Interpretation:**

- **High profit:** High-margin customer (valuable)
- **Low/Negative:** Loss-making customer (review needed)

**Business Use:** Profitability analysis, customer segmentation

---

### **1.4 Average Order Value (AOV)**

**Definition:** The average value per order for a customer  
**Formula:** `AVG(sales_amount)` or `SUM(sales_amount) / COUNT(DISTINCT order_number)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    SUM(sales_amount) / COUNT(DISTINCT order_number) AS avg_order_value
FROM gold.fact_sales
GROUP BY customer_id;
```

**Interpretation:**

- **High AOV (>$500):** Premium customer, higher order values
- **Medium AOV ($100-$500):** Regular customer
- **Low AOV (<$100):** Price-sensitive customer

**Business Use:** Pricing strategy, cross-sell opportunities

---

### **1.5 Last Purchase Date**

**Definition:** The most recent date a customer placed an order  
**Formula:** `MAX(order_date)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    MAX(order_date) AS last_purchase_date,
    DATEDIFF(DAY, MAX(order_date), GETDATE()) AS days_since_purchase
FROM gold.fact_sales
GROUP BY customer_id;
```

**Interpretation:**

- **Recent (< 30 days):** Active customer
- **Moderate (30-90 days):** Cooling off
- **Inactive (> 90 days):** At-risk customer

**Business Use:** Customer engagement, win-back campaigns

---

### **1.6 Customer Segment**

**Definition:** Tiered classification of customer value  
**Formula:**

```
IF total_sales > 100,000 THEN 'VIP'
ELSE IF total_sales > 50,000 THEN 'Premium'
ELSE 'Standard'
```

**Data Source:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    total_sales,
    CASE
        WHEN total_sales > 100000 THEN 'VIP'
        WHEN total_sales > 50000 THEN 'Premium'
        ELSE 'Standard'
    END AS segment
FROM gold.customer_metrics;
```

**Interpretation:**

- **VIP:** Top 5-10% of revenue, requires white-glove service
- **Premium:** 20-30% of revenue, targeted offers
- **Standard:** Base of customers, general marketing

**Business Use:** Targeted marketing, resource allocation, retention budgeting

---

### **1.7 Profit Margin %**

**Definition:** Percentage profit relative to sales revenue  
**Formula:** `(SUM(profit) / SUM(sales_amount)) × 100`  
**Data Source:** `gold.customer_metrics`

**SQL:**

```sql
SELECT
    customer_id,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales_amount), 0), 2)
        AS profit_margin_percent
FROM gold.fact_sales f
GROUP BY customer_id;
```

**Example:**

```
Sales: $10,000
Cost: $6,000
Profit: $4,000
Margin: (4000 / 10000) × 100 = 40%
```

**Interpretation:**

- **>30%:** High margin, healthy profitability
- **15-30%:** Acceptable
- **<15%:** Low margin, review pricing

**Business Use:** Profitability assessment, pricing optimization

---

## 📦 Product KPIs

### **2.1 Units Sold**

**Definition:** Total number of orders (units) for a product  
**Formula:** `COUNT(DISTINCT order_number)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.product_metrics`

**Interpretation:**

- **High (>100):** Best-seller, high demand
- **Medium (10-100):** Popular product
- **Low (<10):** Niche/slow-moving

**Business Use:** Inventory management, demand forecasting

---

### **2.2 Product Revenue**

**Definition:** Total sales revenue from a product  
**Formula:** `SUM(sales_amount)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.product_metrics`

**Interpretation:**

- Measure of product market contribution
- Used for revenue concentration analysis

**Business Use:** Revenue attribution, product portfolio analysis

---

### **2.3 Product Profit**

**Definition:** Total profit contribution from a product  
**Formula:** `SUM(profit_amount)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.product_metrics`

**Interpretation:**

- **Higher profit:** More valuable to business (despite lower sales)
- May indicate higher margins or premium positioning

**Business Use:** Profitability ranking, product viability assessment

---

### **2.4 Average Sale Price (ASP)**

**Definition:** Average price per sale for a product  
**Formula:** `AVG(sales_amount)` or `SUM(sales_amount) / COUNT(DISTINCT order_number)`  
**Data Source:** `gold.fact_sales`  
**View:** `gold.product_metrics`

**Interpretation:**

- **High ASP:** Premium product, lower volume, higher margins
- **Low ASP:** Commodity product, high volume, thin margins

**Business Use:** Pricing strategy, product mix planning

---

### **2.5 Product Cost**

**Definition:** Cost of goods sold (COGS) for a product  
**Formula:** Sourced from `gold.dim_products.cost`  
**Data Source:** Bronze/Silver product tables  
**View:** `gold.product_metrics`

**Interpretation:**

- Base cost for margin calculation
- Used to identify cost reduction opportunities

**Business Use:** Supplier negotiations, cost management

---

### **2.6 Product Profit Margin %**

**Definition:** Percentage profit margin for a product  
**Formula:** `(SUM(profit) / SUM(sales_amount)) × 100`  
**Data Source:** `gold.product_metrics`

**SQL:**

```sql
SELECT
    product_id,
    product_name,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(sales_amount), 0), 2)
        AS profit_margin_percent
FROM gold.fact_sales
GROUP BY product_id, product_name;
```

**Example:**

```
Product: Bike X
Revenue: $50,000
Cost: $35,000
Profit: $15,000
Margin: (15000 / 50000) × 100 = 30%
```

**Interpretation:**

- **>40%:** High margin, premium product
- **20-40%:** Standard margin
- **<20%:** Low margin, consider discontinuing

**Business Use:** Product profitability, margin optimization

---

### **2.7 Revenue Rank by Category**

**Definition:** Ranking of product revenue within its category  
**Formula:** `RANK() OVER (PARTITION BY category ORDER BY SUM(sales_amount) DESC)`  
**Data Source:** `gold.product_metrics`

**Interpretation:**

- **Rank 1:** Top product in category
- **Rank 2-3:** Strong performers
- **Rank 4+:** Underperformers or niche products

**Business Use:** Category strategy, promotional focus, inventory allocation

---

## 💰 Financial KPIs

### **3.1 Total Order Value (TOV)**

**Definition:** Classification of order size for business value  
**Formula:**

```
IF sales_amount > 10,000 THEN 'High-Value'
ELSE IF sales_amount >= 5,000 THEN 'Medium-Value'
ELSE 'Standard'
```

**Interpretation:**

- **High-Value (>$10K):** Premium orders, VIP customers
- **Medium-Value ($5-10K):** Quality orders, growth opportunity
- **Standard (<$5K):** Volume orders, broad market

**Business Use:** Order prioritization, fulfillment routing, customer targeting

---

### **3.2 Revenue by Category**

**Definition:** Total sales revenue by product category  
**Formula:** `SUM(sales_amount)` grouped by category  
**Data Source:** `gold.revenue_by_category` view

**Interpretation:**

- Identifies revenue concentration
- Shows category performance

**Example:**

```
Mountain Bikes: $500,000 (45%)
Road Bikes:    $400,000 (36%)
Accessories:   $200,000 (19%)
```

**Business Use:** Category strategy, marketing budget allocation

---

### **3.3 Profit by Category**

**Definition:** Total profit contribution by category  
**Formula:** `SUM(profit_amount)` grouped by category  
**Data Source:** `gold.revenue_by_category` view

**Interpretation:**

- May differ significantly from revenue
- Shows true profitability, not just sales volume

**Business Use:** Margin optimization, product mix decisions

---

### **3.4 Category Profit Margin %**

**Definition:** Overall profitability by category  
**Formula:** `(SUM(profit) / SUM(sales_amount)) × 100` by category  
**Data Source:** `gold.revenue_by_category` view

**Interpretation:**

- **High margin categories:** Prioritize in portfolio
- **Low margin categories:** Improve efficiency or exit

**Business Use:** Category profitability assessment, strategic review

---

## 🚚 Fulfillment KPIs

### **4.1 On-Time Delivery Rate %**

**Definition:** Percentage of orders delivered by due date  
**Formula:** `(orders with shipping_delay ≤ 0) / total_orders × 100`  
**Data Source:** `gold.fulfillment_metrics` view

**Calculation (from Silver):**

```
shipping_delay_days = due_date - ship_date
IF shipping_delay_days ≤ 0 THEN On-Time
ELSE Late
```

**SQL:**

```sql
SELECT
    order_date,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN shipping_delay_days <= 0 THEN 1 ELSE 0 END) AS on_time_orders,
    ROUND(
        SUM(CASE WHEN shipping_delay_days <= 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS on_time_delivery_rate
FROM gold.fact_sales
GROUP BY order_date;
```

**Interpretation:**

- **>95%:** Excellent service, industry-leading
- **85-95%:** Good performance, acceptable
- **<85%:** Poor performance, needs improvement

**Business Use:** SLA tracking, logistics optimization, customer satisfaction

---

### **4.2 Average Shipping Delay (Days)**

**Definition:** Average number of days between ship date and due date  
**Formula:** `AVG(shipping_delay_days)`  
**Data Source:** `gold.fulfillment_metrics` view

**Interpretation:**

- **Negative value:** Orders shipped early (good)
- **Zero:** Exactly on time (excellent)
- **Positive value:** Orders shipped late (problem)

**Example:**

```
Avg Shipping Delay: +2.5 days
= Orders are delivered 2.5 days LATE on average
```

**Business Use:** Logistics assessment, carrier performance evaluation

---

### **4.3 Late Orders Count**

**Definition:** Number of orders delivered after due date  
**Formula:** `COUNT(*) WHERE shipping_delay_days > 0`  
**Data Source:** `gold.fulfillment_metrics` view

**Interpretation:**

- Identifies fulfillment problematic periods
- Input for root cause analysis

**Business Use:** Operational reporting, quality metrics tracking

---

### **4.4 Daily Revenue**

**Definition:** Total sales revenue per day  
**Formula:** `SUM(sales_amount)` by order_date  
**Data Source:** `gold.fulfillment_metrics` view

**Interpretation:**

- Revenue trending
- Seasonal pattern identification

**Business Use:** Daily KPI tracking, forecasting accuracy

---

## 📈 Category KPIs

### **5.1 Category Order Count**

**Definition:** Total number of orders for a category  
**Formula:** `COUNT(DISTINCT order_number)` by category  
**Data Source:** `gold.revenue_by_category` view

**Interpretation:**

- Order volume by category
- Demand distribution

---

### **5.2 Category Average Order Value**

**Definition:** Average order value within a category  
**Formula:** `SUM(sales_amount) / COUNT(DISTINCT order_number)` by category  
**Data Source:** `gold.revenue_by_category` view

**Interpretation:**

- Price positioning per category
- Customer spending behavior by category

**Example:**

```
Mountain Bikes:  $800 AOV (premium)
Accessories:     $200 AOV (budget)
```

---

## 🎯 Recommended KPI Dashboards

### **Executive Dashboard**

- Total Revenue (vs target)
- Total Profit & Margin %
- Customer Count & Segments
- On-Time Delivery %
- Top 5 Customers by Revenue
- Top 5 Products by Revenue

### **Operations Dashboard**

- Daily Order Count
- Daily Revenue
- On-Time Delivery Rate
- Avg Shipping Delay
- Late Orders Count
- Orders by Value Category

### **Product Management Dashboard**

- Revenue by Category
- Profit by Category
- Top Products by Units Sold
- Product Margin Distribution
- Category Profit Margin Trend

### **Customer Analytics Dashboard**

- Customer Count by Segment
- Average Revenue per Customer
- Customer Acquisition vs Attrition
- Top 10 Customers
- Repeat Order Rate

---

## 📝 KPI Calculation Notes

- **All calculations use Silver/Gold layer data** (cleansed and validated)
- **Dates are in YYYY-MM-DD format** (standardized in Silver)
- **Currency values are in numeric format** (no $ symbols)
- **Divisions by zero are handled** using `NULLIF()` to prevent errors
- **All percentages rounded to 2 decimal places**
- **Views are dynamic** and query current data (no static snapshots)

---

## 🔄 KPI Refresh Frequency

| KPI                    | Refresh Frequency  | Owner            |
| ---------------------- | ------------------ | ---------------- |
| Daily Revenue & Orders | Real-time (hourly) | Operations       |
| On-Time Delivery %     | Daily              | Logistics        |
| Customer Metrics       | Weekly             | Sales            |
| Product Performance    | Weekly             | Product Mgmt     |
| Category Analysis      | Monthly            | Business Analyst |
| Profit Analysis        | Monthly            | Finance          |

---

**Document Version:** 1.0  
**Last Updated:** March 22, 2026  
**Next Review:** Q2 2026 (post stakeholder feedback)
