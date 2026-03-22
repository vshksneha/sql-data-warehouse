# Architecture Diagrams - Content Specifications

This document specifies what each architecture diagram should contain for the E-commerce Data Warehouse project.

---

## 📊 data_flow.png - ETL Data Flow Diagram

### **Purpose**

Visual representation of the complete data pipeline from source systems to business intelligence tools.

### **Required Elements**

1. **Source Systems Box**
   - CRM System (3 CSV files)
   - ERP System (3 CSV files)
   - File paths: `datasets/source_crm/` and `datasets/source_erp/`

2. **Bronze Layer Box**
   - 6 tables: customers, products, sales_details, CUST_AZ12, LOC_A101, PX_CAT_G1V2
   - BULK INSERT operations
   - Raw data storage

3. **Silver Layer Box**
   - 6 tables: customers, products, sales_transactions, locations, product_categories, data_quality_log
   - Business logic additions (profit, delays, segments)
   - Data cleansing and enrichment

4. **Gold Layer Box**
   - 7 views: dim_customers, dim_products, fact_sales, customer_metrics, product_metrics, fulfillment_metrics, revenue_by_category
   - Analytics-ready aggregations

5. **Consumption Layer**
   - Power BI, Tableau, Excel
   - Direct SQL queries
   - Reporting tools

### **Flow Arrows**

- CSV → Bronze (BULK INSERT)
- Bronze → Silver (stored procedures)
- Silver → Gold (CREATE VIEW)
- Gold → BI Tools (queries)

### **Key Annotations**

- Data volumes (19K customers, 18K orders, etc.)
- Processing frequency (daily)
- Business logic additions in Silver layer

---

## 🔗 data_integration.png - Source System Integration

### **Purpose**

Shows how CRM and ERP systems integrate and what data is exchanged.

### **Required Elements**

1. **CRM System Box**
   - cust_info.csv → bronze.customers
   - prd_info.csv → bronze.products
   - sales_details.csv → bronze.sales_details
   - Data types and record counts

2. **ERP System Box**
   - CUST_AZ12.csv → bronze.CUST_AZ12 (supplementary customer data)
   - LOC_A101.csv → bronze.LOC_A101 (warehouse locations)
   - PX_CAT_G1V2.csv → bronze.PX_CAT_G1V2 (pricing & categories)
   - Data types and record counts

3. **Integration Points**
   - LEFT JOIN between bronze.customers and bronze.CUST_AZ12
   - Enrichment of products with ERP pricing data
   - Location data for fulfillment analytics

4. **Data Quality Considerations**
   - Duplicate handling
   - Missing data scenarios
   - Data validation rules

---

## 🏗️ data_layers.pdf - Medallion Architecture Layers

### **Purpose**

Detailed explanation of the Bronze → Silver → Gold layer responsibilities.

### **Bronze Layer Section**

- **Purpose**: Raw data repository
- **Characteristics**:
  - No transformations
  - Exact copy of source data
  - Schema-on-read approach
  - Historical data preservation
- **Tables**: 6 raw tables
- **Operations**: BULK INSERT only

### **Silver Layer Section**

- **Purpose**: Cleansed and enriched business data
- **Transformations**:
  - Data validation and cleansing
  - Standardization (uppercase, trimming)
  - Business logic calculations
  - Cross-system data integration
- **New Columns Added**:
  - profit_amount, profit_margin_percent
  - shipping_delay_days, shipped_on_time
  - order_value_category, customer_segment
  - credit_limit, account_active
- **Tables**: 6 enriched tables

### **Gold Layer Section**

- **Purpose**: Analytics-ready views
- **Characteristics**:
  - Query-time aggregation
  - Business-friendly naming
  - Pre-calculated KPIs
  - Optimized for reporting
- **Views**: 7 analytics views
- **Categories**: Dimensions, Facts, Metrics

### **Layer Relationships**

