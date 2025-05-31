/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

;with src as (
SELECT DISTINCT i.CustomerID
,REPLACE(REPLACE(c.CustomerName,'Tailspin Toys (',''),')','') as CustomerName
--,InvoiceDate
,CAST(DATEADD(m, DATEDIFF(m, 0, InvoiceDate), 0) as date) as InvoiceDate
,InvoiceID
FROM [WideWorldImporters].[Sales].[Invoices]  i
INNER JOIn [WideWorldImporters].[Sales].[Customers] c On c.CustomerID=i.CustomerID AND c.CustomerID between 2 and 6
)


select CONVERT(varchar(100),InvoiceDate,104) AS InvoiceDate
,[Gasport, NY] 
,[Jessie, ND]
,[Medicine Lodge, KS]
,[Peeples Valley, AZ]
,[Sylvanite, MT]
from
(select CustomerName, InvoiceID,InvoiceDate from src)
as src
pivot
(
count(InvoiceID) 
for CustomerName 
in ([Gasport, NY] ,[Jessie, ND],[Medicine Lodge, KS],[Peeples Valley, AZ],[Sylvanite, MT])
)
as result



/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName, AddressLine
from [WideWorldImporters].[Sales].[Customers]
unpivot
(
AddressLine for columnname in (DeliveryAddressLine1,DeliveryAddressLine2,PostalAddressLine1,PostalAddressLine2)
) as T_unpivot
where CustomerName LIKE '%Tailspin Toys%'

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

DROP TABLE iF EXISTS #Result
CREATE TABLE #Result (
CountryID int
,CountryName varchar(60)
,IsoAlpha3Code varchar(3)
,IsoNumericCode varchar(3)
)
INSERT INTO #Result
SELECt CountryID
,CountryName
,CAST(IsoAlpha3Code as varchar(3)) as IsoAlpha3Code
,CAST(IsoNumericCode as varchar(3)) as IsoNumericCode
FROm [WideWorldImporters].Application.Countries


select CountryID, CountryName
,Code 
from #Result
unpivot
(
Code for columnname in (IsoAlpha3Code,IsoNumericCode)
) as T_unpivot


--не понимаю, почему вот так не работает. Также, только в CTE привожу к одному формату
;with res as (
SELECt CountryID
,CountryName
,CAST(IsoAlpha3Code as varchar(3)) as IsoAlpha3Code
,CAST(IsoNumericCode as varchar(3)) as IsoNumericCode
FROm [WideWorldImporters].Application.Countries
)

select CountryID, CountryName
,Code 
from res
unpivot
(
Code for columnname in (IsoAlpha3Code,IsoNumericCode)
) as T_unpivot



/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
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
INNER JOIN [WideWorldImporters].[Sales].[OrderLines] ol ON ol.OrderID=i.OrderID
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
