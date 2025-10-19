

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [YearData]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Years', FILENAME = N'D:\DZFilesgroups\Yeardata.ndf' , 
SIZE = 1097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [YearData]
GO
--[Sales].[Orders_DZ]
-- граничные точки
CREATE PARTITION FUNCTION [fnYearPartition](DATE) 
AS 
	RANGE RIGHT FOR VALUES ('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');
GO

-- расположение секций 
CREATE PARTITION SCHEME [schmYearPartition] 
AS 
	PARTITION [fnYearPartition] ALL TO ([YearData])
GO


--создаем таблицу для секционированния 
SELECT * INTO [Sales].[OrdersPartitioned]
FROM Sales.Orders;

USE [WideWorldImporters]
GO

/****** Object:  Table [Sales].[Orders_DZ]    Script Date: 19.10.2025 19:04:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Sales].[OrdersYear](
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
)  ON [schmYearPartition]([OrderDate])
GO



--создадим кластерный индекс в той же схеме с ключом секционирования
ALTER TABLE [Sales].[OrdersYear] 
	ADD CONSTRAINT PK_Sales_OrdersYear
	PRIMARY KEY CLUSTERED  (OrderDate, OrderID) ON [schmYearPartition](OrderDate);

	
CREATE TABLE [Sales].[OrderLinesYear](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmYearPartition]([OrderDate])

ALTER TABLE [Sales].[OrderLinesYear] 
	ADD CONSTRAINT PK_Sales_OrderLinesYear
	PRIMARY KEY CLUSTERED  (OrderDate, OrderID, OrderLineID) ON [schmYearPartition](OrderDate);


INSERT INTO [Sales].[OrdersYear]
           ([OrderID]
           ,[CustomerID]
           ,[SalespersonPersonID]
           ,[PickedByPersonID]
           ,[ContactPersonID]
           ,[BackorderOrderID]
           ,[OrderDate]
           ,[ExpectedDeliveryDate]
           ,[CustomerPurchaseOrderNumber]
           ,[IsUndersupplyBackordered]
           ,[Comments]
           ,[DeliveryInstructions]
           ,[InternalComments]
           ,[PickingCompletedWhen]
           ,[LastEditedBy]
           ,[LastEditedWhen])

SELECt [OrderID]
           ,[CustomerID]
           ,[SalespersonPersonID]
           ,[PickedByPersonID]
           ,[ContactPersonID]
           ,[BackorderOrderID]
           ,[OrderDate]
           ,[ExpectedDeliveryDate]
           ,[CustomerPurchaseOrderNumber]
           ,[IsUndersupplyBackordered]
           ,[Comments]
           ,[DeliveryInstructions]
           ,[InternalComments]
           ,[PickingCompletedWhen]
           ,[LastEditedBy]
           ,[LastEditedWhen]
FROM [Sales].[Orders]



DECLARE @start DATE = '20120101';
DECLARE @end DATE = '20221231';

INSERT INTO [Sales].[OrderLinesYear]
           ([OrderLineID]
           ,[OrderID]
           ,[OrderDate]
           ,[StockItemID]
           ,[Description]
           ,[PackageTypeID]
           ,[Quantity]
           ,[UnitPrice]
           ,[TaxRate]
           ,[PickedQuantity]
           ,[PickingCompletedWhen]
           ,[LastEditedBy]
           ,[LastEditedWhen])
SELECt 
[OrderLineID]
           ,[OrderID]
           , DATEADD(
    DAY,
    ABS(CHECKSUM(NEWID())) % (DATEDIFF(DAY, @start, @end) + 1),
    @start
) 
           ,[StockItemID]
           ,[Description]
           ,[PackageTypeID]
           ,[Quantity]
           ,[UnitPrice]
           ,[TaxRate]
           ,[PickedQuantity]
           ,[PickingCompletedWhen]
           ,[LastEditedBy]
           ,[LastEditedWhen]
FROm [Sales].[OrderLines]

selecT count(*) from [Sales].[OrderLinesYear]
selecT count(*) from [Sales].[OrdersYear]


-- Ctrl + M 
-- без фильтра на ключ секционирования
set statistics time, io on
SELECT ord.OrderID, ord.OrderDate, Details.Quantity, Details.UnitPrice,ord.CustomerID
FROM Sales.[OrdersYear] AS ord
JOIN Sales.[OrderLinesYear] AS Details ON ord.OrderID = Details.OrderID AND ord.OrderDate = Details.OrderDate
WHERE ord.CustomerID=22


-- с фильтром
SELECT ord.OrderID, ord.OrderDate, Details.Quantity, Details.UnitPrice
FROM Sales.[OrdersYear] AS ord
JOIN Sales.[OrderLinesYear] AS Details ON ord.OrderID = Details.OrderID AND ord.OrderDate = Details.OrderDate
WHERE ord.CustomerID = 22
	AND ord.OrderDate > '20120101' AND ord.OrderDate < '20160501'
