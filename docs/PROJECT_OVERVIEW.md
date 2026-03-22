# E-Commerce Data Warehouse - Project Overview

**Project Name:** E-Commerce Data Warehouse (Customized)  
**Date Created:** March 22, 2026  
**Version:** 1.0  
**Status:** ✅ Production Ready

---

## 📋 Executive Summary

This is a **comprehensive E-commerce Data Warehouse** built using the **Medallion Architecture** (Bronze → Silver → Gold layers). The system consolidates customer, product, and sales data from CRM and ERP systems into a unified analytics platform with built-in KPIs for business intelligence.

**Key Features:**

- ✅ Multi-source data integration (CRM + ERP)
- ✅ Advanced ETL with data cleansing & transformation
- ✅ Business logic layer (profit, shipping delays, customer segments)
- ✅ 7 pre-built analytics views (KPIs)
- ✅ Star schema for optimal query performance

---

## 🎯 Project Objectives

1. **Centralize Data**: Consolidate customer, product, and sales data from multiple sources
2. **Data Quality**: Cleanse and standardize data for accurate reporting
3. **Business Analytics**: Provide actionable insights through KPIs
4. **Scalability**: Enable future enhancements and additional data sources
5. **Ease of Use**: Make analytics accessible to business users

---

## 🏗️ Architecture Overview

### **Medallion Architecture (3-Layer)**

```
┌─────────────────────────────────────────────────────┐
│                   GOLD LAYER                        │
│        (Analytics-Ready Business Views)             │
│  • dim_customers • dim_products • fact_sales        │
│  • customer_metrics • product_metrics • etc         │
└─────────────────────────────────────────────────────┘
                        ▲
                        │ (Views)
┌─────────────────────────────────────────────────────┐
│                 SILVER LAYER                        │
│      (Cleansed, Standardized Data Tables)           │
│ • Deduplication • Normalization • Enrichment        │
│ • Business Logic (Profit, Segments, Delays)         │
└─────────────────────────────────────────────────────┘
                        ▲
                        │ (ETL/Transform)
┌─────────────────────────────────────────────────────┐
│                 BRONZE LAYER                        │
│              (Raw Data from Sources)                │
│ • CRM: customers, products, sales                   │
│ • ERP: locations, demographics, categories          │
└─────────────────────────────────────────────────────┘
                        ▲
                        │ (BULK INSERT)
┌─────────────────────────────────────────────────────┐
│              SOURCE CSV FILES                       │
│  • source_crm/ • source_erp/                        │
└─────────────────────────────────────────────────────┘
```

---

## 📊 Data Sources

### **CRM Source** (Customer Relationship Management)

- **cust_info.csv** - Customer demographics (18,495 records)
- **prd_info.csv** - Product catalog
- **sales_details.csv** - Transaction records

### **ERP Source** (Enterprise Resource Planning)

- **CUST_AZ12.csv** - Customer supplementary data (age, gender)
- **LOC_A101.csv** - Location/country information
- **PX_CAT_G1V2.csv** - Product category hierarchy

---

## 💾 Database Objects

### **Schemas**

| Schema     | Purpose              | Tables   |
| ---------- | -------------------- | -------- |
| **bronze** | Raw ingestion layer  | 6 tables |
| **silver** | Cleansed/transformed | 6 tables |
| **gold**   | Analytics-ready      | 7 views  |

### **Key Tables & Views**

**Bronze Layer** (Raw Data):

- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.crm_sales_details`
- `bronze.erp_cust_az12`
- `bronze.erp_loc_a101`
- `bronze.erp_px_cat_g1v2`

**Silver Layer** (Cleansed Data with Business Logic):

- `silver.crm_cust_info` - Normalized customer data
- `silver.crm_prd_info` - Product data with category extraction
- `silver.crm_sales_details` - **Enhanced with:** profit calculation, shipping delays, order value categories
- `silver.erp_*` - Location, demographics, categories

**Gold Layer** (Analytics Views):

- `gold.dim_customers` - Customer dimension
- `gold.dim_products` - Product dimension
- `gold.fact_sales` - Sales fact table with business metrics
- `gold.customer_metrics` - Customer KPIs (VIP/Premium/Standard segmentation)
- `gold.product_metrics` - Product performance by category
- `gold.fulfillment_metrics` - Daily delivery performance
- `gold.revenue_by_category` - Category-level revenue analysis

---

## 🔄 ETL Pipeline

### **Phase 1: Bronze Layer** (Raw Ingestion)

```
CSV Files → BULK INSERT → Bronze Tables (as-is)
```

- No transformations
- Preserves source structure
- Audit trail ready

### **Phase 2: Silver Layer** (Cleansing & Enrichment)

```
Bronze Tables → Transformation Rules → Silver Tables
```

**Transformations Applied:**

- ✅ Trim whitespace
- ✅ Normalize codes (M→Male, F→Female, S→Single, M→Married)
- ✅ Standardize product lines (M→Mountain, R→Road, T→Touring)
- ✅ Fix date formats (YYYYMMDD → DATE)
- ✅ Remove invalid records (NULL, future dates)
- ✅ Deduplicate customers (keep most recent)
- ✅ **Business Logic:**
  - Profit calculation: `Sales - (Product_Cost × Quantity)`
  - Shipping delays: `Due_Date - Ship_Date` (negative = on-time)
  - Order value categorization (High/Medium/Standard)

### **Phase 3: Gold Layer** (Analytics Ready)

```
Silver Tables → Star Schema Views → Gold Views
```

- Fact tables with keys
- Dimensions fully enriched
- Pre-calculated KPIs
- Ready for BI tools

---

## 📈 Key Business Metrics (KPIs)

### **Customer Metrics**

| KPI                  | Formula                                             | Use Case                |
| -------------------- | --------------------------------------------------- | ----------------------- |
| **Total Orders**     | COUNT(DISTINCT order_id)                            | Customer activity level |
| **Total Sales**      | SUM(sales_amount)                                   | Revenue contribution    |
| **Customer Segment** | IF sales > 100K: VIP, >50K: Premium, else: Standard | Customer classification |
| **Profit Margin %**  | (SUM(profit) / SUM(sales)) × 100                    | Profitability           |

### **Product Metrics**

| KPI                 | Formula                           | Use Case                |
| ------------------- | --------------------------------- | ----------------------- |
| **Units Sold**      | COUNT(DISTINCT order_id)          | Volume analysis         |
| **Revenue**         | SUM(sales_amount)                 | Product performance     |
| **Profit**          | SUM(sales_amount - cost×quantity) | Profitability           |
| **Profit Margin %** | (SUM(profit) / SUM(sales)) × 100  | Efficiency              |
| **Revenue Rank**    | RANK() by category, sales         | Competitive positioning |

### **Fulfillment Metrics**

| KPI                    | Formula                                      | Use Case             |
| ---------------------- | -------------------------------------------- | -------------------- |
| **On-Time Delivery %** | (orders with delay ≤ 0) / total orders × 100 | Service quality      |
| **Avg Shipping Delay** | AVG(due_date - ship_date)                    | Logistics efficiency |
| **Daily Revenue**      | SUM(sales_amount) by date                    | Revenue trending     |

---

## 🚀 Quick Start

### **1. Prerequisites**

- SQL Server 2016+ installed
- SQL Server Management Studio (SSMS)
- Dataset CSV files in correct location

### **2. Execute the Project**

```sql
-- Open and run this script in SSMS:
c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\scripts\00_RUN_ALL.sql
```

**Execution Time:** ~2-5 minutes

### **3. Verify Completion**

```sql
-- Check database exists
SELECT name FROM sys.databases WHERE name = 'DataWarehouse';

