# AI Image Generation Prompts for E-Commerce Data Warehouse Diagrams

Use these detailed prompts with Nano Banana or similar AI image generation tools to create professional architecture diagrams for your E-commerce Data Warehouse project.

---

## 📊 1. data_flow.png - ETL Data Flow Diagram

**Prompt:**

```
Create a professional ETL data flow diagram for an E-commerce Data Warehouse using the medallion architecture. Show a horizontal flowchart with 5 main sections:

LEFT: Source Systems box containing:
- CRM System with 3 CSV files: cust_info.csv, prd_info.csv, sales_details.csv
- ERP System with 3 CSV files: CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv
- File path labels: datasets/source_crm/ and datasets/source_erp/

MIDDLE-LEFT: Bronze Layer box (orange color) with:
- 6 tables: customers, products, sales_details, CUST_AZ12, LOC_A101, PX_CAT_G1V2
- Label: "Raw Data - No Transformations"
- BULK INSERT arrows from CSV files

MIDDLE: Silver Layer box (gray color) with:
- 6 tables: customers, products, sales_transactions, locations, product_categories, data_quality_log
- Label: "Cleansed + Business Logic"
- Key additions: profit calculations, shipping delays, customer segments

MIDDLE-RIGHT: Gold Layer box (gold color) with:
- 7 views: dim_customers, dim_products, fact_sales, customer_metrics, product_metrics, fulfillment_metrics, revenue_by_category
- Label: "Analytics-Ready Views"
- Pre-calculated KPIs

RIGHT: Consumption Layer with:
- Power BI, Tableau, Excel icons
- SQL Server Management Studio
- Direct query access

FLOW: Use arrows to show data movement: CSV → Bronze → Silver → Gold → BI Tools
Add data volume annotations: 19K customers, 18K orders, 200 products
Use professional colors: Orange=Bronze, Gray=Silver, Gold=Gold
Clean, technical style with clear labels and no clutter
```

---

## 🔗 2. data_integration.png - Source System Integration

**Prompt:**

```
Create a detailed source system integration diagram for an E-commerce Data Warehouse showing CRM and ERP data flows. Use a split-screen layout:

LEFT SIDE - CRM System (Blue theme):
- Central CRM box with "E-commerce CRM" label
- 3 outgoing arrows to CSV files:
  * cust_info.csv (19K records) → bronze.customers
  * prd_info.csv (200 records) → bronze.products
  * sales_details.csv (18K records) → bronze.sales_details
- Show data types: customer demographics, product catalog, sales transactions

RIGHT SIDE - ERP System (Green theme):
- Central ERP box with "Enterprise ERP" label
- 3 outgoing arrows to CSV files:
  * CUST_AZ12.csv (15K records) → bronze.CUST_AZ12 (supplementary customer data)
  * LOC_A101.csv (40 records) → bronze.LOC_A101 (warehouse locations)
  * PX_CAT_G1V2.csv (100 records) → bronze.PX_CAT_G1V2 (pricing & categories)

MIDDLE - Integration Layer:
- Silver layer box showing cross-system joins:
  * bronze.customers LEFT JOIN bronze.CUST_AZ12 (credit limits)
  * bronze.products enriched with PX_CAT_G1V2 (margin data)
  * Location data for fulfillment analytics
- Data quality considerations box: duplicate handling, missing data, validation rules

STYLE: Professional technical diagram, clear arrows showing data flow directions, color-coded by system (CRM=blue, ERP=green), include record counts, use clean sans-serif fonts, high contrast for readability
```

---

## 🏗️ 3. data_layers.pdf - Medallion Architecture Layers

**Prompt:**

