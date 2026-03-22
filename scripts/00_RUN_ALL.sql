/*
=============================================================================
MASTER SCRIPT: Run Complete E-Commerce Data Warehouse Project
=============================================================================
Purpose:
    This script orchestrates the entire data warehouse pipeline:
    1. Initialize Database (Bronze, Silver, Gold schemas)
    2. Create Bronze Layer (Raw data tables)
    3. Load Bronze Layer (BULK INSERT from CSVs)
    4. Create Silver Layer (Cleansed tables)
    5. Load Silver Layer (Transform & enrichment)
    6. Create Gold Layer (Analytics views & KPIs)

Execution Time: ~2-5 minutes (depends on data volume)
Prerequisites: 
    - SQL Server installed and running
    - Dataset CSV files in correct location
    - Proper file permissions

Author: AI Assistant
Date: March 22, 2026
=============================================================================
*/

PRINT '╔════════════════════════════════════════════════════════════════════════╗';
PRINT '║                                                                        ║';
PRINT '║              E-COMMERCE DATA WAREHOUSE - FULL EXECUTION                ║';
PRINT '║                                                                        ║';
PRINT '╚════════════════════════════════════════════════════════════════════════╝';
PRINT '';

-- =========================================================================
-- PHASE 1: INITIALIZE DATABASE
-- =========================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 1: Initialize Database (Create DataWarehouse DB + Schemas)';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    PRINT '>> Dropping existing DataWarehouse database...';
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
    PRINT '>> DataWarehouse database dropped successfully';
END;
GO

-- Create the 'DataWarehouse' database
PRINT '>> Creating new DataWarehouse database...';
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Bronze Schema
PRINT '>> Creating Bronze schema...';
GO
CREATE SCHEMA bronze;
GO

-- Create Silver Schema
PRINT '>> Creating Silver schema...';
GO
CREATE SCHEMA silver;
GO

-- Create Gold Schema
PRINT '>> Creating Gold schema...';
GO
CREATE SCHEMA gold;
GO

PRINT '✓ Database initialization complete!';
PRINT '';
GO

-- =========================================================================
-- PHASE 2: CREATE BRONZE LAYER TABLES
-- =========================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 2: Create Bronze Layer Tables';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

PRINT '>> Creating bronze.crm_cust_info...';
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE
);
GO

PRINT '>> Creating bronze.crm_prd_info...';
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      NVARCHAR(50),
    prd_nm       NVARCHAR(50),
    prd_cost     INT,
    prd_line     NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);
GO

PRINT '>> Creating bronze.crm_sales_details...';
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),
    sls_prd_key  NVARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);
GO

PRINT '>> Creating bronze.erp_loc_a101...';
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),
    cntry  NVARCHAR(50)
);
GO

PRINT '>> Creating bronze.erp_cust_az12...';
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),
    bdate  DATE,
    gen    NVARCHAR(50)
);
GO

PRINT '>> Creating bronze.erp_px_cat_g1v2...';
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),
    cat          NVARCHAR(50),
    subcat       NVARCHAR(50),
    maintenance  NVARCHAR(50)
);
GO

PRINT '✓ Bronze layer tables created successfully!';
PRINT '';

-- =========================================================================
-- PHASE 3: LOAD BRONZE LAYER DATA
-- =========================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 3: Load Bronze Layer Data (BULK INSERT)';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

BEGIN TRY
    SET @batch_start_time = GETDATE();
    
    PRINT '>> Loading CRM source data...';
    
    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    BULK INSERT bronze.crm_cust_info
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    BULK INSERT bronze.crm_prd_info
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    BULK INSERT bronze.crm_sales_details
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    PRINT '';
    PRINT '>> Loading ERP source data...';

    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    BULK INSERT bronze.erp_cust_az12
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    BULK INSERT bronze.erp_loc_a101
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @start_time = GETDATE();
    PRINT '  Loading: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'c:\Users\vshks\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @batch_end_time = GETDATE();
    PRINT '';
    PRINT '✓ Bronze layer data loaded successfully!';
    PRINT '  Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

END TRY
BEGIN CATCH
    PRINT '❌ ERROR during Bronze load: ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
