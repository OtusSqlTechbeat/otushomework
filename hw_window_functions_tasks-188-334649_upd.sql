/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/
DROP TABLE IF EXISTS #Invoices
SELECt i.InvoiceID
,i.InvoiceDate
,DATEPART(month,InvoiceDate) as [Month]
,CustomerName
,Quantity*UnitPrice as SumInvoice
INTO #Invoices
FROM [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].InvoiceLines ol On ol.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Sales].[Customers] c ON c.CustomerID=i.CustomerID
WHERE InvoiceDate>='2015-01-01' 

SELECt i.InvoiceID
,CustomerName
,i.InvoiceDate
,SumInvoice
,(select sum(SumInvoice) 
								from  #Invoices i2 
								where i2.InvoiceID=i.InvoiceID  
								  ) as [сумму_нарастающим_итогом]
FROM #Invoices i
ORDER BY i.InvoiceID,InvoiceDate




/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

DROP TABLE IF EXISTS #Result
SELECt InvoiceID
,InvoiceDate
,CustomerName
,SumInvoice as сумму_продажи
,sum(SumInvoice) over(partition by InvoiceID)  as [сумму_нарастающим_итогом]
--INTO #Result
FROM #Invoices
ORDER BY InvoiceID,InvoiceDate

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

;with src as (
SELECT DATEPART(month,i.InvoiceDate) as [Month]
,StockItemID
,ol.Quantity
FROM [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].InvoiceLines ol ON ol.InvoiceID=i.InvoiceID
WHERE i.InvoiceDate between '2016-01-01' AND '2016-12-31'
)
, res as (
SELECT [Month] 
,StockItemID
,Quantity
,row_number() over (partition by  [Month] order by Quantity desc) as num
FROM src
)

SELECT [Month]
,StockItemID,Quantity,num
FROm res
WHERE num IN (1,2)
ORDER BY [Month]

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/


SELECT StockItemID
,StockItemName
,s.[SupplierName]
,UnitPrice
,TypicalWeightPerUnit
,row_number() over (partition by SUBSTRING(StockItemName, 1, 1) order by StockItemName) --пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
,SUM(QuantityPerOuter) over (partition by 1 )--посчитайте общее количество товаров и выведете полем в этом же запросе
,SUM(QuantityPerOuter) over (partition by SUBSTRING(StockItemName, 1, 1))--посчитайте общее количество товаров в зависимости от первой буквы названия товара
,lead(StockItemID) over (partition by 1 order by StockItemName )--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
,lag(StockItemID) over (partition by 1 order by StockItemName )--предыдущий ид товара с тем же порядком отображения (по имени)
,ISNULL(lag(StockItemName,2) over (partition by 1 order by StockItemID ),'No items')--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
,NTILE(30) OVER (ORDER BY TypicalWeightPerUnit) --сформируйте 30 групп товаров по полю вес товара на 1 шт
FROM [WideWorldImporters].[Warehouse].[StockItems] si
INNER JOIn [WideWorldImporters].[Purchasing].[Suppliers] s On s.SupplierID=si.SupplierID

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

;with res as (
SELECt i.SalespersonPersonID
,p.FullName as SalesName
,i.CustomerID
,c.CustomerName
,i.InvoiceDate
,Quantity*UnitPrice as SumInvoice
,row_number() over (partition by i.SalespersonPersonID order by i.InvoiceDate desc ) as num
FROM [WideWorldImporters].[Sales].[Invoices]  i
INNER JOIN [WideWorldImporters].[Sales].InvoiceLines  ol On OL.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Application].[People] p On p.PersonID=i.SalespersonPersonID
INNER JOIN [WideWorldImporters].[Sales].[Customers] c On c.CustomerID=i.CustomerID
)
SELECT r.SalespersonPersonID
,SalesName
,CustomerID
,CustomerName
,InvoiceDate
,SumInvoice
FROM res r
WHERE num=1


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

;with res as (
SELECT i.CustomerID
,c.CustomerName
,st.StockItemID
,st.UnitPrice
,i.InvoiceDate
,dense_rank() over (partition by i.CustomerID order by st.UnitPrice desc ) as num
FROm [WideWorldImporters].[Sales].[Invoices]  i
INNER JOIN [WideWorldImporters].[Sales].InvoiceLines ol ON ol.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Warehouse].[StockItems] st On st.StockItemID=ol.StockItemID
INNER JOIn [WideWorldImporters].[Sales].[Customers] c On c.CustomerID=i.CustomerID
)

SELECT  CustomerID
,CustomerName
,StockItemID
,UnitPrice
,InvoiceDate
FROM res 
WHERE num IN (1,2)

