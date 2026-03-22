# E-Commerce Data Warehouse - Naming Conventions

This document outlines the naming conventions used for schemas, tables, views, columns, and other objects in the E-commerce SQL Data Warehouse.

## Table of Contents

1. [General Principles](#general-principles)
2. [Schema Naming](#schema-naming)
3. [Table Naming Conventions](#table-naming-conventions)
   - [Bronze Layer Rules](#bronze-layer-rules)
   - [Silver Layer Rules](#silver-layer-rules)
   - [Gold Layer Rules](#gold-layer-rules)
4. [Column Naming Conventions](#column-naming-conventions)
   - [Primary Keys](#primary-keys)
   - [Business Keys](#business-keys)
   - [Surrogate Keys](#surrogate-keys)
   - [Technical Columns](#technical-columns)
   - [Business Logic Columns](#business-logic-columns)
5. [Stored Procedure Naming](#stored-procedure-naming)
6. [View Naming Conventions](#view-naming-conventions)
7. [File Naming](#file-naming)

---

## General Principles

- **Case Convention**: Use `snake_case` for all object names (lowercase with underscores)
- **Language**: English only for all names
- **Reserved Words**: Avoid SQL Server reserved words
- **Abbreviations**: Use consistent abbreviations (see examples below)
- **Prefixes**: Use layer prefixes for clear identification
- **Descriptive**: Names should be self-documenting and business-aligned

## Schema Naming

All schemas follow the medallion architecture pattern:

| Schema   | Purpose                     | Example Usage        |
| -------- | --------------------------- | -------------------- |
| `bronze` | Raw data storage            | `bronze.customers`   |
| `silver` | Cleansed & transformed data | `silver.customers`   |
| `gold`   | Analytics-ready views       | `gold.dim_customers` |

## Table Naming Conventions

### Bronze Layer Rules

- **Pattern**: `bronze.<source_system><entity>`
- **Purpose**: Raw data tables matching source system names
- **Examples**:
  - `bronze.customers` (from CRM cust_info.csv)
  - `bronze.products` (from CRM prd_info.csv)
  - `bronze.sales_details` (from CRM sales_details.csv)
  - `bronze.CUST_AZ12` (from ERP CUST_AZ12.csv)
  - `bronze.LOC_A101` (from ERP LOC_A101.csv)
  - `bronze.PX_CAT_G1V2` (from ERP PX_CAT_G1V2.csv)

### Silver Layer Rules

- **Pattern**: `silver.<entity>`
- **Purpose**: Cleansed and enriched business entities
- **Examples**:
  - `silver.customers` (enriched customer data)
  - `silver.products` (product catalog with pricing)
  - `silver.sales_transactions` (sales with business logic)
  - `silver.locations` (warehouse locations)
  - `silver.product_categories` (category master)
  - `silver.data_quality_log` (ETL quality tracking)

### Gold Layer Rules

- **Pattern**: `gold.<category>_<entity>`
- **Purpose**: Analytics-ready views for business intelligence
- **Category Prefixes**:
  - `dim_` : Dimension tables (master data)
  - `fact_` : Fact tables (transactional data)
  - `<entity>_metrics` : Aggregated KPI views
  - `revenue_by_<entity>` : Financial summary views

- **Examples**:
  - `gold.dim_customers` (customer dimension)
  - `gold.dim_products` (product dimension)
  - `gold.fact_sales` (sales transactions)
  - `gold.customer_metrics` (customer KPIs)
  - `gold.product_metrics` (product performance)
  - `gold.fulfillment_metrics` (delivery KPIs)
  - `gold.revenue_by_category` (category revenue)

## Column Naming Conventions

### Primary Keys

- **Business Keys**: Natural identifiers from source systems
- **Pattern**: `<entity>_id` or `<entity>_number`
- **Examples**:
  - `customer_id` (unique customer identifier)
  - `product_id` (unique product identifier)
  - `order_number` (unique order identifier)
  - `location_id` (unique location identifier)

### Business Keys

- **Pattern**: `<entity>_<attribute>` or direct business terms
- **Examples**:
  - `customer_number` (human-readable customer code)
  - `product_number` (SKU/product code)
  - `category_id` (category identifier)
  - `subcategory` (product subcategory)

### Surrogate Keys

- **Pattern**: `<entity>_key`
- **Purpose**: System-generated unique identifiers for analytics
- **Examples**:
  - `customer_key` (surrogate key in gold.dim_customers)
  - `product_key` (surrogate key in gold.dim_products)

### Technical Columns

- **Pattern**: Standard SQL naming without prefixes
- **Examples**:
  - `created_at` (record creation timestamp)
  - `updated_at` (last modification timestamp)

### Business Logic Columns

- **Pattern**: Descriptive business terms with clear meaning
- **Examples**:
  - `profit_amount` (calculated profit per transaction)
  - `profit_margin_percent` (profit as percentage)
  - `shipping_delay_days` (days order was late)
  - `shipped_on_time` (boolean: 1=ontime, 0=late)
  - `order_value_category` (High/Medium/Standard)
  - `customer_segment` (VIP/Premium/Standard)
  - `total_orders` (aggregated order count)
  - `total_sales` (aggregated revenue)
  - `total_profit` (aggregated profit)
  - `avg_order_value` (average order value)
  - `on_time_delivery_rate` (percentage on-time)
  - `revenue_rank_by_category` (ranking within category)

## Stored Procedure Naming

- **Pattern**: `load_<layer>` or `proc_load_<layer>`
- **Examples**:
  - `proc_load_bronze` (loads raw data from CSV)
  - `proc_load_silver` (transforms and enriches data)

## View Naming Conventions

- **Pattern**: `gold.<category>_<entity>` (same as Gold tables)
- **Examples**:
  - `gold.dim_customers` (customer dimension view)
  - `gold.fact_sales` (sales fact view)
  - `gold.customer_metrics` (customer KPI aggregations)
  - `gold.product_metrics` (product performance metrics)

## File Naming

- **SQL Scripts**: `<nn>_<description>.sql` (numbered sequence)
  - `00_RUN_ALL.sql` (master orchestration script)
  - `init_database.sql` (database initialization)
- **Documentation**: `<UPPERCASE_DESCRIPTION>.md`
  - `PROJECT_OVERVIEW.md`
  - `IMPLEMENTATION_GUIDE.md`
  - `ANALYTICS_GUIDE.md`
- **CSV Data Files**: `<source>_<entity>.csv`
  - `source_crm/cust_info.csv`
  - `source_erp/CUST_AZ12.csv`
- **Diagrams**: `<topic>.<extension>`
  - `data_flow.png`
  - `data_model.png`
  - `data_layers.pdf`
