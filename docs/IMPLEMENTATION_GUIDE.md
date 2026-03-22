# E-Commerce Data Warehouse - Implementation Guide

**Purpose:** Step-by-step instructions to build and validate the complete data warehouse  
**Target Audience:** Data Engineers, DBAs, Technical Leads  
**Prerequisites:** SQL Server 2016+, SSMS 18+, Dataset CSV files

---

## 📋 Pre-Implementation Checklist

- [ ] SQL Server is installed and running
- [ ] SQL Server Management Studio (SSMS) is installed
- [ ] Dataset CSV files are in: `c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\`
- [ ] User has `CREATE DATABASE`, `CREATE SCHEMA`, `ALTER SERVER STATE` permissions
- [ ] Sufficient disk space (at least 2 GB free)
- [ ] Backup existing databases (if any)

---

## 🚀 Phase-by-Phase Implementation

### **PHASE 1: Database & Schema Initialization** (2 minutes)

#### Step 1.1: Open Master Script in SSMS

1. Launch **SQL Server Management Studio**
2. Connect to your SQL Server instance
3. File → Open → File
4. Navigate to:
   ```
   c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\scripts\00_RUN_ALL.sql
   ```
5. Click **Open**

#### Step 1.2: Execute Initialization

1. In the script editor, select **all text** (Ctrl+A)
2. Press **F5** to execute
3. Monitor the **Messages** tab for progress

**Expected Output:**

```
═══════════════════════════════════════════════════════════════════════
PHASE 1: Initialize Database (Create DataWarehouse DB + Schemas)
═══════════════════════════════════════════════════════════════════════

>> Dropping existing DataWarehouse database...
>> DataWarehouse database dropped successfully
>> Creating new DataWarehouse database...
>> Creating Bronze schema...
>> Creating Silver schema...
>> Creating Gold schema...
✓ Database initialization complete!
```

#### Step 1.3: Verify Database Creation

```sql
-- Run this query to verify
USE master;
SELECT name, create_date FROM sys.databases
WHERE name = 'DataWarehouse';
```

**Expected Result:** 1 row showing DataWarehouse database

---

### **PHASE 2: Bronze Layer - Table Creation** (1 minute)

The master script will automatically:

1. Create 6 raw data tables in `bronze` schema
2. Preserve exact source structure

**Tables Created:**

- `bronze.crm_cust_info` - Customer data
- `bronze.crm_prd_info` - Product data
- `bronze.crm_sales_details` - Sales transactions
- `bronze.erp_cust_az12` - Customer demographics
- `bronze.erp_loc_a101` - Geographic location
- `bronze.erp_px_cat_g1v2` - Product categories

#### Verify Phase 2:

```sql
USE DataWarehouse;

-- Check all bronze tables exist
SELECT TABLE_NAME, TABLE_SCHEMA, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME;
```

**Expected Result:** 6 tables listed

---

### **PHASE 3: Bronze Layer - Data Load** (30 seconds to 2 minutes, depending on CSV size)

The script loads data from CSV files using `BULK INSERT`:

```sql
-- Execution Log shows:
>> Loading CRM source data...
  Loading: bronze.crm_cust_info
    ✓ Done - Duration: 2 seconds
  Loading: bronze.crm_prd_info
    ✓ Done - Duration: 1 second
  Loading: bronze.crm_sales_details
    ✓ Done - Duration: 3 seconds

>> Loading ERP source data...
  Loading: bronze.erp_cust_az12
    ✓ Done - Duration: 1 second
  Loading: bronze.erp_loc_a101
    ✓ Done - Duration: 1 second
  Loading: bronze.erp_px_cat_g1v2
    ✓ Done - Duration: 1 second

✓ Bronze layer data loaded successfully!
  Total Duration: 10 seconds
```

#### Verify Phase 3:

```sql
USE DataWarehouse;

-- Check row counts by table
SELECT
    TABLE_SCHEMA,
    TABLE_NAME,
    (SELECT COUNT(*) FROM bronze.crm_cust_info) AS cust_info_rows,
    (SELECT COUNT(*) FROM bronze.crm_prd_info) AS prd_info_rows,
    (SELECT COUNT(*) FROM bronze.crm_sales_details) AS sales_rows
WHERE TABLE_SCHEMA = 'bronze'
LIMIT 1;
```

---

### **PHASE 4: Silver Layer - Table Creation** (1 minute)

Creates 6 cleansed tables with additional KPI columns:

**New Columns Added (Silver Layer):**

- `dwh_create_date` - Tracking timestamp
- `profit_amount` - Calculated profit
- `shipping_delay_days` - Delivery performance
- `order_value_category` - Business segmentation

#### Verify Phase 4:

```sql
-- Check silver schema tables
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'silver'
ORDER BY TABLE_NAME;

