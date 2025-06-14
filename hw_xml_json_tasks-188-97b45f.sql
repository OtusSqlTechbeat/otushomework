/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

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
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/


DECLARE @xmlDocument XML;

SELECT @xmlDocument = BulkColumn
FROM OPENROWSET(BULK 'D:\DZ\XML_JSON\StockItems-188-1fb5df.xml', SINGLE_CLOB) as t

SELECT @xmlDocument AS [@xmlDocument];

DECLARE @docHandle INT;
EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument;

DROP TABLE IF EXISTS #StockItems_Source
SELECt StockItemName,SupplierID,UnitPackageID,OuterPackageID,LeadTimeDays,QuantityPerOuter,IsChillerStock,TaxRate,UnitPrice 
INTO #StockItems_Source
FROM Warehouse.StockItems
WHERE 1=2

INSERT INTO #StockItems_Source (StockItemName,SupplierID,UnitPackageID,OuterPackageID,LeadTimeDays,QuantityPerOuter,IsChillerStock,TaxRate,UnitPrice)
SELECT
StockItemName
,SupplierID
,UnitPackageID
,OuterPackageID
,LeadTimeDays
,QuantityPerOuter
,IsChillerStock
,TaxRate
,UnitPrice
FROM OPENXML(@docHandle, N'/StockItems/Item') --путь к строкам
WITH ( 
   StockItemName varchar(100) '@Name',
	SupplierID INT  'SupplierID', 
	UnitPackageID INT 'Package/UnitPackageID', 
	OuterPackageID INT 'Package/OuterPackageID',
	QuantityPerOuter INT 'Package/QuantityPerOuter',
	TypicalWeightPerUnit float 'Package/TypicalWeightPerUnit',
	LeadTimeDays int 'LeadTimeDays',
	IsChillerStock int 'IsChillerStock',
	TaxRate float 'TaxRate',
	UnitPrice float 'UnitPrice'
	)

-- удаляем handle
EXEC sp_xml_removedocument @docHandle;


/* вариант через XQuery

DROP TABLE IF EXISTS #StockItems_Source
DECLARE @x XML
SET @x = (
		SELECT *
		FROM OPENROWSET(BULK 'D:\DZ\XML_JSON\StockItems-188-1fb5df.xml', SINGLE_BLOB) AS d
		)
SELECT  
  StockItemName = t.Item.value('(@Name)[1]', 'varchar(100)')
  , SupplierID = t.Item.value('(SupplierID)[1]', 'int')
  , UnitPackageID = t.Item.value('(Package/UnitPackageID)[1]', 'int')
  , OuterPackageID = t.Item.value('(Package/OuterPackageID)[1]', 'int')
  , QuantityPerOuter = t.Item.value('(Package/QuantityPerOuter)[1]', 'int')
  , TypicalWeightPerUnit = t.Item.value('(Package/TypicalWeightPerUnit)[1]', 'float')
  , LeadTimeDays = t.Item.value('(LeadTimeDays)[1]', 'int')
  , IsChillerStock = t.Item.value('(IsChillerStock)[1]', 'int')
  , TaxRate = t.Item.value('(TaxRate)[1]', 'float')
  , UnitPrice = t.Item.value('(UnitPrice)[1]', 'float')
INTO  #StockItems_Source
FROM @x.nodes('/StockItems/Item') AS t(Item)



*/

SELECT * FROm #StockItems_Source

DROP TABLE IF EXISTS #StockItems_Target
SELECT StockItemName,SupplierID,UnitPackageID,OuterPackageID,LeadTimeDays,QuantityPerOuter,IsChillerStock,TaxRate,UnitPrice 
INTO #StockItems_Target
FROm Warehouse.StockItems


SELECT * FROm #StockItems_Target
SELECT * FROm #StockItems_Source

MERGE #StockItems_Target AS Target
USING #StockItems_Source AS Source
    ON (Target.StockItemName = Source.StockItemName)
WHEN MATCHED 
    THEN UPDATE 
        SET StockItemName = Source.StockItemName
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (  Source.StockItemName, Source.SupplierID,Source.UnitPackageID,Source.OuterPackageID,Source.LeadTimeDays,Source.QuantityPerOuter,Source.IsChillerStock,Source.TaxRate,Source.UnitPrice)
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;





/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT StockItemName as [@Name]
,SupplierID as [SupplierID]
,UnitPackageID as [Package/UnitPackageID]
,OuterPackageID as[Package/OuterPackageID]
,QuantityPerOuter as [Package/QuantityPerOuter]
,TypicalWeightPerUnit as [Package/TypicalWeightPerUnit]
,LeadTimeDays
,IsChillerStock
,TaxRate
,UnitPrice
FROm [Warehouse].[StockItems]
FOR XML PATH('Item'), ROOT('StockItems')

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

SELECT * FROm [Warehouse].[StockItems]

select StockItemID
,StockItemName
, t.* 
from Warehouse.StockItems as i
outer apply openjson(CustomFields) with (
	CountryOfManufacture varchar(100) '$.CountryOfManufacture'
	, FirstTag varchar(20) '$.Tags[1]'
	) t

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/



SELECT DISTINCT
    s.StockItemID,
    s.StockItemName,
	CustomFields,
    STRING_AGG(t2.value, ', ') WITHIN GROUP (ORDER BY t2.value) AS AllTags
FROM Warehouse.StockItems s
CROSS APPLY OPENJSON(CustomFields, '$.Tags') t
CROSS APPLY OPENJSON(CustomFields, '$.Tags') t2
WHERE t.value = 'Vintage'
GROUP BY s.StockItemID, s.StockItemName,CustomFields
