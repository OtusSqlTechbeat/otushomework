/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM  [Sales].[GetCustomerWithMaxPrice] ()
CREATE FUNCTION [Sales].[GetCustomerWithMaxPrice] ()
RETURNS 
@Result TABLE 
(
	-- Add the column definitions for the TABLE variable here
	CustomerID int, 
	CustomerName varchar(100),
	MaxPrice float
)
AS
BEGIN
DECLARE  @TMP TABLE(CustomerID int, 
	CustomerName varchar(100),
	MaxPrice float)

INSERT INTO @TMP
SELECT i.CustomerID,c.CustomerName,SUM(il.[Quantity]*[UnitPrice]) as MaxPrice 
FROm [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il On il.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Sales].[Customers]  c ON c.CustomerID=i.CustomerID
GROUP BY  i.CustomerID,CustomerName

INSERt INTO @Result
SELECt * FROm @TMP 
WHERE MaxPrice In (
SELECT TOP 1 MaxPrice FROM @TMP
ORDER BY MaxPrice desc
)


	
	RETURN 
END
GO

SELECT * FROM  [Sales].[GetCustomerWithMaxPrice] ()

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sales].[SumPriceByCustomerID]
	-- Add the parameters for the stored procedure here
	@CustomerID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
SELECT i.CustomerID,c.CustomerName,SUM(il.[Quantity]*[UnitPrice]) as MaxPrice 
FROm [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il On il.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Sales].[Customers]  c ON c.CustomerID=i.CustomerID
WHERE i.CustomerID=@CustomerID
GROUP BY  i.CustomerID,CustomerName

END
GO
exec  [Sales].[SumPriceByCustomerID] 149

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Sales].[fn_SumPriceByCustomerID] 
(	
	@CustomerID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT i.CustomerID,c.CustomerName,SUM(il.[Quantity]*[UnitPrice]) as MaxPrice 
FROm [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il On il.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Sales].[Customers]  c ON c.CustomerID=i.CustomerID
WHERE i.CustomerID=@CustomerID
GROUP BY  i.CustomerID,CustomerName
)
GO



Не совсем понял задания,как проверять?
Функция работает быстрее. Нижке анализ. Видно, что Время синтаксического анализа и компиляции SQL Server у функции меньше




SET STATISTICS TIME ON
SET STATISTICS IO ON
SELECT * FROM [Sales].[fn_SumPriceByCustomerID] (149)

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 9 мс, истекшее время = 9 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

(1 row affected)
Таблица "InvoiceLines". Сканирований 2, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 161, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Invoices". Сканирований 1, логических операций чтения 2, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 0, логических операций чтения 2, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 3 мс.

Completion time: 2025-08-04T21:53:41.6397722+03:00
*/


SET STATISTICS TIME ON
SET STATISTICS IO ON
exec  [Sales].[SumPriceByCustomerID] 149

/*
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 0 мс, истекшее время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Время синтаксического анализа и компиляции SQL Server: 
 время ЦП = 13 мс, истекшее время = 13 мс.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 0 мс.
Таблица "InvoiceLines". Сканирований 2, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 161, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "InvoiceLines". Считано сегментов 1, пропущено 0.
Таблица "Invoices". Сканирований 1, логических операций чтения 2, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Worktable". Сканирований 0, логических операций чтения 0, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.
Таблица "Customers". Сканирований 0, логических операций чтения 2, физических операций чтения 0, операций чтения страничного сервера 0, операций чтения, выполненных с упреждением 0, операций чтения страничного сервера, выполненных с упреждением 0, логических операций чтения LOB 0, физических операций чтения LOB 0, операций чтения LOB страничного сервера 0, операций чтения LOB, выполненных с упреждением 0, операций чтения LOB страничного сервера, выполненных с упреждением 0.

 Время работы SQL Server:
   Время ЦП = 0 мс, затраченное время = 4 мс.

 Время работы SQL Server:
   Время ЦП = 16 мс, затраченное время = 17 мс.

Completion time: 2025-08-04T21:53:22.0559492+03:00

*/



/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT * FROM  [Sales].[GetMaxPriceByCustomer]  (148)
ALTER FUNCTION [Sales].[GetMaxPriceByCustomer] (@CustomerID int)
RETURNS 
@Result TABLE 
(
	-- Add the column definitions for the TABLE variable here
	CustomerID int, 
	CustomerName varchar(100),
	MaxPrice float
)
AS
BEGIN
DECLARE  @TMP TABLE(CustomerID int, 
	CustomerName varchar(100),
	MaxPrice float)

INSERT INTO @TMP
SELECT i.CustomerID,c.CustomerName,SUM(il.[Quantity]*[UnitPrice]) as MaxPrice 
FROm [WideWorldImporters].[Sales].[Invoices] i
INNER JOIN [WideWorldImporters].[Sales].[InvoiceLines] il On il.InvoiceID=i.InvoiceID
INNER JOIN [WideWorldImporters].[Sales].[Customers]  c ON c.CustomerID=i.CustomerID
WHERE i.CustomerID=@CustomerID
GROUP BY  i.CustomerID,CustomerName

INSERt INTO @Result
SELECt * FROm @TMP 
WHERE MaxPrice In (
SELECT TOP 1 MaxPrice FROM @TMP
ORDER BY MaxPrice desc
)


	
	RETURN 
END
GO

SELECT 
    c.CustomerID,
    c.CustomerName,
    sp.MaxPrice
FROM 
   [Sales].[Customers]  c
CROSS APPLY     [Sales].[GetMaxPriceByCustomer](c.CustomerID) sp

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
