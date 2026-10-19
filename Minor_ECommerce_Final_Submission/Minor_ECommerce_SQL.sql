-- MINOR PROJECT: E-Commerce Sales Performance Analysis
-- MS SQL Server script

CREATE DATABASE ECommerceAnalytics;
GO
USE ECommerceAnalytics;
GO

CREATE TABLE dbo.SalesTransactions (
    RowID INT PRIMARY KEY,
    OrderID VARCHAR(30),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(30),
    CustomerID VARCHAR(30),
    CustomerName VARCHAR(150),
    Segment VARCHAR(50),
    Country VARCHAR(80),
    City VARCHAR(100),
    Region VARCHAR(30),
    Category VARCHAR(50),
    SubCategory VARCHAR(80),
    ProductName VARCHAR(250),
    Sales DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(8,4),
    Profit DECIMAL(18,2)
);
GO

-- Total Sales by Month
SELECT YEAR(OrderDate) AS SalesYear, MONTH(OrderDate) AS SalesMonth,
       SUM(Sales) AS TotalSales
FROM dbo.SalesTransactions
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY SalesYear, SalesMonth;

-- Top 5 Customers
SELECT TOP 5 CustomerID, CustomerName, SUM(Sales) AS TotalSales
FROM dbo.SalesTransactions
GROUP BY CustomerID, CustomerName
ORDER BY TotalSales DESC;

-- Sales and Profit by Region
SELECT Region, SUM(Sales) AS TotalSales, SUM(Profit) AS TotalProfit,
       CASE WHEN SUM(Sales)=0 THEN 0 ELSE SUM(Profit)/SUM(Sales) END AS ProfitMargin
FROM dbo.SalesTransactions
GROUP BY Region
ORDER BY TotalSales DESC;

-- JOIN example: regional target lookup
CREATE TABLE dbo.RegionTargets (
    Region VARCHAR(30) PRIMARY KEY,
    TargetMargin DECIMAL(8,4)
);
INSERT INTO dbo.RegionTargets VALUES
('West',0.18),('East',0.16),('Central',0.14),('South',0.13);

SELECT s.Region, SUM(s.Sales) AS Sales, SUM(s.Profit) AS Profit,
       rt.TargetMargin
FROM dbo.SalesTransactions s
JOIN dbo.RegionTargets rt ON s.Region=rt.Region
GROUP BY s.Region, rt.TargetMargin;

-- CASE example
SELECT Category,
       SUM(Sales) AS Sales,
       SUM(Profit) AS Profit,
       CASE
         WHEN SUM(Profit)/NULLIF(SUM(Sales),0) >= 0.15 THEN 'High Margin'
         WHEN SUM(Profit)/NULLIF(SUM(Sales),0) >= 0.08 THEN 'Medium Margin'
         ELSE 'Low Margin'
       END AS MarginBand
FROM dbo.SalesTransactions
GROUP BY Category;
