USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [Sales].[ConfirmRequest]    Script Date: 04.08.2025 20:29:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--ответ на первое ПОКА
CREATE PROCEDURE [Sales].[ConfirmRequest]
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	    --Получаем сообщение от таргета которое находится у инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --ЭТО второй ПОКА
		

	COMMIT TRAN; 
END



GO


