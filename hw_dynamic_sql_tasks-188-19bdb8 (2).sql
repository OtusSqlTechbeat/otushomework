/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

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

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DROP TABLE IF EXISTS #SRC
SELECT DISTINCT i.CustomerID
,c.CustomerName
--,InvoiceDate
,CAST(DATEADD(m, DATEDIFF(m, 0, InvoiceDate), 0) as date) as InvoiceDate
,InvoiceID
INTO #SRC
FROM [WideWorldImporters].[Sales].[Invoices]  i
INNER JOIn [WideWorldImporters].[Sales].[Customers] c On c.CustomerID=i.CustomerID 


DECLARE @query AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)


SELECT @ColumnName= ISNULL(@ColumnName + ',','') 
       + QUOTENAME(CustomerName)
FROM (SELECT DISTINCT  CustomerName
         FROM #SRC ) AS Names

			 --SELECt @ColumnName

SET @query = 
  N'
select CONVERT(varchar(100),InvoiceDate,104) AS InvoiceDate
,' +@ColumnName + '
from
(select CustomerName, InvoiceID,InvoiceDate from #SRC )
as src
pivot
(
count(InvoiceID) 
for CustomerName 
in (' +@ColumnName + ')
)
as result

'

EXEC sp_executesql @query