-- Check all tables created
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('bronze', 'silver');

-- Check all views created
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold' AND TABLE_TYPE = 'VIEW';
```

### **4. Query Analytics**

```sql
-- Top 10 customers by sales
SELECT TOP 10 * FROM gold.customer_metrics
ORDER BY total_sales DESC;

-- Top 10 products by revenue
SELECT TOP 10 * FROM gold.product_metrics
ORDER BY revenue DESC;

-- Daily fulfillment performance
SELECT * FROM gold.fulfillment_metrics
ORDER BY order_date DESC;

-- Revenue by category
SELECT * FROM gold.revenue_by_category
ORDER BY total_revenue DESC;
```

---

## 📁 Project Structure

```
sql-data-warehouse-project/
├── README.md                          # Main project overview
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
├── docs/
│   ├── PROJECT_OVERVIEW.md            # This file
│   ├── IMPLEMENTATION_GUIDE.md         # Step-by-step execution
│   ├── KPI_DEFINITIONS.md              # Detailed KPI specs
│   ├── ANALYTICS_GUIDE.md              # How to query & analyze
│   ├── data_catalog.md                 # Table/column descriptions
│   └── naming_conventions.md           # Naming standards
├── scripts/
│   ├── 00_RUN_ALL.sql                 # Master orchestration script
│   ├── init_database.sql               # DB initialization
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── proc_load_bronze.sql
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── proc_load_silver.sql
│   └── gold/
│       └── ddl_gold.sql
└── tests/
    ├── quality_checks_gold.sql
    └── quality_checks_silver.sql
```

---

## 🔐 Data Quality & Validation

### **Bronze Layer Quality Checks**

- ✅ Record counts match source
- ✅ No schema violations
- ✅ NULL handling documented

### **Silver Layer Quality Checks**

- ✅ Deduplication validation
- ✅ Transformation accuracy
- ✅ Date format consistency

### **Gold Layer Quality Checks**

- ✅ Referential integrity (FK relationships)
- ✅ KPI calculation validation
- ✅ No null key violations

---

## 🛠️ Maintenance & Support

### **Common Tasks**

| Task                 | Command                                                        |
| -------------------- | -------------------------------------------------------------- |
| **Refresh Data**     | `EXEC bronze.load_bronze;` → `EXEC silver.load_silver;`        |
| **Check Row Counts** | `SELECT OBJECT_NAME(id), ROWS FROM sysindexes WHERE indid < 2` |
| **Backup Database**  | SQL Server native backup                                       |
| **Monitor Queries**  | Use SQL Server Profiler                                        |

### **Troubleshooting**

- **CSV file not found**: Check path in BULK INSERT statements
- **Schema doesn't exist**: Verify `CREATE SCHEMA` executed in Phase 1
- **View errors**: Validate underlying layer tables exist

---

## 📞 Support & Documentation

- **Questions?** Refer to `ANALYTICS_GUIDE.md`
- **How to add data sources?** See `IMPLEMENTATION_GUIDE.md`
- **Need new KPI?** Check `KPI_DEFINITIONS.md`
- **Table details?** Consult `data_catalog.md`

---

## ✅ Deliverables

- [x] **Database Design** - Complete medallion architecture
- [x] **ETL Pipelines** - 3-phase transformation
- [x] **Business Logic** - Integrated KPIs & metrics
- [x] **Analytics Views** - 7 ready-to-query views
- [x] **Master Script** - One-click execution
- [x] **Documentation** - Comprehensive guides
- [x] **Quality Checks** - Data validation scripts

---

**Status:** ✅ **PRODUCTION READY**  
**Last Updated:** March 22, 2026  
**Next Phase:** Stakeholder validation & BI tool integration
