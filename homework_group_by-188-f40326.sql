/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) as InvoiceYear
	,Month(i.InvoiceDate) as InvoiceMonth
	,AVG(UnitPrice) as AVGUnitPrice
FROm Sales.Invoices i
	INNER JOIN Sales.OrderLines ol ON ol.OrderID=i.OrderID
GROUP BY YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)
ORDER By YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)




/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT YEAR(i.InvoiceDate) as OrderYear
	,Month(i.InvoiceDate) as OrderMonth
	,SUM(UnitPrice*Quantity) as SumUnitPrice
FROm Sales.Invoices i
	INNER JOIN Sales.OrderLines ol ON ol.OrderID=i.OrderID
GROUP BY YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)
HAVING SUM(UnitPrice*Quantity)>4600000
ORDER By YEAR(i.InvoiceDate)
	,SUM(UnitPrice*Quantity)






/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
    YEAR(i.InvoiceDate) AS InvoiceYear
    ,MONTH(i.InvoiceDate) AS InvoiceMonth
    ,StockItemName
    ,SUM(Quantity) AS SumQuantity
    ,SUM(Quantity * ol.UnitPrice) AS SumUnitPrice
    ,MIN(i.InvoiceDate) AS FirstInvoiceDate
FROm Sales.Invoices i 
INNER JOIN Sales.OrderLines ol ON ol.OrderID=i.OrderID
INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
GROUP BY 
    YEAR(i.InvoiceDate), 
    MONTH(i.InvoiceDate), 
    StockItemName
HAVING SUM(Quantity) < 50
ORDER BY  YEAR(i.InvoiceDate)
	,MONTH(i.InvoiceDate)
	,StockItemName

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/



SELECT  
YEAR(i.InvoiceDate) as InvoiceYear
,Month(i.InvoiceDate) as InvoiceMonth
,ISNULL(SumUnitPrice,0) as SumUnitPrice
FROm Sales.Invoices i
LEFT  JOIN (
	SELECT YEAR(i.InvoiceDate) as InvoiceYear
		,Month(i.InvoiceDate) as InvoiceMonth
		,SUM(UnitPrice*Quantity) as SumUnitPrice
	FROm Sales.Invoices i
		INNER JOIN Sales.OrderLines ol ON ol.OrderID=i.OrderID
	GROUP BY YEAR(i.InvoiceDate),Month(i.InvoiceDate)
	HAVING SUM(UnitPrice*Quantity)>4600000
) t ON t.InvoiceYear=YEAR(i.InvoiceDate) AND t.InvoiceMonth=Month(i.InvoiceDate)
GROUP BY YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)
	,SumUnitPrice
ORDER By YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)


SELECT  
YEAR(i.InvoiceDate) as InvoiceYear
,Month(i.InvoiceDate) as InvoiceMonth
,ISNULL(StockItemName,0) as StockItemName
,ISNULL(SumQuantity,0) as SumQuantity
,ISNULL(SumUnitPrice,0) as SumUnitPrice
,FirstInvoiceDate as FirstInvoiceDate
FROm Sales.Invoices i
LEFT  JOIN (
SELECT 
    YEAR(i.InvoiceDate) AS InvoiceYear
    ,MONTH(i.InvoiceDate) AS InvoiceMonth
    ,StockItemName
    ,SUM(Quantity) AS SumQuantity
    ,SUM(Quantity * ol.UnitPrice) AS SumUnitPrice
    ,MIN(i.InvoiceDate) AS FirstInvoiceDate
FROm Sales.Invoices i 
INNER JOIN Sales.OrderLines ol ON ol.OrderID=i.OrderID
INNER JOIN Warehouse.StockItems si ON ol.StockItemID = si.StockItemID
GROUP BY 
    YEAR(i.InvoiceDate), 
    MONTH(i.InvoiceDate), 
    StockItemName
HAVING SUM(Quantity) < 50
) t ON t.InvoiceYear=YEAR(i.InvoiceDate) AND t.InvoiceMonth=Month(i.InvoiceDate)
GROUP BY YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)
	,SumUnitPrice
	,StockItemName
	,SumQuantity
	,FirstInvoiceDate
ORDER By YEAR(i.InvoiceDate)
	,Month(i.InvoiceDate)