```
Create a detailed medallion architecture diagram showing Bronze, Silver, and Gold layers as stacked horizontal sections. Use a clean, professional technical style:

TOP SECTION - Bronze Layer (Orange/bronze color theme):
- Header: "Bronze Layer - Raw Data Repository"
- Characteristics list: No transformations, exact source copy, schema-on-read, historical preservation
- 6 tables in a row: customers, products, sales_details, CUST_AZ12, LOC_A101, PX_CAT_G1V2
- Operations: BULK INSERT only
- Data volumes: 19K customers, 18K orders, 200 products, 40 locations

MIDDLE SECTION - Silver Layer (Gray/silver color theme):
- Header: "Silver Layer - Cleansed & Enriched Business Data"
- Transformation arrows showing data flow from Bronze
- Key transformations: Data validation, standardization, business logic calculations, cross-system integration
- NEW COLUMNS ADDED (highlight in green):
  * profit_amount = sales_amount - (cost × quantity)
  * profit_margin_percent = (profit / sales_amount) × 100
  * shipping_delay_days = DATEDIFF(DAY, due_date, shipping_date)
  * shipped_on_time = CASE WHEN delay_days <= 0 THEN 1 ELSE 0 END
  * order_value_category = High/Medium/Standard
  * customer_segment = VIP/Premium/Standard
- 6 enriched tables: customers, products, sales_transactions, locations, product_categories, data_quality_log

BOTTOM SECTION - Gold Layer (Gold/yellow color theme):
- Header: "Gold Layer - Analytics-Ready Views"
- Query-time aggregation from Silver layer
- Business-friendly naming, pre-calculated KPIs, reporting optimization
- 7 views: dim_customers, dim_products, fact_sales, customer_metrics, product_metrics, fulfillment_metrics, revenue_by_category
- Categories: Dimensions (dim_), Facts (fact_), Metrics (aggregated KPIs)

CONNECTING ELEMENTS:
- Vertical arrows showing layer progression
- Data transformation indicators
- Business value increasing from top to bottom
- Layer purposes clearly labeled

STYLE: Clean technical diagram, use consistent color scheme (bronze/silver/gold), clear section separation, professional fonts, include key metrics and transformation examples
```

---

## 📋 4. data_model.png - Entity Relationship Diagram

**Prompt:**

```
Create a comprehensive Entity Relationship Diagram for an E-commerce Data Warehouse showing all tables and views across three layers. Use a three-tier vertical layout:

TOP TIER - Bronze Layer (Orange boxes):
- 6 tables arranged horizontally:
  * customers (customer_id PK, customer_number, first_name, last_name, email, country, marital_status, gender, birthdate, created_at)
  * products (product_id PK, product_number, product_name, category_id, category, subcategory, cost, product_line, start_date, maintenance_required)
  * sales_details (order_number + customer_id + product_id PK, order_date, shipping_date, due_date, sales_amount, quantity, unit_price)
  * CUST_AZ12 (CUST_ID PK, CUST_NAME, CUST_COUNTRY, CREDIT_LIMIT, CUST_SINCE)
  * LOC_A101 (LOC_ID PK, LOCATION_NAME, CITY, COUNTRY, TIMEZONE)
  * PX_CAT_G1V2 (CAT_ID PK, CAT_NAME, SUBCATID, AVG_MARGIN_PCT, DISCOUNT_ALLOWED)

MIDDLE TIER - Silver Layer (Gray boxes):
- 6 tables with relationships:
  * customers (customer_id PK, + credit_limit, account_active from ERP)
  * products (product_id PK, + list_price, margin_percent from ERP)
  * sales_transactions (order_number + customer_id + product_id PK, + profit_amount, shipping_delay_days, order_value_category)
  * locations (location_id PK, standardized location data)
  * product_categories (category_id PK, margin and discount data)
  * data_quality_log (log_id PK, error tracking)

BOTTOM TIER - Gold Layer (Gold boxes):
- 7 views with relationships:
  * dim_customers (customer_key PK, customer_id FK to silver.customers)
  * dim_products (product_key PK, product_id FK to silver.products)
  * fact_sales (order_number + customer_key + product_key PK, FK to dims, + all business logic)
  * customer_metrics (customer_id PK, aggregated KPIs)
  * product_metrics (product_id PK, performance metrics)
  * fulfillment_metrics (order_date PK, daily delivery KPIs)
  * revenue_by_category (category PK, category-level financials)

RELATIONSHIPS:
- Solid lines for direct FK relationships
- Dashed lines for lookup relationships
- Cardinality indicators (1:1, 1:many)
- Color-coded by layer (Orange=Bronze, Gray=Silver, Gold=Gold)
- Include key column names on relationships

LEGEND: Include legend showing relationship types, layer colors, cardinality symbols
STYLE: Professional ERD style, clear entity boxes with attributes, readable fonts, logical layout
```

---

## 🏛️ 5. data_architecture.png - System Architecture

**Prompt:**

