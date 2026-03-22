# E-Commerce Data Warehouse - Complete Data Catalog

## Overview

This catalog documents all data objects across the three layers of the medallion architecture:

- **Bronze Layer** (6 tables): Raw data from CSV sources - no transformations
- **Silver Layer** (6 tables): Cleansed & enriched data with business logic
- **Gold Layer** (7 views): Analytics-ready aggregations and dimensions

---

## 📊 Layer Overview

| Layer      | Purpose                    | Object Count | Update Frequency      |
| ---------- | -------------------------- | ------------ | --------------------- |
| **Bronze** | Raw data repository        | 6 tables     | Daily BULK INSERT     |
| **Silver** | Cleansing & business logic | 6 tables     | Daily processing      |
| **Gold**   | Analytics-ready views      | 7 views      | Query-time generation |

---

# 🟫 BRONZE LAYER (Raw Data)

Source: CSV files in `/datasets/source_crm/` and `/datasets/source_erp/`

## bronze.customers

**Source:** `source_crm/cust_info.csv`  
**Purpose:** Raw customer demographic data  
**Load Method:** BULK INSERT  
**Records:** 19,000+

| Column          | Type          | Source Field   | Notes                        |
| --------------- | ------------- | -------------- | ---------------------------- |
| customer_id     | INT           | cust_id        | Unique customer identifier   |
| customer_number | NVARCHAR(50)  | cust_number    | Human-readable customer code |
| first_name      | NVARCHAR(50)  | first_name     | Customer first name          |
| last_name       | NVARCHAR(50)  | last_name      | Customer last name           |
| email_address   | NVARCHAR(100) | email          | Email contact                |
| country         | NVARCHAR(50)  | country        | Country of residence         |
| marital_status  | NVARCHAR(50)  | marital_status | M/S/D/etc                    |
| gender          | NVARCHAR(50)  | gender         | M/F/N                        |
| birthdate       | DATE          | birthdate      | Birth date                   |
| created_at      | DATETIME      | created_at     | Record creation timestamp    |

---

## bronze.products

**Source:** `source_crm/prd_info.csv`  
**Purpose:** Raw product catalog  
**Records:** 200+

| Column               | Type          | Source Field | Notes                                  |
| -------------------- | ------------- | ------------ | -------------------------------------- |
| product_id           | INT           | prd_id       | Unique product identifier              |
| product_number       | NVARCHAR(50)  | prd_number   | Product SKU                            |
| product_name         | NVARCHAR(100) | prd_name     | Product description                    |
| category_id          | NVARCHAR(50)  | cat_id       | Category code                          |
| category             | NVARCHAR(50)  | category     | Category name (Bikes, Components, etc) |
| subcategory          | NVARCHAR(50)  | subcategory  | Product subcategory                    |
| cost                 | DECIMAL(10,2) | cost         | Unit cost                              |
| product_line         | NVARCHAR(50)  | prod_line    | Road/Mountain/Hybrid                   |
| start_date           | DATE          | start_date   | Product launch date                    |
| maintenance_required | NVARCHAR(20)  | maintenance  | Y/N                                    |

---

## bronze.sales_details

**Source:** `source_crm/sales_details.csv`  
**Purpose:** Raw sales transaction data  
**Records:** 18,000+

| Column        | Type          | Source Field | Notes                    |
| ------------- | ------------- | ------------ | ------------------------ |
| order_number  | NVARCHAR(50)  | order_id     | Unique order identifier  |
| customer_id   | INT           | cust_id      | Customer reference       |
| product_id    | INT           | prd_id       | Product reference        |
| order_date    | DATE          | order_date   | When order was placed    |
| shipping_date | DATE          | ship_date    | When order shipped       |
| due_date      | DATE          | due_date     | When order should arrive |
| sales_amount  | DECIMAL(10,2) | sales_amt    | Total order value        |
| quantity      | INT           | qty          | Units ordered            |
| unit_price    | DECIMAL(10,2) | unit_price   | Price per unit           |