-- Verify business logic columns exist
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'crm_sales_details';
```

**Expected Columns in silver.crm_sales_details:**

- sls_ord_num, sls_prd_key, sls_cust_id
- sls_order_dt, sls_ship_dt, sls_due_dt
- sls_sales, sls_quantity, sls_price
- **profit_amount** ⭐
- **shipping_delay_days** ⭐
- **order_value_category** ⭐
- dwh_create_date

---

### **PHASE 5: Silver Layer - Data Transformation** (1-3 minutes)

Applies business logic & cleansing rules:

```
Bronze Data + Transformation Rules → Silver Data
```

**Transformation Examples:**

**1. Customer Normalization:**

```sql
BEFORE (Bronze):
  cst_firstname: ' Jon'→ TRIM → 'Jon'
  cst_gndr: 'M' → CASE → 'Male'
  cst_marital_status: 'S' → CASE → 'Single'
```

**2. Product Normalization:**

```sql
BEFORE (Bronze):
  prd_line: 'M' → CASE → 'Mountain'
  prd_line: 'R' → CASE → 'Road'
  prd_line: 'T' → CASE → 'Touring'
```

**3. Date Conversion:**

```sql
BEFORE (Bronze):
  sls_order_dt: 20251006 (INT)
AFTER (Silver):
  sls_order_dt: 2025-10-06 (DATE)
```

**4. Business Logic (Profit Calculation):**

```sql
profit_amount = sls_sales - (prd_cost * sls_quantity)

EXAMPLE:
  sls_sales: 5000
  prd_cost: 100
  sls_quantity: 10
  profit_amount: 5000 - (100 * 10) = 4000
```

**5. Shipping Performance:**

```sql
shipping_delay_days = due_date - ship_date

EXAMPLES:
  due_date: 2025-10-15,  ship_date: 2025-10-10  → -5 (5 days EARLY)
  due_date: 2025-10-15,  ship_date: 2025-10-20  → +5 (5 days LATE)
```

**6. Order Value Categorization:**

```sql
IF sales_amount > 10000 THEN 'High-Value'
ELSE IF sales_amount >= 5000 THEN 'Medium-Value'
ELSE 'Standard'
```

#### Verify Phase 5:

```sql
-- Check silver data loads
SELECT
    (SELECT COUNT(*) FROM silver.crm_cust_info) AS silver_customers,
    (SELECT COUNT(*) FROM silver.crm_prd_info) AS silver_products,
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_sales;

-- Verify business logic is applied
SELECT TOP 5
    sls_ord_num,
    sls_sales,
    profit_amount,
    shipping_delay_days,
    order_value_category
FROM silver.crm_sales_details;

-- Check profit calculation sample
SELECT TOP 1
    sls_ord_num,
    sls_sales,
    (SELECT prd_cost FROM silver.crm_prd_info LIMIT 1) * sls_quantity AS expected_cost,
    profit_amount
FROM silver.crm_sales_details;
```

---

### **PHASE 6: Gold Layer - Analytics Views** (1 minute)

Creates 7 business-ready views with pre-calculated KPIs:

**Views Created:**

1. **`gold.dim_customers`** - Customer dimension (enriched with demographics, location)
2. **`gold.dim_products`** - Product dimension (with category hierarchy)
3. **`gold.fact_sales`** - Fact table (with business metrics embedded)
4. **`gold.customer_metrics`** - Customer KPIs
5. **`gold.product_metrics`** - Product performance metrics
6. **`gold.fulfillment_metrics`** - Daily delivery performance
7. **`gold.revenue_by_category`** - Category-level revenue analytics

#### Verify Phase 6:

```sql
-- Check all gold views exist
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold' AND TABLE_TYPE = 'VIEW'
ORDER BY TABLE_NAME;

-- Expected Result: 7 views
-- gold.customer_metrics
-- gold.dim_customers
-- gold.dim_products
-- gold.fact_sales
-- gold.fulfillment_metrics
-- gold.product_metrics
-- gold.revenue_by_category
```

---

## ✅ Post-Implementation Validation

### **Step 1: Database Integrity Check**

```sql
-- Verify all layers exist and have data
SELECT
    'Bronze' AS Layer,
    'crm_cust_info' AS Object,
    (SELECT COUNT(*) FROM bronze.crm_cust_info) AS RecordCount
UNION ALL
SELECT 'Silver', 'crm_cust_info', COUNT(*) FROM silver.crm_cust_info
UNION ALL
SELECT 'Gold', 'dim_customers', COUNT(*) FROM gold.dim_customers;
```

### **Step 2: KPI Calculation Validation**

```sql
-- Verify profit calculation
SELECT TOP 5
    sls_ord_num,
    sls_quantity,
    sls_price,
    sls_sales,
    profit_amount,
    (sls_sales - (sls_price * sls_quantity)) AS manual_calc
FROM silver.crm_sales_details;

-- Verify customer segmentation
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS count,
    MIN(total_sales) AS min_sales,
    MAX(total_sales) AS max_sales
