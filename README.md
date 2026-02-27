# 📈 Advanced Analytics & Business Intelligence: From Data to Insights

## 🌟 Project Overview
This project represents the **Intelligence Layer** of a full-scale data lifecycle. Building upon a robust [Data Warehouse Foundation](https://github.com/JacobDaniel-82/sql-data-warehouse-project), this repository focuses on transforming raw warehouse tables into actionable business insights.

The project is divided into two primary phases:
1. **Exploratory Data Analysis (EDA):** A 6-step deep dive into data distributions and quality.
2. **Advanced Analytics:** A 5-step analytical framework involving YoY growth, cumulative metrics, and customer segmentation.

---

## 🏗️ Technical Foundation
While this repository contains the analytical logic, it is highly dependent on the Gold Layer of the Medallion Architecture. 

> [!TIP]
> **New Visitors:** It is highly recommended to check out the [Data Warehouse Repository](https://github.com/JacobDaniel-82/sql-data-warehouse-project) first to understand how the underlying data was engineered, cleansed, and modeled.

---

## 📁 Repository Structure
```text
├── datasets/             # Exported Gold Layer files (Fact & Dimensions)
├── docs/                 # Architecture diagrams & Analytics Data Model
│   └── data_catalog.md   # Metadata & Column descriptions for Gold views
├── scripts/              
│   ├── eda_gold.sql      # Phase 1: 6-Step Exploratory Data Analysis
│   ├── advanced_analytics.sql # Phase 2: 5-Step Advanced Business Analytics
│   └── report_views.sql  # Final Curated Reporting Models (Product/Customer)
└── README.md             # Project documentation 
```
---

## 🚀 Analytical Journey

### Phase 1: 6-Step Exploratory Data Analysis (EDA)
Before modeling, I performed a rigorous exploration to understand the data's boundaries:
1. **Metadata Exploration:** Investigating schemas and data types.
2. **Dimension Profiling:** Checking unique values and hierarchies.
3. **Date Profiling:** Analyzing birthdates and order ranges for lifecycle analysis.
4. **KPI Baseline:** Establishing "Ground Truth" for Sales, Orders, and Customers.
5. **Magnitude Analysis:** Geography and Category-based volume checks.
6. **Ranking Analysis:** Identifying initial top/bottom performers.

### Phase 2: 5-Step Advanced Analytics
Using T-SQL window functions and CTEs, I developed complex business logic:
1. **Time-Series Analysis:** Monthly and yearly sales trends.
2. **Cumulative Metrics:** Running totals and rolling 3-month averages.
3. **Performance Analysis (YoY):** Year-over-Year growth per product.
4. **Part-to-Whole Analysis:** Category contribution percentages to total revenue.
5. **Data Segmentation:** - **Products:** Cost-range grouping.
    - **Customers:** VIP, Regular, and New segments based on lifespan and spend.

---

## 📊 Business Reporting Layer
The final output consists of two curated views in the `gold` schema, designed for direct consumption by BI tools (Power BI/Tableau):

* **`gold.report_products`**: Consolidates revenue, quantity, and AOR (Average Order Revenue) with performance tiering.
* **`gold.report_customers`**: Merges demographics with behavioral data (Recency, Lifespan, and Segment).

![Analytics Data Model](docs/data_model.png)

---

## 💡 Business Insights & Executive Summary

After executing the Advanced Analytics suite, several critical business patterns emerged that provide a roadmap for strategic decision-making.

### 1. Revenue Concentration (The 96% Rule)
* **Insight:** The **Bikes** category is the primary engine of the business, contributing a staggering **96% of total revenue**. 
* **Observation:** While **Accessories** and **Clothing** have high transaction volumes, their low unit price means they currently serve only as "add-on" items rather than primary revenue drivers.
* **Recommendation:** Focus marketing budget primarily on high-margin bike models. Consider "Bundling" strategies where a bike purchase includes discounted accessories to increase the Average Order Value (AOV) of the lower-performing categories.

### 2. Customer Segmentation & Loyalty
* **Insight:** A significant portion of the database consists of **"New"** customers (lifespan < 12 months). However, the **"VIP"** segment (long-term high-spenders) generates a disproportionate amount of the annual profit.
* **Observation:** There is a "drop-off" point after the first 6 months where customer engagement dips.
* **Recommendation:** Implement a **Customer Retention Program** specifically for "Regular" customers to transition them into "VIP" status. Targeted email campaigns at the 10-month mark could prevent churn.

### 3. Product Performance & Lifecycle
* **Insight:** Ranking analysis revealed that 5 specific bike models account for the majority of the "High-Performer" segment.
* **Observation:** Certain sub-categories in Clothing have been stagnant for the last two quarters (Recency > 6 months).
* **Recommendation:** Liquidate "Low-Performer" clothing stock through seasonal sales to free up warehouse space for high-demand bike inventory.

### 4. Geographic Expansion
* **Insight:** Magnitude analysis shows that two specific countries dominate the customer base, but the **Average Monthly Spend** is higher in smaller, emerging regions.
* **Recommendation:** Explore localized marketing in high-spending "niche" regions to diversify the geographic risk currently concentrated in the top two countries.

---

## 🤝 Let's Connect!

If you found this project interesting, I’d love to connect and chat about Data Engineering, Data Analytics, and Business Intelligence. 

- **Explore More:** This is just one part of my journey. Check out my [📂 Full Portfolio](https://github.com/JacobDaniel-82) to see my projects.
- **Professional Network:** Let's stay in touch on [💼 LinkedIn](https://www.linkedin.com/in/jacobdanielr) (I'm active here!).
- **Get in Touch:** Have a question or a suggestion? Feel free to reach out via [📧 Email](mailto:jacobdanielr82@gmail.com): jacobdanielr82@gmail.com

*Designed and Engineered by **Jacob Daniel R** | 2026*