GO
-- =========================================================================
-- PHASE 4: CREATE SILVER LAYER TABLES
-- =========================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 4: Create Silver Layer Tables';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

PRINT '>> Creating silver.crm_cust_info...';
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,
    cst_key            NVARCHAR(50),
    cst_firstname      NVARCHAR(50),
    cst_lastname       NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr           NVARCHAR(50),
    cst_create_date    DATE,
    dwh_create_date    DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Creating silver.crm_prd_info...';
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Creating silver.crm_sales_details...';
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),
    sls_prd_key     NVARCHAR(50),
    sls_cust_id     INT,
    sls_order_dt    DATE,
    sls_ship_dt     DATE,
    sls_due_dt      DATE,
    sls_sales       INT,
    sls_quantity    INT,
    sls_price       INT,
    profit_amount   INT,
    shipping_delay_days INT,
    order_value_category NVARCHAR(20),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Creating silver.erp_loc_a101...';
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),
    cntry           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Creating silver.erp_cust_az12...';
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),
    bdate           DATE,
    gen             NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '>> Creating silver.erp_px_cat_g1v2...';
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),
    cat             NVARCHAR(50),
    subcat          NVARCHAR(50),
    maintenance     NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

PRINT '✓ Silver layer tables created successfully!';
PRINT '';

-- =========================================================================
-- PHASE 5: LOAD SILVER LAYER DATA
-- =========================================================================
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 5: Load Silver Layer Data (Transform & Enrich)';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

BEGIN TRY
    SET @batch_start_time = GETDATE();

    -- Loading silver.crm_cust_info
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    -- Loading silver.crm_prd_info
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    INSERT INTO silver.crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
        prd_nm,
        ISNULL(prd_cost, 0) AS prd_cost,
        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    -- Loading silver.crm_sales_details
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.crm_sales_details (with business logic)';
    TRUNCATE TABLE silver.crm_sales_details;
    INSERT INTO silver.crm_sales_details (
        sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt,
        sls_sales, sls_quantity, sls_price, profit_amount, shipping_delay_days, order_value_category
    )
    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN (sls_quantity * ABS(sls_price)) - (cp.prd_cost * sls_quantity) ELSE sls_sales - (cp.prd_cost * sls_quantity) END,
        DATEDIFF(DAY, CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END, CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END),
        CASE WHEN CASE WHEN sls_sales IS NULL OR sls_sales <= 0 THEN sls_quantity * ABS(sls_price) ELSE sls_sales END > 10000 THEN 'High-Value' WHEN CASE WHEN sls_sales IS NULL OR sls_sales <= 0 THEN sls_quantity * ABS(sls_price) ELSE sls_sales END >= 5000 THEN 'Medium-Value' ELSE 'Standard' END
    FROM bronze.crm_sales_details
    LEFT JOIN silver.crm_prd_info cp ON bronze.crm_sales_details.sls_prd_key = cp.prd_key;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    -- Loading silver.erp_cust_az12
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT
        CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) ELSE cid END,
        CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
        CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female' WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male' ELSE 'n/a' END
    FROM bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    -- Loading silver.erp_loc_a101
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany' WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States' WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a' ELSE TRIM(cntry) END
    FROM bronze.erp_loc_a101;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    -- Loading silver.erp_px_cat_g1v2
    SET @start_time = GETDATE();
    PRINT '>> Transforming: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
    SELECT id, cat, subcat, maintenance FROM bronze.erp_px_cat_g1v2;
    SET @end_time = GETDATE();
    PRINT '    ✓ Done - Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

    SET @batch_end_time = GETDATE();
    PRINT '';
    PRINT '✓ Silver layer data loaded successfully!';
    PRINT '  Total Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

END TRY
BEGIN CATCH
    PRINT '❌ ERROR during Silver load: ' + ERROR_MESSAGE();
END CATCH;

PRINT '';
GO

USE DataWarehouse;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT 'PHASE 6: Create Gold Layer (Analytics Views & KPIs)';
PRINT '═══════════════════════════════════════════════════════════════════════';
PRINT '';

PRINT '>> Creating gold.dim_customers';
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr ELSE COALESCE(ca.gen, 'n/a') END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
GO

