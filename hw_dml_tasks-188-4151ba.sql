/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


INSERT INTO [WideWorldImporters].[Sales].[Customers]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
SELECt TOP 5
[CustomerID]+2000
           ,[CustomerName]+'_INSERT'
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy]

FROm [WideWorldImporters].[Sales].[Customers]


SELECt * FROm [WideWorldImporters].[Sales].[Customers]
WHERE CustomerID>2000



/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

 DELETE FROm [WideWorldImporters].[Sales].[Customers]
WHERE CustomerID=2005



/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [WideWorldImporters].[Sales].[Customers] SET CustomerName='Test_Update'
WHERE CustomerID=2004

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

DROP TABLE IF EXISTS #TargetTable
SELECT TOP 5
CustomerID
,CustomerName
INTO #TargetTable
FROM [WideWorldImporters].[Sales].[Customers]
WHERE CustomerID IN (1,5,7,2001)

DROP TABLE IF EXISTS #SourceTable
SELECT TOP 5
CustomerID
,CustomerName
INTO #SourceTable
FROM [WideWorldImporters].[Sales].[Customers]
WHERE CustomerID IN (2003,2004,2001,2002)

--SELECT * FROM #TargetTable
--SELECT * FROM #SourceTable

MERGE #TargetTable AS Target
USING #SourceTable AS Source
    ON (Target.CustomerID = Source.CustomerID)
WHEN MATCHED 
    THEN UPDATE 
        SET CustomerName = Source.CustomerName
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (Source.CustomerID, Source.CustomerName)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;

SELECT * FROM #TargetTable
SELECT * FROM #SourceTable

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/


DECLARE @out varchar(250);
set @out = 'bcp [WideWorldImporters].[Sales].[Customers] OUT "D:\bcp\dz.txt" -T -c -S ' + @@SERVERNAME;
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS #Customers
SELECT * 
INTO #Customers
FROM [WideWorldImporters].[Sales].[Customers]
WHERE 1=2


BULK INSERT #Customers
    FROM "D:\bcp\dz.txt"
	WITH 
		(
		BATCHSIZE = 1000,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK
		);

SELECT * FROM #Customers
