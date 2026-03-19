# Sql-Project--TechOf
Exploratory sales and business performance analysis using SQL and Excel on the AdventureWorks database. Focused on revenue, profit, and seasonality KPIs.

#Sales & Performance Analysis: AdventureWorks (SQL & Excel)
📌 Project Overview
This project focuses on a strategic analysis of the AdventureWorks database using SQL for data extraction and Excel for reporting. The main goal was to extract Key Performance Indicators (KPIs) such as revenue, profit, margins, and seasonality to provide a data-driven business perspective.

🛠️ Tech Stack
•	SQL: Used for complex data extraction, table joins, and analytical functions.
•	Microsoft Excel: Applied for data cleaning, pivot tables, and visual reporting.
•	PowerPoint: Used for storytelling and final presentation of insights.

📊 Key Analyses & Logic
1. Revenue & Seasonality Analysis
•	Yearly Revenue: Calculated by grouping sales by year using YEAR(OrderDate). I validated data integrity by comparing the Header SubTotal with the LineTotal sum.
•	Seasonal Patterns: Aggregated monthly sales regardless of the year to identify recurring purchase behaviors. This helped detect if specific months consistently outperformed others.
2. Profitability & Margins
•	Profit Calculation: Developed a custom formula: (LineTotal) - (OrderQty * StandardCost). This required joining three tables: SalesOrderDetail, SalesOrderHeader, and Production.Product.
•	Average Margin: Calculated the profit per individual item sold to evaluate sales "quality" beyond raw volume.
3. Rankings and Advanced SQL Functions
•	Monthly Global Ranking: Used Common Table Expressions (CTEs) and the RANK() function to classify months based on absolute margin.
•	Yearly Performance: Applied PARTITION BY Year to reset rankings annually, identifying the best and worst month for each specific year.
4. Deep Dive: Loss Identification
•	Audit of Negative Margins: Filtered for products that generated losses during specific periods (2012-2013).
•	Discount Impact: Used the HAVING clause to correlate losses with high discount rates (UnitPriceDiscount), auditing if promotions were hurting overall profitability.

💡 Business Insights
•	Summer Peaks: Data shows a clear upward trend in revenue during the summer months, aligning with the nature of the products sold.
•	Strategic Disruption: Mass discounts in 2012 caused a financial anomaly that forced the company into a recovery cycle.
•	Growth Trend: Despite historical challenges, the company shows a solid growth trajectory in both revenue and profit consolidation after June 2012.

📫 Contact
João Videira 
•	LinkedIn: linkedin.com/in/joão-videira-5685501b4 
•	Email: joaovideira1998@gmail.com
