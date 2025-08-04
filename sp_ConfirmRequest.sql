USE [WideWorldImporters]
GO

/****** Object:  StoredProcedure [Sales].[ConfirmRequest]    Script Date: 04.08.2025 20:29:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--����� �� ������ ����
CREATE PROCEDURE [Sales].[ConfirmRequest]
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER,
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	    --�������� ��������� �� ������� ������� ��������� � ����������
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --��� ������ ����
		

	COMMIT TRAN; 
END



GO


