USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [Sales].[SendRequest]    Script Date: 04.08.2025 20:28:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [Sales].[SendRequest]
	@StartDate date
	,@EndDate date
	,@CustomerID int
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER;
	DECLARE @RequestMessage NVARCHAR(max);
	
	BEGIN TRAN --�� ������ ������ � ����������, �.�. ��� ��� �� ��������� � ���������� �������� ���������

	--��������� XML � ������ RequestMessage ��� ��������� ����� �������(� �������� ��������� ����� ���� �����)
	SELECT @RequestMessage = (
							  SELECT @StartDate as  [StartDate]
							  ,@EndDate as  [EndDate]
							  ,CustomerID as  [CustomerID]
							  ,COUNT(InvoiceID) as  [InvoicesCNT] 
							FROm [WideWorldImporters].[Sales].[Invoices]
							WHERE InvoiceDate between @StartDate AND @EndDate
							AND CustomerID=@CustomerID
							GROUP BY CustomerID
							  FOR XML PATH('Item'), ROOT('RequestMessage'));  
	
	
	--������� ������
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService] 
	TO SERVICE
	'//WWI/SB/TargetService'   
	ON CONTRACT
	[//WWI/SB/Contract]         
	WITH ENCRYPTION=OFF;       

	--���������� ���� ���� �������������� ���������, �� ����� ��������� � ����� ���������, ������� ����� �������������� ������ ���������������)
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	
	
	COMMIT TRAN 
END

GO