---

## bronze.CUST_AZ12 (ERP Customer Data)

**Source:** `source_erp/CUST_AZ12.csv`  
**Purpose:** Customer data from ERP system (supplementary)  
**Records:** 15,000+

| Column       | Type          | Notes                      |
| ------------ | ------------- | -------------------------- |
| CUST_ID      | INT           | ERP customer ID            |
| CUST_NAME    | NVARCHAR(100) | Customer full name         |
| CUST_COUNTRY | NVARCHAR(50)  | ERP country field          |
| CREDIT_LIMIT | DECIMAL(12,2) | Customer credit limit      |
| CUST_SINCE   | DATE          | Account establishment date |

---

## bronze.LOC_A101 (ERP Location Data)

**Source:** `source_erp/LOC_A101.csv`  
**Purpose:** Geographic/warehouse location data  
**Records:** 40+

| Column        | Type          | Notes                   |
| ------------- | ------------- | ----------------------- |
| LOC_ID        | INT           | Location identifier     |
| LOCATION_NAME | NVARCHAR(100) | Warehouse/facility name |
| CITY          | NVARCHAR(50)  | City name               |
| COUNTRY       | NVARCHAR(50)  | Country code            |
| TIMEZONE      | NVARCHAR(50)  | Timezone offset         |

---

## bronze.PX_CAT_G1V2 (ERP Category/Pricing Data)

**Source:** `source_erp/PX_CAT_G1V2.csv`  
**Purpose:** Product category and pricing from ERP  
**Records:** 100+

| Column           | Type          | Notes                |
| ---------------- | ------------- | -------------------- |
| CAT_ID           | INT           | Category code        |
| CAT_NAME         | NVARCHAR(100) | Category description |
| SUBCATID         | INT           | Subcategory ID       |
| AVG_MARGIN_PCT   | DECIMAL(5,2)  | Expected margin %    |
| DISCOUNT_ALLOWED | DECIMAL(5,2)  | Max discount %       |

---

---

# 🟩 SILVER LAYER (Cleansed & Enhanced)

Transformations applied: Data validation, standardization, business logic addition

## silver.customers

**Source:** bronze.customers + bronze.CUST_AZ12 (LEFT JOIN)  
**Purpose:** Cleansed customer dimension with validation  
**Records:** 19,000+

| Column          | Type          | Transformation              | Example              |
| --------------- | ------------- | --------------------------- | -------------------- |
| customer_id     | INT           | No change                   | 1001                 |
| customer_number | NVARCHAR(50)  | No change                   | CUST-001-AZ          |
| first_name      | NVARCHAR(50)  | UPPER() + TRIM()            | JOHN                 |
| last_name       | NVARCHAR(50)  | UPPER() + TRIM()            | SMITH                |
| email_address   | NVARCHAR(100) | LOWER()                     | john.smith@email.com |
| country         | NVARCHAR(50)  | Standardized                | Australia            |
| marital_status  | NVARCHAR(50)  | Coalesced from both sources | Married              |
| gender          | NVARCHAR(50)  | M/F/Unknown                 | Male                 |
| birthdate       | DATE          | Validated                   | 1975-06-15           |
| credit_limit    | DECIMAL(12,2) | **NEW: From ERP**           | 50000.00             |
| account_active  | BIT           | **NEW: Calculated**         | 1 (if before today)  |
| created_at      | DATETIME      | No change                   | 2024-01-15 12:30:00  |

---

## silver.products

**Source:** bronze.products + bronze.PX_CAT_G1V2  
**Purpose:** Cleansed product dimension with pricing rules  
**Records:** 200+

