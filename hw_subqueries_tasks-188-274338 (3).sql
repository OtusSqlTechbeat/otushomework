/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT PersonID
,FullName
FROm WideWorldImporters.Application.People p
LEFT OUTER JOIN (
SELECt SalespersonPersonID FROm Sales.Invoices i 
WHERE InvoiceDate='2015-07-04'
)sp On sp.SalespersonPersonID=p.PersonID
WHERE IsSalesPerson=1
AND sp.SalespersonPersonID IS NULL

--через WITH (для производных таблиц)
;with invoice as (
SELECt SalespersonPersonID FROm Sales.Invoices i 
WHERE InvoiceDate='2015-07-04'
)
SELECT PersonID
,FullName
FROm WideWorldImporters.Application.People p
LEFT OUTER JOIN invoice sp On sp.SalespersonPersonID=p.PersonID
WHERE IsSalesPerson=1
AND sp.SalespersonPersonID IS NULL

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/


SELECT StockItemID,StockItemName,UnitPrice FROM [WideWorldImporters].[Warehouse].[StockItems]
WHERE UnitPrice IN (
SELECT MIN(UnitPrice) FROM [WideWorldImporters].[Warehouse].[StockItems]
)



/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

;with maxta as (
SELECT TOP 5 CustomerID,TransactionAmount FROM [WideWorldImporters].Sales.CustomerTransactions
ORDER BY TransactionAmount desc
)
SELECT c.CustomerID
,c.CustomerName
,m.TransactionAmount
FROM [WideWorldImporters].[Sales].[Customers] c
INNER JOIN maxta m ON m.CustomerID=c.CustomerID
ORDER BY TransactionAmount desc

DROP TABLE IF EXISTS #MaxTA
SELECT TOP 5 CustomerID,TransactionAmount
INTO #MaxTA
FROM [WideWorldImporters].Sales.CustomerTransactions
ORDER BY TransactionAmount desc

SELECT c.CustomerID
,c.CustomerName
,m.TransactionAmount
FROM [WideWorldImporters].[Sales].[Customers] c
INNER JOIN #MaxTA m ON m.CustomerID=c.CustomerID
ORDER BY TransactionAmount desc



/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/
--выбираю топ 3 самых дорогих товара
;with stocks as (
SELECT TOP 3 StockItemID,UnitPrice FROm [WideWorldImporters].[Warehouse].[StockItems]
ORDER By UnitPrice desc
)
--подтягиваю информацию о продажах , кто упаковал и кому отправили
,invoicelines as (
SELECT il.InvoiceID,il.StockItemID,s.UnitPrice,p.FullName as PackedByName,CustomerID FROm [WideWorldImporters].[Sales].InvoiceLines il
INNER JOIN [WideWorldImporters].[Sales].[Invoices] i ON i.InvoiceID=il.InvoiceID
INNER JOIn stocks s ON s.StockItemID=il.StockItemID
INNER JOIN WideWorldImporters.Application.People p ON p.PersonID=i.PackedByPersonID
)
--подтягиваю города и вывожу результат
SELECT DISTINCT cit.CityID
,cit.CityName
FROm invoicelines i
INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON c.CustomerID=i.CustomerID
INNER JOIN WideWorldImporters.[Application].[Cities] cit On cit.CityID=c.DeliveryCityID


-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос


SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
/*
Собирает общие продажи у которых сумма продаж больше 27000
По ним показывает продавца
TotalSummForPickedItems по заказам у которых o.PickingCompletedWhen IS NOT NULL


Ниже запрос более читабельный
оптимизации заключается в уменьшении подзапросов.
В плане запросов меньше операций
*/

;with salestotals as (
SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000
)
,totalsummforpickeditems as (
SELECT ol.OrderID,SUM(ol.PickedQuantity*ol.UnitPrice) as TotalSummForPickedItems
		FROM WideWorldImporters.Sales.OrderLines ol
INNER JOIN Sales.Orders o On o.OrderID=ol.OrderID  
WHERE o.PickingCompletedWhen IS NOT NULL
GROUP By ol.OrderID
)

SELECT i.InvoiceID
,InvoiceDate
,p.FullName SalesPersonName
,TotalSumm as TotalSummByInvoice
,TotalSummForPickedItems
FROm WideWorldImporters.Sales.Invoices  i
INNER JOIN salestotals st On st.InvoiceID=i.InvoiceID
LEFt OUTER JOIN totalsummforpickeditems t ON t.OrderID=i.OrderID
LEFT OUTER JOIN WideWorldImporters.Application.People p On p.PersonID = i.SalespersonPersonID
ORDER BY TotalSumm DESC
