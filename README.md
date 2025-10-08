# 📊 Enterprise Data Warehouse Architecture & Modeling (Kimball Methodology)

## 🏗 Introduction
This project demonstrates the end-to-end design and implementation of a **modern Enterprise Data Warehouse (EDW)** solution.  
The goal was to integrate data from multiple disparate systems into a unified analytical platform that provides accurate, consistent, and reliable insights across business units.  

The architecture follows **Ralph Kimball’s dimensional modeling methodology**, enabling scalable data integration, standardized reporting, and a single source of truth for enterprise analytics.

---

## 🧩 Problem Statement
The organization faced challenges with fragmented data across multiple systems — including relational databases, flat files (CSV), and third-party applications.  

This resulted in:
- Inconsistent reporting and duplicated metrics  
- Data quality issues and lack of centralized governance  
- Limited visibility into performance across departments  

To address these challenges, a **centralized data warehouse** was designed and implemented to streamline data flow, improve data quality, and enhance analytical capabilities.

---

## 🧠 Skills Demonstrated
- **Data Modeling:** Star schema, dimensional modeling, conformed dimensions  
- **ETL Development:** Source-to-target mapping, data cleansing, transformation, and load automation  
- **Data Architecture:** Multi-layered architecture (Staging → EDW → Data Marts)  
- **Business Analysis:** Requirement gathering, stakeholder identification, and bus matrix design  
- **Documentation:** Technical & business documentation using industry best practices  
- **Tools & Technologies:**  
  - SQL Server, Excel, Visio  
  - Kimball Methodology, ETL scripting, Dimensional Modeling

---

## 🗂 Data Sourcing
Data was ingested from multiple sources including:
- **SQL Server Databases** (transactional systems)  
- **CSV and Excel files** from business users  
- **OData feeds** for external integrations  

Each source was profiled and staged for further transformation and cleansing.

---

## 🔄 Data Transformation
The ETL process was designed to:
- Cleanse and validate incoming data  
- Apply business transformation rules  
- Standardize reference data (e.g., date, product, customer dimensions)   
- Load transformed data into the Enterprise Data Warehouse (EDW)

📁 **Documentation:**
- [Source to Target Mapping - Fact Tables](./SourceTargetMapping-Fact.xlsx)  
- [Source to Target Mapping - Dimension Tables](./Source%20to%20Target%20Mapping%20-%20Dimension.xlsx)

🧱 **SQL Scripts:**
> *(Placeholder for SQL scripts — add links once uploaded)*  
> - [ETL SQL Scripts Folder](./SQL_Scripts/)

---

## 🧮 Data Modeling
The **Enterprise Data Warehouse (EDW)** was designed following the **Kimball approach**, featuring:
- **Fact tables** for business processes (e.g., sales, operations, finance)  
- **Dimension tables** with conformed and role-playing dimensions (e.g., date, customer, product)  
- **Data Marts** developed for specific business units  

📊 **Supporting Artifacts:**
- [Data Warehouse Model](./Data%20Warehouse%20Model.png)  
- [Bus Matrix](./Bus%20Matrix.xlsx)  
- [Architecture Diagram](./Architecture.png)

---

## 👥 Stakeholder & Requirements Management
Key documentation artifacts created to ensure alignment between business and technical teams:
- [Solution Requirements Document](./Solution%20Requirements.docx)  
- [Stakeholder Matrix](./Stakeholder%20Matrix.xlsx)

These deliverables helped define scope, identify data owners, and ensure each business unit’s analytical needs were addressed.

---

## ✅ Conclusion
This project successfully delivered a **scalable, maintainable, and business-aligned data warehouse** solution.  
It established a consistent data foundation for reporting and analytics while demonstrating strong data architecture, modeling, and ETL development practices.

The result is a **single version of the truth** for enterprise reporting, enabling faster and more accurate decision-making across departments.

---