| Column         | Type          | Transformation                  | Example          |
| -------------- | ------------- | ------------------------------- | ---------------- |
| product_id     | INT           | No change                       | 500              |
| product_number | NVARCHAR(50)  | UPPER()                         | BK-M123-45       |
| product_name   | NVARCHAR(100) | TRIM()                          | Mountain Bike XL |
| category_id    | NVARCHAR(50)  | No change                       | CAT-02           |
| category       | NVARCHAR(50)  | Standardized                    | Mountain Bikes   |
| subcategory    | NVARCHAR(50)  | Standardized                    | Hardtail         |
| cost           | DECIMAL(10,2) | Validated                       | 450.00           |
| list_price     | DECIMAL(10,2) | **NEW: Calculated from margin** | 900.00           |
| margin_percent | DECIMAL(5,2)  | **NEW: From ERP**               | 50.00            |
| product_line   | NVARCHAR(50)  | Standardized                    | Mountain         |
| active         | BIT           | **NEW: start_date <= today**    | 1                |
| created_at     | DATETIME      | No change                       | 2023-01-01       |

---

## silver.sales_transactions

**Source:** bronze.sales_details  
**Purpose:** Cleansed, enriched sales with business logic  
**Records:** 18,000+  
**📌 CRITICAL: New Business Logic Columns Added**

| Column                    | Type          | Transformation                                    | Example             |
| ------------------------- | ------------- | ------------------------------------------------- | ------------------- |
| order_number              | NVARCHAR(50)  | UPPER()                                           | SO-54496            |
| customer_id               | INT           | No change                                         | 1001                |
| product_id                | INT           | No change                                         | 500                 |
| order_date                | DATE          | Validated                                         | 2025-03-15          |
| shipping_date             | DATE          | Validated                                         | 2025-03-17          |
| due_date                  | DATE          | Validated                                         | 2025-03-25          |
| sales_amount              | DECIMAL(10,2) | Validated                                         | 1200.00             |
| quantity                  | INT           | Validated                                         | 2                   |
| unit_price                | DECIMAL(10,2) | Validated                                         | 600.00              |
| **profit_amount**         | DECIMAL(10,2) | **NEW: sales_amount - (product_cost × quantity)** | 300.00              |
| **profit_margin_percent** | DECIMAL(5,2)  | **NEW: (profit / sales_amount) × 100**            | 25.00               |
| **shipping_delay_days**   | INT           | **NEW: DATEDIFF(DAY, due_date, shipping_date)**   | 0                   |
| **shipped_on_time**       | BIT           | **NEW: shipping_delay_days <= 0**                 | 1                   |
| **order_value_category**  | NVARCHAR(20)  | **NEW: High/Medium/Standard**                     | Medium              |
| created_at                | DATETIME      | No change                                         | 2025-03-15 10:30:00 |

---

## silver.locations

**Source:** bronze.LOC_A101  
**Purpose:** Cleansed warehouse/fulfillment location data  
**Records:** 40+

| Column        | Type          | Transformation   | Example          |
| ------------- | ------------- | ---------------- | ---------------- |
| location_id   | INT           | No change        | 101              |
| location_name | NVARCHAR(100) | UPPER() + TRIM() | SYDNEY WAREHOUSE |
| city          | NVARCHAR(50)  | Standardized     | Sydney           |
| country       | NVARCHAR(50)  | Standardized     | Australia        |
| timezone      | NVARCHAR(50)  | Validated        | AEDT             |

---

## silver.product_categories

**Source:** bronze.PX_CAT_G1V2  
**Purpose:** Cleansed category master  
**Records:** 50+

| Column             | Type          | Transformation | Example        |
| ------------------ | ------------- | -------------- | -------------- |
| category_id        | INT           | No change      | 2              |
| category_name      | NVARCHAR(100) | UPPER()        | MOUNTAIN BIKES |
| subcategory_id     | INT           | No change      | 21             |
| subcategory_name   | NVARCHAR(100) | UPPER()        | HARDTAIL       |
| avg_margin_percent | DECIMAL(5,2)  | Validated      | 45.50          |
| discount_allowed   | DECIMAL(5,2)  | Validated      | 15.00          |

---

## silver.data_quality_log

**Source:** Generated during ETL  
**Purpose:** Track data quality issues and rejections  
**Records:** Updated daily