```
Create a high-level system architecture diagram for an E-commerce Data Warehouse showing all components and data flows. Use a layered architectural style:

TOP LAYER - Data Sources:
- CRM System box (file share icon) with datasets/source_crm/ path
- ERP System box (database icon) with datasets/source_erp/ path
- CSV files listed: cust_info.csv, prd_info.csv, sales_details.csv, CUST_AZ12.csv, LOC_A101.csv, PX_CAT_G1V2.csv

MIDDLE LAYER - Processing Layer:
- SQL Server 2016+ box with DataWarehouse database
- Three schemas: bronze, silver, gold
- SSMS (SQL Server Management Studio) icon
- Stored procedures: proc_load_bronze, proc_load_silver
- BULK INSERT operations

BOTTOM LAYER - Consumption Layer:
- Business Intelligence tools: Power BI, Tableau, Excel
- User roles: Data Engineers (db_owner), Analysts (read access), BI Tools (service accounts)
- Direct SQL query access

INFRASTRUCTURE ELEMENTS:
- Windows Server box
- Network access indicators
- Storage requirements: ~500 MB
- Security: Windows Authentication

DATA FLOW ARROWS:
- CSV files → BULK INSERT → Bronze tables
- Bronze → Stored Procedures → Silver tables
- Silver → CREATE VIEW → Gold views
- Gold views → BI Tools & Direct Queries

SECURITY & ACCESS:
- Schema-level permissions
- Data classification indicators
- Authentication methods

STYLE: Clean architectural diagram, use icons for components (servers, databases, users), clear data flow arrows, professional color scheme, include component labels and connection types
```

---

## 🔄 6. ETL.png - ETL Process Workflow

**Prompt:**

```
Create a detailed ETL process workflow diagram showing the 6-phase execution flow with error handling. Use a flowchart style with decision points:

START: Environment Pre-checks box
- SQL Server version validation
- File access permissions
- Database connectivity
- Disk space verification

PHASE 1: Database & Schema Setup (Green)
- CREATE DATABASE DataWarehouse
- CREATE SCHEMA bronze, silver, gold
- Set permissions and roles

PHASE 2: Bronze Layer Loading (Orange)
- BULK INSERT customers FROM cust_info.csv
- BULK INSERT products FROM prd_info.csv
- BULK INSERT sales_details FROM sales_details.csv
- BULK INSERT CUST_AZ12, LOC_A101, PX_CAT_G1V2
- Parallel processing indicators

PHASE 3: Silver Layer Transformation (Gray)
- EXEC proc_load_silver
- Data validation and cleansing
- Business logic calculations (profit, delays, segments)
- Cross-system joins (CRM + ERP data)
- Data quality logging

PHASE 4: Gold Layer View Creation (Gold)
- CREATE VIEW statements for 7 analytics views
- Dependency management (dimensions before facts)
- Performance optimization
- Query validation

PHASE 5: Validation & Testing (Blue)
- Row count verification
- Data quality checks
- KPI accuracy validation
- Sample query testing

END: Success/Failure Decision
- Success: Process complete, ready for analytics
- Failure: Error handling and rollback procedures

ERROR HANDLING ELEMENTS:
- TRY/CATCH blocks around each phase
- Logging to data_quality_log table
- Email alerts for failures
- Rollback procedures

SCHEDULING:
- Daily execution (business hours)
- Weekend full refresh
- Monitoring dashboard

STYLE: Professional workflow diagram, use decision diamonds for success/failure, color-code phases (setup=green, bronze=orange, silver=gray, gold=yellow, validation=blue), include timing estimates, clear flow arrows, error handling paths
```

---

## 🎨 General Style Guidelines for All Diagrams

**Color Scheme:**

- Bronze Layer: Orange (#D2691E) or copper tones
- Silver Layer: Gray (#808080) or silver tones
- Gold Layer: Gold (#FFD700) or yellow tones
- Source Systems: Blue (#4169E1) for CRM, Green (#228B22) for ERP
- Processing: Purple (#800080) for ETL operations

**Technical Specifications:**

- High resolution (300 DPI minimum)
- Professional sans-serif fonts (Arial, Calibri, or similar)
- Clear, readable labels
- Consistent icon usage
- White background with colored elements
- Include legends for complex diagrams

**File Formats:**

- PNG for web/docs integration
- PDF for detailed technical diagrams
- SVG for scalable vector graphics

**Quality Standards:**

- No clutter or unnecessary elements
- Clear hierarchy and flow
- Professional technical appearance
- Consistent styling across all diagrams
- Include version numbers and dates

---

**Prompt Version:** 1.0  
**Created:** March 22, 2026  
**Based on:** diagram_specifications.md and project structure  
**Tools:** Nano Banana, Midjourney, DALL-E, or similar AI image generators
