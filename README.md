# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 🚀  
This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

---

## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## 📊 Architecture Documentation

This project includes comprehensive documentation of the data warehouse architecture:

### Core Documentation Files

- **[diagram_specifications.md](docs/diagram_specifications.md)**: Detailed specifications for creating architecture diagrams (data flows, ERDs, system architecture)
- **[data_catalog.md](docs/data_catalog.md)**: Complete catalog of datasets with field descriptions and metadata
- **[naming_conventions.md](docs/naming_conventions.md)**: Consistent naming standards for tables, columns, and files

### Architecture Overview

| Layer      | Purpose             | Data State             | Access Method       |
| ---------- | ------------------- | ---------------------- | ------------------- |
| **Bronze** | Raw data storage    | As-is from sources     | Direct table access |
| **Silver** | Cleansed & enriched | Business logic applied | Transformed views   |
| **Gold**   | Analytics-ready     | Pre-aggregated KPIs    | Star schema views   |

For detailed specifications on architecture components, see [docs/diagram_specifications.md](docs/diagram_specifications.md).

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:

- SQL Development
- Data Architect
- Data Engineering
- ETL Pipeline Developer
- Data Modeling
- Data Analytics

---

## 🛠️ Important Links & Tools:

Everything is for Free!

- **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting your SQL database.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** Set up a GitHub account and repository to manage, version, and collaborate on your code efficiently.
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Notion](https://www.notion.com/templates/sql-data-warehouse-project):** Get the Project Template from Notion
- **[Notion Project Steps](https://thankful-pangolin-2ca.notion.site/SQL-Data-Warehouse-Project-16ed041640ef80489667cfe2f380b269?pvs=4):** Access to All Project Phases and Tasks.

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications

- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

---

### BI: Analytics & Reporting (Data Analysis)

#### Objective

Develop SQL-based analytics to deliver detailed insights into:

- **Customer Behavior**
- **Product Performance**
- **Sales Trends**

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

For more details, refer to [docs/requirements.md](docs/requirements.md).

---

## 🧭 How to Find What You Need

| I want to...                        | Go to...                                                           | Why?                                                         |
| ----------------------------------- | ------------------------------------------------------------------ | ------------------------------------------------------------ |
| **Set up the project**              | [docs/requirements.md](docs/requirements.md)                       | Complete setup instructions and prerequisites                |
| **Understand the data model**       | [docs/data_catalog.md](docs/data_catalog.md)                       | Field descriptions, data types, and business rules           |
| **Follow naming conventions**       | [docs/naming_conventions.md](docs/naming_conventions.md)           | Consistent naming standards for tables, columns, and files   |
| **See architecture specifications** | [docs/diagram_specifications.md](docs/diagram_specifications.md)   | Detailed specs for data flows, ERDs, and system architecture |
| **Check data quality**              | [tests/quality_checks_silver.sql](tests/quality_checks_silver.sql) | Data validation and quality assurance                        |
| **Run the ETL process**             | [scripts/init_database.sql](scripts/init_database.sql)             | Database setup and initial load                              |

---

## 🆘 Support & Troubleshooting

### Common Issues & Solutions

| Issue                   | Symptom                              | Solution                                                                                      |
| ----------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------- |
| **Permission Errors**   | "Access denied" when running scripts | Run SSMS as Administrator, check file permissions                                             |
| **Missing Data**        | Tables appear empty after loading    | Verify CSV file paths, check BULK INSERT permissions                                          |
| **Connection Issues**   | Can't connect to SQL Server          | Ensure SQL Server service is running, check connection string                                 |
| **Schema Errors**       | "Invalid object name" errors         | Run scripts in correct order: init_database.sql first                                         |
| **Data Quality Issues** | Unexpected NULL values or duplicates | Check [tests/quality_checks_silver.sql](tests/quality_checks_silver.sql) for validation rules |

### Getting Help

| Question Type              | Resource                                                         | Details                                          |
| -------------------------- | ---------------------------------------------------------------- | ------------------------------------------------ |
| **Setup Issues**           | [docs/requirements.md](docs/requirements.md)                     | Prerequisites, installation, and configuration   |
| **Data Model Questions**   | [docs/data_catalog.md](docs/data_catalog.md)                     | Field definitions, relationships, business rules |
| **Architecture Questions** | [docs/diagram_specifications.md](docs/diagram_specifications.md) | System design, layer purposes, data flows        |
| **ETL Problems**           | [scripts/](scripts/) + [tests/](tests/)                          | Script execution, error handling, validation     |
| **Naming Standards**       | [docs/naming_conventions.md](docs/naming_conventions.md)         | Table/column naming, file organization           |

### Quick Start Checklist

- ✅ SQL Server 2016+ installed and running
- ✅ SSMS installed and connected
- ✅ CSV files in correct [datasets/](datasets/) folders
- ✅ Execute [scripts/init_database.sql](scripts/init_database.sql) first
- ✅ Run Bronze, Silver, Gold scripts in sequence
- ✅ Validate with [tests/quality_checks_silver.sql](tests/quality_checks_silver.sql)

```
data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── diagram_specifications.md       # Detailed specifications for creating architecture diagrams
│   ├── etl.                 # Draw.io file shows all different techniquies and methods of ETL
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```

---

## 📝 Document Metadata

| Document                      | Lines | Created      | Version | Type       |
| ----------------------------- | ----- | ------------ | ------- | ---------- |
| **data_catalog.md**           | 500+  | Mar 22, 2026 | 2.0     | Reference  |
| **naming_conventions.md**     | 150+  | Mar 22, 2026 | 2.0     | Reference  |
| **diagram_specifications.md** | 280+  | Mar 22, 2026 | 1.0     | Reference  |
| **README.md** (this file)     | 200+  | Mar 22, 2026 | 2.0     | Navigation |

**Total Documentation:** ~1,200+ lines of detailed guides + diagram specifications

---

## ✅ Next Steps

1. **New to the project?** → Read [docs/requirements.md](docs/requirements.md) for setup
2. **Need data details?** → Check [docs/data_catalog.md](docs/data_catalog.md)
3. **Understanding architecture?** → Review [docs/diagram_specifications.md](docs/diagram_specifications.md)
4. **Following standards?** → Reference [docs/naming_conventions.md](docs/naming_conventions.md)
5. **Having issues?** → See troubleshooting section above

---

**Happy analyzing! 🎉**

For questions or updates, refer to the appropriate documentation file above.