| Column      | Type          | Description                |
| ----------- | ------------- | -------------------------- |
| log_id      | INT           | Auto-increment             |
| table_name  | NVARCHAR(50)  | Table affected             |
| error_type  | NVARCHAR(100) | Validation error           |
| error_count | INT           | Number of records affected |
| logged_at   | DATETIME      | When logged                |

---

---

# 🟨 GOLD LAYER (Analytics-Ready Views)

All views are **queried in real-time** from Silver layer - no materialized copies.

## gold.dim_customers

**Purpose:** Customer dimension for analytics  
**Source view:** silver.customers with aggregates  
**Records:** 19,000+ (one per customer)

| Column         | Type         | Source           | Description          | Example    |
| -------------- | ------------ | ---------------- | -------------------- | ---------- |
| customer_key   | INT          | Surrogate        | Unique analytics key | 1          |
| customer_id    | INT          | silver.customers | Business key         | 1001       |
| first_name     | NVARCHAR(50) | silver.customers | Customer first name  | JOHN       |
| last_name      | NVARCHAR(50) | silver.customers | Customer last name   | SMITH      |
| country        | NVARCHAR(50) | silver.customers | Country of residence | Australia  |
| marital_status | NVARCHAR(50) | silver.customers | M/S/D/W              | Married    |
| gender         | NVARCHAR(50) | silver.customers | M/F/Unknown          | Male       |
| birthdate      | DATE         | silver.customers | Date of birth        | 1975-06-15 |
| create_date    | DATE         | silver.customers | Record creation      | 2024-01-15 |

---

## gold.dim_products

**Purpose:** Product dimension for analytics  
**Source:** silver.products  
**Records:** 200+ (one per product)

| Column         | Type          | Source          | Description          | Example          |
| -------------- | ------------- | --------------- | -------------------- | ---------------- |
| product_key    | INT           | Surrogate       | Unique analytics key | 1                |
| product_id     | INT           | silver.products | Business key         | 500              |
| product_number | NVARCHAR(50)  | silver.products | Product SKU          | BK-M123-45       |
| product_name   | NVARCHAR(100) | silver.products | Product description  | Mountain Bike XL |
| category_id    | NVARCHAR(50)  | silver.products | Category code        | CAT-02           |
| category       | NVARCHAR(50)  | silver.products | Category name        | Mountain Bikes   |
| subcategory    | NVARCHAR(50)  | silver.products | Subcategory          | Hardtail         |
| cost           | DECIMAL(10,2) | silver.products | Product cost         | 450.00           |
| product_line   | NVARCHAR(50)  | silver.products | Product line         | Mountain         |
| start_date     | DATE          | silver.products | Launch date          | 2023-01-01       |
| maintenance    | NVARCHAR(20)  | silver.products | Maintenance required | No               |

---

## gold.fact_sales

**Purpose:** Fact table - transactional sales data  
**Source:** silver.sales_transactions JOIN silver.customers JOIN silver.products  
**Records:** 18,000+  
**📌 Contains all business logic columns (profit, delays, categories)**

| Column                   | Type          | Purpose                                | Example    |
| ------------------------ | ------------- | -------------------------------------- | ---------- |
| **Keys**                 |               |                                        |            |
| order_number             | NVARCHAR(50)  | Order identifier                       | SO-54496   |
| customer_key             | INT           | Customer dimension link                | 1          |
| product_key              | INT           | Product dimension link                 | 1          |
| **Dates**                |               |                                        |            |
| order_date               | DATE          | When order placed                      | 2025-03-15 |
| shipping_date            | DATE          | When order shipped                     | 2025-03-17 |
| due_date                 | DATE          | When order due                         | 2025-03-25 |
| **Measures**             |               |                                        |            |
| sales_amount             | DECIMAL(10,2) | Order total $                          | 1200.00    |
| quantity                 | INT           | Units ordered                          | 2          |
| unit_price               | DECIMAL(10,2) | Price per unit                         | 600.00     |
| **Business Logic (NEW)** |               |                                        |            |
| profit                   | DECIMAL(10,2) | sales_amount - (cost × qty)            | 300.00     |
| profit_margin_pct        | DECIMAL(5,2)  | (profit / sales_amount) × 100          | 25.00      |
| shipping_delay_days      | INT           | DATEDIFF(DAY, due_date, shipping_date) | 0          |
| shipped_on_time          | BIT           | 1 if delay_days <= 0                   | 1          |
| order_value_category     | NVARCHAR(20)  | High/Medium/Standard                   | Medium     |