PRINT '✓ gold.dim_customers created';

PRINT '>> Creating gold.dim_products';
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance AS maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
GO

PRINT '✓ gold.dim_products created';

PRINT '>> Creating gold.fact_sales (with business metrics)';
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,
    pr.product_key AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price,
    sd.profit_amount AS profit,
    sd.shipping_delay_days AS shipping_delay_days,
    sd.order_value_category AS order_value_category
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
GO

PRINT '✓ gold.fact_sales created';

PRINT '>> Creating gold.customer_metrics (KPI view)';
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
    CASE WHEN SUM(fs.sales_amount) > 100000 THEN 'VIP' WHEN SUM(fs.sales_amount) > 50000 THEN 'Premium' ELSE 'Standard' END AS customer_segment,
    ROUND(SUM(fs.profit) * 100.0 / NULLIF(SUM(fs.sales_amount), 0), 2) AS profit_margin_percent
FROM gold.dim_customers dc
LEFT JOIN gold.fact_sales fs ON dc.customer_key = fs.customer_key
GROUP BY dc.customer_key, dc.customer_id, dc.first_name, dc.last_name, dc.country;
GO

PRINT '✓ gold.customer_metrics created';

PRINT '>> Creating gold.product_metrics (KPI view)';
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
    ROUND(SUM(fs.profit) * 100.0 / NULLIF(SUM(fs.sales_amount), 0), 2) AS profit_margin_percent,
    RANK() OVER (PARTITION BY dp.category ORDER BY SUM(fs.sales_amount) DESC) AS revenue_rank_by_category
FROM gold.dim_products dp
LEFT JOIN gold.fact_sales fs ON dp.product_key = fs.product_key
GROUP BY dp.product_key, dp.product_id, dp.product_name, dp.category, dp.subcategory, dp.cost;
GO

PRINT '✓ gold.product_metrics created';

PRINT '>> Creating gold.fulfillment_metrics (KPI view)';
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

PRINT '✓ gold.fulfillment_metrics created';

PRINT '>> Creating gold.revenue_by_category (KPI view)';
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
LEFT JOIN gold.fact_sales fs ON dp.product_key = fs.product_key
GROUP BY dp.category;
GO

PRINT '✓ gold.revenue_by_category created';
PRINT '';
PRINT '✓ Gold layer views created successfully!';
PRINT '';
GO

-- =========================================================================
-- FINAL SUMMARY
-- =========================================================================
PRINT '';
PRINT '';
PRINT '╔════════════════════════════════════════════════════════════════════════╗';
PRINT '║                                                                        ║';
PRINT '║                   ✓ PROJECT EXECUTION COMPLETE!                        ║';
PRINT '║                                                                        ║';
PRINT '╚════════════════════════════════════════════════════════════════════════╝';
PRINT '';
PRINT 'Summary of Created Objects:';
PRINT '  • Database: DataWarehouse';
PRINT '  • Schemas: bronze, silver, gold';
PRINT '  • Bronze Tables: 6 (raw data)';
PRINT '  • Silver Tables: 6 (cleansed & enriched)';
PRINT '  • Gold Views: 7 (analytics-ready)';
PRINT '    - dim_customers, dim_products, fact_sales';
PRINT '    - customer_metrics, product_metrics';
PRINT '    - fulfillment_metrics, revenue_by_category';
PRINT '';
PRINT 'Next Steps - Query Analytics:';
PRINT '';
PRINT '  1. Customer Analysis:';
PRINT '     SELECT TOP 10 * FROM gold.customer_metrics ORDER BY total_sales DESC;';
PRINT '';
PRINT '  2. Product Performance:';
PRINT '     SELECT TOP 10 * FROM gold.product_metrics ORDER BY revenue DESC;';
PRINT '';
PRINT '  3. Fulfillment Quality:';
PRINT '     SELECT * FROM gold.fulfillment_metrics ORDER BY order_date DESC;';
PRINT '';
PRINT '  4. Category Revenue:';
PRINT '     SELECT * FROM gold.revenue_by_category ORDER BY total_revenue DESC;';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════════════';
