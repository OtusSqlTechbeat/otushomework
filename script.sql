

set statistics time, io on
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID)    
FROM Sales.Orders AS ord
    JOIN Sales.OrderLines AS det
        ON det.OrderID = ord.OrderID
    JOIN Sales.Invoices AS Inv 
        ON Inv.OrderID = ord.OrderID
    JOIN Sales.CustomerTransactions AS Trans
        ON Trans.InvoiceID = Inv.InvoiceID
    JOIN Warehouse.StockItemTransactions AS ItemTrans
        ON ItemTrans.StockItemID = det.StockItemID
WHERE Inv.BillToCustomerID != ord.CustomerID
    AND (Select SupplierId
         FROM Warehouse.StockItems AS It
         Where It.StockItemID = det.StockItemID) = 12
    AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
        FROM Sales.OrderLines AS Total
            Join Sales.Orders AS ordTotal
                On ordTotal.OrderID = Total.OrderID
        WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000
    AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID



;WITH StockItems AS (
    SELECT StockItemID
    FROM Warehouse.StockItems
    WHERE SupplierId = 12
),
CustomerOrders AS (
    SELECT 
        CustomerID,
        SUM(UnitPrice * Quantity) AS TotalAmount
    FROM Sales.OrderLines
     JOIN Sales.Orders ON OrderLines.OrderID = Orders.OrderID
    GROUP BY CustomerID
    HAVING SUM(UnitPrice * Quantity) > 250000
)
SELECT 
    ord.CustomerID,
    det.StockItemID,
    SUM(det.UnitPrice) AS TotalPrice,
    SUM(det.Quantity) AS TotalQuantity,
    COUNT(ord.OrderID) AS OrderCount
FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID
JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID  
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID
JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID
JOIN StockItems ON StockItems.StockItemID = det.StockItemID
JOIN CustomerOrders ON CustomerOrders.CustomerID = Inv.CustomerID
WHERE 
    Inv.BillToCustomerID != ord.CustomerID
	--AND Inv.InvoiceDate= ord.OrderDate
    AND DATEDIFF(day, Inv.InvoiceDate, ord.OrderDate) = 0
	 
GROUP BY 
    ord.CustomerID, 
    det.StockItemID