---

## gold.customer_metrics

**Purpose:** Customer-level KPIs for analysis  
**Source:** Aggregated from fact_sales + dim_customers  
**Records:** 19,000+ (one per customer)  
**Refresh:** Query-time (real-time)

| Column                | Type          | Calculation                           | Example    |
| --------------------- | ------------- | ------------------------------------- | ---------- |
| customer_id           | INT           | From dim_customers                    | 1001       |
| first_name            | NVARCHAR(50)  | From dim_customers                    | JOHN       |
| last_name             | NVARCHAR(50)  | From dim_customers                    | SMITH      |
| country               | NVARCHAR(50)  | From dim_customers                    | Australia  |
| total_orders          | INT           | COUNT(order_number)                   | 5          |
| total_sales           | DECIMAL(12,2) | SUM(sales_amount)                     | 6000.00    |
| total_profit          | DECIMAL(12,2) | SUM(profit)                           | 1500.00    |
| profit_margin_percent | DECIMAL(5,2)  | (total_profit / total_sales) × 100    | 25.00      |
| avg_order_value       | DECIMAL(10,2) | total_sales / total_orders            | 1200.00    |
| customer_segment      | NVARCHAR(20)  | VIP/Premium/Standard (based on sales) | VIP        |
| last_purchase_date    | DATE          | MAX(order_date)                       | 2025-03-20 |

---

## gold.product_metrics

**Purpose:** Product-level performance KPIs  
**Source:** Aggregated from fact_sales + dim_products  
**Records:** 200+ (one per product)

| Column                   | Type          | Calculation                                               | Example          |
| ------------------------ | ------------- | --------------------------------------------------------- | ---------------- |
| product_id               | INT           | From dim_products                                         | 500              |
| product_name             | NVARCHAR(100) | From dim_products                                         | Mountain Bike XL |
| category                 | NVARCHAR(50)  | From dim_products                                         | Mountain Bikes   |
| subcategory              | NVARCHAR(50)  | From dim_products                                         | Hardtail         |
| units_sold               | INT           | SUM(quantity)                                             | 150              |
| revenue                  | DECIMAL(12,2) | SUM(sales_amount)                                         | 90000.00         |
| profit                   | DECIMAL(12,2) | SUM(profit)                                               | 45000.00         |
| profit_margin_percent    | DECIMAL(5,2)  | (profit / revenue) × 100                                  | 50.00            |
| avg_selling_price        | DECIMAL(10,2) | revenue / units_sold                                      | 600.00           |
| revenue_rank_by_category | INT           | RANK() OVER (PARTITION BY category ORDER BY revenue DESC) | 1                |

---

## gold.fulfillment_metrics

**Purpose:** Daily operational KPIs  
**Source:** Aggregated from fact_sales by order_date  
**Records:** ~365 (daily)

| Column                  | Type          | Calculation                                   | Example    |
| ----------------------- | ------------- | --------------------------------------------- | ---------- |
| order_date              | DATE          | From fact_sales                               | 2025-03-15 |
| total_orders            | INT           | COUNT(order_number)                           | 125        |
| on_time_orders          | INT           | COUNT(order_number WHERE shipped_on_time = 1) | 120        |
| late_orders             | INT           | total_orders - on_time_orders                 | 5          |
| on_time_delivery_rate   | DECIMAL(5,2)  | (on_time_orders / total_orders) × 100         | 96.00      |
| avg_shipping_delay_days | DECIMAL(5,2)  | AVG(shipping_delay_days)                      | -0.5       |
| daily_revenue           | DECIMAL(12,2) | SUM(sales_amount)                             | 18500.00   |

