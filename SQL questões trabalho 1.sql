--qual é o revenue por ano?
select 
year(orderdate) as  'Year',
sum(subtotal) as Revenue
from sales.salesorderheader
group by year(OrderDate)
order by Year

select
year(h.orderdate) as  'Year',
sum(d.LineTotal) as Total
from sales.SalesOrderDetail D
join sales.SalesOrderHeader H
	on d.SalesOrderID=h.SalesOrderID
group by  year(h.OrderDate)

--REVENUE com ano e mês de cada ano
select 
year(orderdate) as  'Year',
month(orderdate) as 'Month',
sum(subtotal) as Revenue
from sales.salesorderheader
group by year(OrderDate), 
		month(OrderDate)
order by Year

--qual é o revenue por mês?
select
month(orderdate) as 'Month',
sum (subtotal) as Revenue
from sales.SalesOrderHeader
group by month(OrderDate)
order by Month

--qual é o profit por ano?
select
year(h.orderdate) as 'Year',
SUM((d.LineTotal) - (d.OrderQty * p.StandardCost)) as Profit
from sales.SalesOrderDetail D
	join Production.Product P
	on d.ProductID=p.ProductID
	join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by year(h.orderdate)
order by year(h.orderdate)



--Profit com Ano e mês de cada ano
select
month(h.OrderDate) as 'Month',
year(h.orderdate) as 'Year',
SUM((d.LineTotal) -(d.OrderQty * p.StandardCost)) as Profit
from sales.SalesOrderDetail D
	join Production.Product P
	on d.ProductID=p.ProductID
	join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by year(h.orderdate),
		month(h.OrderDate)
order by year(h.orderdate)


--qual é o profit por mês?
select
month(h.orderdate) as 'Month',
SUM(d.LineTotal) - (d.OrderQty * p.StandardCost) as Profit
from sales.SalesOrderDetail D
	join Production.Product P
	on d.ProductID=p.ProductID
	join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by month(h.orderdate)
order by month(h.orderdate)

--Qual é o Avg do discount?
select	avg(UnitPriceDiscount) AS AvgDiscount
from Sales.SalesOrderDetail

select
	productid,
	avg(UnitPriceDiscount) AS AvgDiscount
from Sales.SalesOrderDetail
group by ProductID
order by AvgDiscount desc

select
ProductID,
max(unitpricediscount) as Discount
from sales.SalesOrderDetail
group by ProductID
order by Discount desc

-- Quantity of items sold

SELECT 
    YEAR(h.OrderDate)  AS [Year],
    MONTH(h.OrderDate) AS [Month],
    CAST(SUM(d.OrderQty) AS DECIMAL(10,0)) AS totalQTY
FROM Sales.SalesOrderHeader h
join Sales.SalesOrderDetail d
on h.SalesOrderID = d.SalesOrderID
GROUP BY YEAR(h.OrderDate), MONTH(h.OrderDate)
ORDER BY [Year] ASC, [Month] ASC


--Qual é a margem?
select 	
	year(OrderDate) 'Year',
	month(OrderDate) 'Month',
	(sum(d.LineTotal) - sum(d.OrderQty * p.StandardCost))  as MarginPercent
from sales.SalesOrderDetail d
join Production.Product p
	on d.ProductID=p.ProductID
join sales.SalesOrderHeader H
	on d.SalesOrderID=h.SalesOrderID
group by 
	year(orderdate),
	month(orderdate)
order by year(orderdate) asc, month(OrderDate)

--Qual é a margem por cada AVG?
select 
	Year(h.orderdate) as 'Year',
	Month(h.orderdate) as 'Month',
	format(avg(d.LineTotal - (d.OrderQty * p.StandardCost)),'#.##') as AvgMarginPercent 
FROM Sales.SalesOrderDetail d
JOIN Production.Product p
    ON d.ProductID = p.ProductID
join sales.salesorderheader h
	on d.SalesOrderID=h.SalesOrderID
group by 
	Year(h.orderdate),
	Month(h.orderdate) 
order by Year asc, Month asc


