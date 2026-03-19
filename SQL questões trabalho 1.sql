/* AdventureWorks Sales & Performance Analysis
   Author: João Videira
   Description: SQL queries for extracting Revenue, Profit, and Ranking KPIs.
*/

---------------------------------------------------------
-- 1. REVENUE ANALYSIS
---------------------------------------------------------

-- 1.1. Total Revenue per Year
-- Logic: Grouping by year using the SalesOrderHeader table.
SELECT 
    YEAR(OrderDate) AS [Year],
    SUM(SubTotal) AS Revenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY [Year];

-- 1.2. Seasonality: Revenue by Month and Year
-- Logic: Monthly breakdown to identify purchase patterns.
SELECT 
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    SUM(SubTotal) AS Revenue
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY [Year], [Month];

-- 1.3. Aggregated Monthly Revenue (Seasonal Pattern)
-- Logic: Summing all "Januaries", "Februaries", etc., to detect business seasonality.
SELECT 
    MONTH(OrderDate) AS [Month],
    SUM(SubTotal) AS Revenue
FROM Sales.SalesOrderHeader
GROUP BY MONTH(OrderDate)
ORDER BY [Month];


---------------------------------------------------------
-- 2. PROFITABILITY ANALYSIS
---------------------------------------------------------

-- 2.1. Profit per Year
-- Formula: (LineTotal) - (OrderQty * StandardCost).
-- Requires joining Sales and Production tables.
SELECT
    YEAR(h.OrderDate) AS [Year],
    SUM((d.LineTotal) - (d.OrderQty * p.StandardCost)) AS Profit
FROM Sales.SalesOrderDetail D
JOIN Production.Product P ON d.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader H ON d.SalesOrderID = h.SalesOrderID
GROUP BY YEAR(h.OrderDate)
ORDER BY [Year];

-- 2.2. Profit per Month (Historical)
SELECT
    YEAR(h.OrderDate) AS [Year],
    MONTH(h.OrderDate) AS [Month],
    SUM((d.LineTotal) - (d.OrderQty * p.StandardCost)) AS Profit
FROM Sales.SalesOrderDetail D
JOIN Production.Product P ON d.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader H ON d.SalesOrderID = h.SalesOrderID
GROUP BY YEAR(h.OrderDate), MONTH(h.OrderDate)
ORDER BY [Year], [Month];


---------------------------------------------------------
-- 3. KEY PERFORMANCE INDICATORS (KPIs)
---------------------------------------------------------

-- 3.1. Discount Analysis
-- Average discount global and per product.
SELECT 
    ProductID,
    AVG(UnitPriceDiscount) AS AvgDiscount
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY AvgDiscount DESC;

-- 3.2. Total Volume: Quantity of items sold
-- Logic: Monitoring physical product flow over time.
SELECT 
    YEAR(h.OrderDate) AS [Year],
    MONTH(h.OrderDate) AS [Month],
    CAST(SUM(d.OrderQty) AS DECIMAL(10,0)) AS TotalQty
FROM Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D ON h.SalesOrderID = d.SalesOrderID
GROUP BY YEAR(h.OrderDate), MONTH(h.OrderDate)
ORDER BY [Year], [Month];

-- 3.3. Monthly Margin Analysis
SELECT 	
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    (SUM(d.LineTotal) - SUM(d.OrderQty * p.StandardCost)) AS MarginAbsolute
FROM Sales.SalesOrderDetail D
JOIN Production.Product P ON d.ProductID = p.ProductID
JOIN Sales.SalesOrderHeader H ON d.SalesOrderID = h.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY [Year], [Month];


---------------------------------------------------------
-- 4. RANKINGS (WINDOW FUNCTIONS)
---------------------------------------------------------

-- 4.1. Monthly Ranking per Year
-- Logic: Identifies the best/worst month within each specific year using PARTITION BY.
SELECT 
    YEAR(h.OrderDate) AS [Year],
    MONTH(h.OrderDate) AS [Month],
    SUM(h.SubTotal - (p.StandardCost * d.OrderQty)) AS Profit,
    RANK() OVER (
        PARTITION BY YEAR(h.OrderDate) 
        ORDER BY SUM(d.LineTotal - (p.StandardCost * d.OrderQty)) DESC
    ) AS MonthlyRank
FROM Sales.SalesOrderHeader H
LEFT JOIN Sales.SalesOrderDetail D ON h.SalesOrderID = d.SalesOrderID
LEFT JOIN Production.Product P ON d.ProductID = p.ProductID
GROUP BY YEAR(h.OrderDate), MONTH(h.OrderDate)
ORDER BY [Year], [Month];


---------------------------------------------------------
-- 5. AUDIT & SPECIFIC PRODUCT ANALYSIS
---------------------------------------------------------

-- 5.1. Loss Identification (Audit 2012-2013)
-- Logic: Filtering products with negative profit where discounts were applied.
SELECT 
    p.[Name],
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    FORMAT(SUM(d.LineTotal - p.StandardCost * d.OrderQty), 'N0') AS Profit,
    FORMAT(AVG(d.UnitPriceDiscount), 'P') AS AvgDiscount
FROM Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product P ON d.ProductID = p.ProductID
WHERE p.SellEndDate IS NOT NULL
  AND YEAR(OrderDate) BETWEEN 2012 AND 2013
  AND MONTH(OrderDate) IN (4, 6)
GROUP BY YEAR(OrderDate), MONTH(OrderDate), p.[Name]
HAVING AVG(d.UnitPriceDiscount) <> 0
ORDER BY [Year], [Month];

-- 5.2. Detailed Product Analysis (ID 778)
-- Logic: Tracking performance evolution of a specific item.
SELECT 
    p.Name,
    YEAR(OrderDate) AS [Year],
    MONTH(OrderDate) AS [Month],
    FORMAT(SUM(d.LineTotal - p.StandardCost * d.OrderQty), 'N0') AS Profit,
    AVG(d.UnitPriceDiscount) AS AvgDiscount
FROM Sales.SalesOrderHeader H
JOIN Sales.SalesOrderDetail D ON h.SalesOrderID = d.SalesOrderID
JOIN Production.Product P ON d.ProductID = p.ProductID
WHERE p.ProductID = 778
GROUP BY YEAR(OrderDate), MONTH(OrderDate), p.Name
ORDER BY [Year], [Month];
