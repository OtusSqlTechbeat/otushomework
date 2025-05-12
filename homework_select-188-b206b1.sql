/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT StockItemID,StockItemName FROM Warehouse.StockItems
WHERE StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT s.SupplierID,SupplierName FROM Purchasing.Suppliers s
LEFT OUTER JOIN Purchasing.PurchaseOrders  p ON p.SupplierID=s.SupplierID
WHERE p.SupplierID IS NULL



/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

SELECT o.OrderID
	,convert(varchar, OrderDate, 104) as OrderDate
	,FORMAT(OrderDate, 'MMMM', 'ru-ru') as 'Месяц'
	,datepart(quarter, OrderDate) as 'Квартал'
	,CASE 
			WHEN MONTH(OrderDate) BETWEEN 1 AND 4 THEN 1
			WHEN MONTH(OrderDate) BETWEEN 5 AND 8 THEN 2
			WHEN MONTH(OrderDate) BETWEEN 9 AND 12 THEN 3
		END AS 'Треть года'
	,c.CustomerName
	,ol.PickingCompletedWhen
FROM Sales.Orders o
	INNER JOIN Sales.OrderLines ol On ol.OrderID=o.OrderID AND (UnitPrice>100 OR  Quantity>20) AND ol.PickingCompletedWhen IS NOT NULL
	INNER JOIN Sales.Customers c ON c.CustomerID=o.CustomerID
ORDER BY datepart(quarter, OrderDate)
	,CASE 
			WHEN MONTH(OrderDate) BETWEEN 1 AND 4 THEN 1
			WHEN MONTH(OrderDate) BETWEEN 5 AND 8 THEN 2
			WHEN MONTH(OrderDate) BETWEEN 9 AND 12 THEN 3
		END 
	,OrderDate desc



SELECT o.OrderID
	,convert(varchar, OrderDate, 104) as OrderDate
	,FORMAT(OrderDate, 'MMMM', 'ru-ru') as 'Месяц'
	,datepart(quarter, OrderDate) as 'Квартал'
	,CASE 
			WHEN MONTH(OrderDate) BETWEEN 1 AND 4 THEN 1
			WHEN MONTH(OrderDate) BETWEEN 5 AND 8 THEN 2
			WHEN MONTH(OrderDate) BETWEEN 9 AND 12 THEN 3
		END AS 'Треть года'
	,c.CustomerName
FROM Sales.Orders o
	INNER JOIN Sales.OrderLines ol On ol.OrderID=o.OrderID AND (UnitPrice>100 OR  Quantity>20) AND ol.PickingCompletedWhen IS NOT NULL
	INNER JOIN Sales.Customers c ON c.CustomerID=o.CustomerID
ORDER BY datepart(quarter, OrderDate)
	,CASE 
			WHEN MONTH(OrderDate) BETWEEN 1 AND 4 THEN 1
			WHEN MONTH(OrderDate) BETWEEN 5 AND 8 THEN 2
			WHEN MONTH(OrderDate) BETWEEN 9 AND 12 THEN 3
		END 
	,OrderDate desc
OFFSET 1000 ROWS
FETCH NEXT 100 ROWS ONLY

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT DeliveryMethodName
	,ExpectedDeliveryDate
	,s.SupplierName
	,p.FullName
FROM Purchasing.Suppliers s
	INNER JOIN Purchasing.PurchaseOrders po ON po.SupplierID=s.SupplierID AND ExpectedDeliveryDate between '2013-01-01' AND '2013-01-31' AND IsOrderFinalized=1
	INNER JOIN Application.DeliveryMethods d On d.DeliveryMethodID=po.DeliveryMethodID AND d.DeliveryMethodName IN ('Air Freight','Refrigerated Air Freight')
	INNER JOIN Application.People p On p.PersonID=po.ContactPersonID


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10 o.OrderID
	,OrderDate
	,c.CustomerName
	,p.FullName as SalesName
FROM  Sales.Orders o
	INNER JOIN Sales.Customers c ON c.CustomerID=o.CustomerID
	INNER JOIN Application.People p ON p.PersonID=o.SalespersonPersonID
ORDER BY OrderDate desc


/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/
SELECT c.CustomerID
	,c.CustomerName
	,PhoneNumber
	,FaxNumber
FROm Sales.Customers  c
	INNER JOIN Sales.Orders o ON o.CustomerID=c.CustomerID
	INNER JOIN Sales.OrderLines ol On ol.OrderID=o.OrderID
	INNER JOIN Warehouse.StockItems si On si.StockItemID=ol.StockItemID AND StockItemName='Chocolate frogs 250g'