--RANK YEAR
with MarginCalcYear as (
select 
	year(h.OrderDate) as YearDate,
	(sum(d.LineTotal) - sum(d.OrderQty * p.StandardCost))/sum(h.SubTotal)  as Margin
from sales.SalesOrderDetail d
join Production.Product p
	on d.ProductID=p.ProductID
join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by year(h.OrderDate)
)

select 
YearDate as 'Year',
RANK () over(
	order by Margin desc
	) as YearRank
from MarginCalcYear

--RANK MONTH ( Rank mensal total, para perceber o melhor mês e o pior ano)
with MarginCalcMonth as (
select 
	Year(h.orderdate) as YearDate,
	month(h.OrderDate) as MonthDate,
	sum((d.LineTotal)-(d.OrderQty * p.StandardCost))  as Margin
from sales.SalesOrderDetail d
join Production.Product p
	on d.ProductID=p.ProductID
join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by month(h.OrderDate),Year(h.orderdate)
)

select 
Yeardate as 'Year',
MonthDate as 'Month',
RANK () over(
	order by Margin desc
	) as MonthRank
from MarginCalcMonth

--RANK MENSAL POR ANO (Querie com partition by year para perceber os melhores e os piores meses de cada ano)
SELECT 
    YEAR(h.orderdate)  AS [Year],
    MONTH(h.orderdate) AS [Month],
    SUM(h.subtotal - (p.StandardCost*d.orderqty)) AS profit,
    rank () over (partition by Year(h.orderdate)
            order by SUM(d.linetotal - (p.StandardCost*d.orderqty)) desc
            ) as RankMês
FROM Sales.SalesOrderHeader h
    left join Sales.SalesOrderDetail d
    on h.SalesOrderID = d.SalesOrderID
    left join Production.Product p
    on d.ProductID = p.ProductID
GROUP BY YEAR(h.orderdate), MONTH(h.orderdate)
ORDER BY [Year] ASC, [Month] ASC


--RANK QUARTER
with MarginCalcQuarter as (
select 
	year(OrderDate) as YearDate,
	datepart(quarter,h.OrderDate) as QuarterDate,
	sum((d.LineTotal) - (d.OrderQty * p.StandardCost))  as Margin
from sales.SalesOrderDetail d
join Production.Product p
	on d.ProductID=p.ProductID
join sales.SalesOrderHeader h
	on d.SalesOrderID=h.SalesOrderID
group by datepart(quarter,h.OrderDate),year(OrderDate)
)

select 
YearDate as 'Year',
QuarterDate as 'Quarter',
Margin,
RANK () over(
	order by Margin desc
	) as QuarterRank
from MarginCalcQuarter


--Pesquisa dos meses com prejuizo de 2012, por produto tendo em conta o desconto realizado.
SELECT 
    p.[Name],
    YEAR(orderdate)  AS [Year],
    MONTH(orderdate) AS [Month],
    format(SUM(d.LineTotal - p.StandardCost * d.OrderQty),'n0') AS Profit,
    format(avg(d.UnitPriceDiscount), '#.##%') avgDesconto
FROM Sales.SalesOrderHeader h
join Sales.SalesOrderDetail d
on h.SalesOrderID = d.SalesOrderID
join Production.Product p
on d.ProductID = p.ProductID
where
 p.SellEndDate is not Null
 and year(OrderDate) between 2012 and 2013
 and MONTH(OrderDate) in (4,6)
GROUP BY YEAR(orderdate), MONTH(orderdate),p.Name
having avg(d.UnitPriceDiscount) <>0
order by 'year','month'

--Analise da margem de um produto em concreto (ex:778)
SELECT 
    p.Name,
    d.ProductID,
    YEAR(orderdate)  AS [Year],
    MONTH(orderdate) AS [Month],
    format(SUM(d.LineTotal - p.StandardCost * d.OrderQty),'n0') AS Profit,
    avg(d.UnitPriceDiscount)
FROM Sales.SalesOrderHeader h
join Sales.SalesOrderDetail d
on h.SalesOrderID = d.SalesOrderID
join Production.Product p
on d.ProductID = p.ProductID
where P.ProductID = 778


GROUP BY YEAR(orderdate), MONTH(orderdate),d.ProductID,p.Name
order by 'year','month'