FROM gold.customer_metrics
GROUP BY customer_segment;

-- Verify fulfillment metrics
SELECT
    COUNT(*) AS total_records,
    COUNT(CASE WHEN on_time_delivery_rate > 0 THEN 1 END) AS records_with_ontime_rate
FROM gold.fulfillment_metrics;
```

### **Step 3: Data Quality Checks**

```sql
-- Check for NULL keys
SELECT 'NULL customer_key' AS issue FROM gold.dim_customers WHERE customer_key IS NULL
UNION ALL
SELECT 'NULL product_key' FROM gold.dim_products WHERE product_key IS NULL
UNION ALL
SELECT 'NULL order_number' FROM gold.fact_sales WHERE order_number IS NULL;

-- Verify no negative dates
SELECT COUNT(*) AS invalid_dates
FROM gold.fact_sales
WHERE order_date > GETDATE() OR shipping_date > GETDATE();
```

---

## 🧪 Sample Queries for Validation

### **Query 1: Top 10 Customers by Revenue**

```sql
SELECT TOP 10
    customer_id,
    first_name,
    last_name,
    total_orders,
    total_sales,
    total_profit,
    customer_segment
FROM gold.customer_metrics
WHERE total_sales IS NOT NULL
ORDER BY total_sales DESC;
```

### **Query 2: Product Performance by Category**

```sql
SELECT
    category,
    COUNT(DISTINCT product_id) AS num_products,
    SUM(revenue) AS category_revenue,
    SUM(profit) AS category_profit,
    ROUND(SUM(profit) * 100.0 / NULLIF(SUM(revenue), 0), 2) AS profit_margin_percent
FROM gold.product_metrics
GROUP BY category
ORDER BY category_revenue DESC;
```

### **Query 3: Fulfillment Performance Trend**

```sql
SELECT
    order_date,
    total_orders,
    on_time_orders,
    late_orders,
    on_time_delivery_rate,
    daily_revenue
FROM gold.fulfillment_metrics
WHERE order_date >= DATEADD(DAY, -30, GETDATE())
ORDER BY order_date DESC;
```

---

## 🔄 Data Refresh Procedure

### **Schedule: Daily/Weekly Refresh**

```sql
-- Step 1: Clear Bronze Layer
TRUNCATE TABLE bronze.crm_cust_info;
TRUNCATE TABLE bronze.crm_prd_info;
TRUNCATE TABLE bronze.crm_sales_details;
-- ... (repeat for all bronze tables)

-- Step 2: Reload from source
EXEC bronze.load_bronze;

-- Step 3: Transform to Silver
EXEC silver.load_silver;

-- Step 4: Gold views automatically refresh (they query Silver)
-- No action needed - views are dynamic
```

---

## 🐛 Troubleshooting Guide

### **Issue 1: "Cannot find the object 'bronze.crm_cust_info'"**

**Cause:** Tables not created  
**Solution:**

```sql
-- Verify schema exists
SELECT * FROM sys.schemas WHERE name = 'bronze';

-- If not, create it
CREATE SCHEMA bronze;
```

### **Issue 2: "Bulk insert data conversion error"**

**Cause:** CSV file has incorrect format  
**Solution:**

```sql
-- Check CSV file:
-- - FIRSTROW = 2 (skip header)
-- - FIELDTERMINATOR = ',' (comma-separated)
-- - No special characters in values
```

### **Issue 3: "View definition includes invalid column reference"**

**Cause:** Underlying table doesn't exist or columns missing  
**Solution:**

```sql
-- Drop and recreate views
DROP VIEW gold.fact_sales;
DROP VIEW gold.customer_metrics;

-- Recreate in order (dimensions first, then facts)
-- Re-run PHASE 6 from 00_RUN_ALL.sql
```

---

## 📊 Summary Checklist

After completing all phases, you should have:

- [x] **DataWarehouse** database created
- [x] **bronze, silver, gold** schemas created
- [x] **6 bronze tables** with 18,495+ customer records
- [x] **6 silver tables** with cleansed data & KPIs
- [x] **7 gold views** with pre-calculated metrics
- [x] **Business logic** applied (profit, shipping delays, segments)
- [x] **Data validated** (no NULLs, correct calculations)
- [x] **Ready for analytics** queries and BI tools

---

## 🎯 Next Steps

1. ✅ **Complete implementation** using this guide
2. ✅ **Validate all data** using verification queries
3. ⏭️ **Connect BI Tool** (Power BI, Tableau, etc.) to Gold views
4. ⏭️ **Create dashboards** for stakeholders
5. ⏭️ **Schedule periodic refreshes** (daily/weekly)
6. ⏭️ **Document SLAs** for data freshness

---

**Document Version:** 1.0  
**Last Updated:** March 22, 2026  
**Estimated Implementation Time:** 10-15 minutes (first run)
