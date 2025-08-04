USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [Sales].[GetRequest]    Script Date: 04.08.2025 20:28:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sales].[GetRequest] 
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@Startdate date,
			@Enddate date,
			@CustomerID int,
			@InvoicesCNT int,
			@xml XML; 
	
	BEGIN TRAN; 

	RECEIVE TOP(1) 
		@TargetDlgHandle = Conversation_Handle, 
		@Message = Message_Body, 
		@MessageType = Message_Type_Name 
	FROM dbo.TargetQueueWWI; 


	SET @xml = CAST(@Message AS XML);

	SELECT @xml
	SELECT 
    @Startdate=T.c.value('(StartDate)[1]', 'DATE'),
    @EndDate=T.c.value('(EndDate)[1]', 'DATE') ,
    @CustomerID=T.c.value('(CustomerID)[1]', 'INT') ,
    @InvoicesCNT=T.c.value('(InvoicesCNT)[1]', 'INT') 
FROM 
    @xml.nodes('/RequestMessage/Item') AS T(c)

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerID = @CustomerID AND InvoiceDate between @Startdate AND @EndDate)
	BEGIN
		INSERT INTO [WideWorldImporters].[Sales].[CustomersInvoicesForPeriod]
           ([CustomerID]
           ,[InvoicesCNT]
           ,[Startdate]
           ,[EndDate])
	SELECT @CustomerID,@InvoicesCNT,@Startdate,@EndDate
	END;
	
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' 
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>';
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; 
		                                  
	END 
	

	COMMIT TRAN;
END
GO