- Bronze: Foundation (raw data)
- Silver: Transformation (business logic)
- Gold: Presentation (analytics)

---

## 📋 data_model.png - Entity Relationship Diagram

### **Purpose**

Complete database schema showing all tables, views, and relationships.

### **Layout Requirements**

1. **Bronze Schema** (top section)
   - 6 tables in logical groups
   - Primary keys and foreign keys
   - Data types for key columns

2. **Silver Schema** (middle section)
   - 6 tables with relationships
   - New columns highlighted
   - Business logic indicators

3. **Gold Schema** (bottom section)
   - 7 views with relationships
   - Dimension-fact relationships
   - Aggregation indicators

### **Key Relationships to Show**

- bronze.customers.customer_id → silver.customers.customer_id
- bronze.products.product_id → silver.products.product_id
- silver.customers.customer_id → gold.fact_sales.customer_key
- silver.products.product_id → gold.fact_sales.product_key
- gold.dim_customers.customer_key → gold.fact_sales.customer_key
- gold.dim_products.product_key → gold.fact_sales.product_key

### **Legend**

- Solid lines: Direct relationships
- Dashed lines: Lookup relationships
- Different colors for each layer
- Cardinality indicators (1:1, 1:many)

---

## 🏛️ data_architecture.png - System Architecture

### **Purpose**

High-level system components and infrastructure.

### **Required Elements**

1. **Data Sources**
   - CRM system (file share)
   - ERP system (file share)
   - CSV file locations

2. **Database Server**
   - SQL Server 2016+
   - DataWarehouse database
   - Bronze/Silver/Gold schemas

3. **ETL Components**
   - SSMS for execution
   - Stored procedures
   - BULK INSERT operations

4. **User Access**
   - Data engineers (db_owner)
   - Analysts (read access)
   - BI tools (service accounts)

5. **Infrastructure**
   - Windows Server
   - Network access
   - Storage requirements

6. **Security**
   - Windows Authentication
   - Schema-level permissions
   - Data classification

---

## 🔄 ETL.png - ETL Process Workflow

### **Purpose**

Step-by-step ETL execution flow with error handling.

### **Workflow Elements**

1. **Phase 1: Environment Setup**
   - Pre-checks (SQL Server version, file access)
   - Database creation
   - Schema creation

2. **Phase 2: Bronze Loading**
   - BULK INSERT for each CSV
   - Error handling and logging
   - Data validation

3. **Phase 3: Silver Transformation**
   - Stored procedure execution
   - Business logic calculations
   - Data quality checks
   - Cross-system joins

4. **Phase 4: Gold View Creation**
   - CREATE VIEW statements
   - Dependency management
   - Performance optimization

5. **Phase 5: Validation**
   - Row count verification
   - Data quality checks
   - KPI accuracy validation

6. **Error Handling**
   - TRY/CATCH blocks
   - Logging to data_quality_log
   - Rollback procedures

### **Scheduling**

- Daily execution (business hours)
- Weekend full refresh
- Monitoring and alerting

---

## 🎨 Diagram Standards

### **Visual Consistency**

- Use consistent color scheme (Bronze=orange, Silver=gray, Gold=yellow)
- Standard icons for databases, files, processes
- Clear labels and annotations
- Professional appearance

### **Tools Recommended**

- Microsoft Visio
- Lucidchart
- Draw.io
- PowerPoint

### **File Formats**

- PNG for web/docs (data_flow.png, data_model.png, etc.)
- PDF for detailed diagrams (data_layers.pdf)
- High resolution (300 DPI minimum)

---

## 📝 Update Requirements

**When to Update Diagrams:**

- New data sources added
- Schema changes
- New business logic
- Architecture modifications
- Team onboarding

**Version Control:**

- Include version numbers
- Date stamps
- Change logs

---

**Document Version:** 1.0  
**Last Updated:** March 22, 2026  
**Next Review:** Q2 2026