---

## gold.revenue_by_category

**Purpose:** Category-level financial performance  
**Source:** Aggregated from fact_sales grouped by category  
**Records:** 4 (one per category)

| Column                | Type          | Calculation                          | Example        |
| --------------------- | ------------- | ------------------------------------ | -------------- |
| category              | NVARCHAR(50)  | From dim_products                    | Mountain Bikes |
| order_count           | INT           | COUNT(order_number)                  | 4500           |
| total_revenue         | DECIMAL(12,2) | SUM(sales_amount)                    | 2700000.00     |
| total_profit          | DECIMAL(12,2) | SUM(profit)                          | 1350000.00     |
| profit_margin_percent | DECIMAL(5,2)  | (total_profit / total_revenue) × 100 | 50.00          |
| avg_order_value       | DECIMAL(10,2) | total_revenue / order_count          | 600.00         |

---

---

## 📊 Data Refresh & Maintenance

| Object    | Layer  | Type  | Update Method | Frequency |
| --------- | ------ | ----- | ------------- | --------- |
| bronze.\* | Bronze | Table | BULK INSERT   | Daily     |
| silver.\* | Silver | Table | Stored Proc   | Daily     |
| gold.\*   | Gold   | View  | Query-time    | Real-time |

---

## 🔄 Sample ETL Pipeline

```
CSV Files (bronze)
    ↓ BULK INSERT
Bronze Tables (raw data, no transformation)
    ↓ Stored Procedures
Silver Tables (cleaned, validated, business logic added)
    ↓ CREATE VIEW
Gold Views (analytics-ready, query-time aggregation)
    ↓ SQL Queries
Business Intelligence Tools (Power BI, Tableau, etc)
```

---

## 📌 Key Transformation Logic

### Profit Calculation (Silver → Gold)

```sql
profit = sales_amount - (product.cost × sales.quantity)
profit_margin_percent = (profit / sales_amount) * 100
```

### Shipping Delay (Silver → Gold)

```sql
shipping_delay_days = DATEDIFF(DAY, due_date, actual_ship_date)
shipped_on_time = CASE WHEN shipping_delay_days <= 0 THEN 1 ELSE 0 END
```

### Customer Segmentation (Silver → Gold)

```sql
CASE
    WHEN total_sales > 10000 THEN 'VIP'
    WHEN total_sales > 5000 THEN 'Premium'
    ELSE 'Standard'
END
```

### Order Value Category (Silver → Gold)

```sql
CASE
    WHEN sales_amount > 10000 THEN 'High-Value'
    WHEN sales_amount >= 5000 THEN 'Medium-Value'
    ELSE 'Standard'
END
```

---

## ✅ Data Quality Rules

| Layer  | Field                 | Rule             | Action          |
| ------ | --------------------- | ---------------- | --------------- |
| Bronze | customer_id           | NOT NULL, UNIQUE | Reject row      |
| Bronze | order_date            | Valid date       | Reject row      |
| Silver | sales_amount          | > 0              | Log warning     |
| Silver | profit_margin_percent | 0-100            | NULL if invalid |
| Gold   | shipping_delay_days   | Calculated       | Never NULL      |

---

## 📖 Column Naming Convention

| Pattern       | Examples                              |
| ------------- | ------------------------------------- | ------- | -------------------- |
| Business Key  | customer_id, product_id, order_number |
| Surrogate Key | customer_key, product_key             | Amounts | sales_amount, profit |
| Percentages   | margin_percent, on_time_rate          |
| Counts        | total_orders, units_sold              |
| Dates         | order_date, created_at                |
| Flags         | shipped_on_time, account_active       |
| Aggregates    | avg_order_value, total_sales          |

---

**Document Version:** 2.0 (Enhanced)  
**Last Updated:** March 22, 2026  
**Coverage:** All 3 layers (Bronze, Silver, Gold) + lineage & transformations
