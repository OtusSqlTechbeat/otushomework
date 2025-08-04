USE [WideWorldImporters];

--�������� �������������� ������� ��� ����������� ���������� ������ �������
ALTER TABLE Sales.Invoices
ADD InvoiceConfirmedForProcessing DATETIME;

--Service Broker ������� ��?
select name, is_broker_enabled
from sys.databases;

--�������� ������
USE master
ALTER DATABASE WideWorldImporters
SET ENABLE_BROKER  WITH ROLLBACK IMMEDIATE; --NO WAIT --prod (� �������������������� ������!!! �� ����� ��� �� �����)

--�� ������ ��������������� �� ����� ����������� ������!!!
ALTER AUTHORIZATION    
   ON DATABASE::WideWorldImporters TO [sa];

--�������� ��� ����� �������� �������� ��� ������������� ������������ ����� �������� ����� ���������� 
--�� � ����������(���������� ������� �������, ��� ���� �� ����� ��������)
--���� �� �������� �� � ����� �� ���������, �� ��� �������� ��������� � OFF
ALTER DATABASE WideWorldImporters SET TRUSTWORTHY ON;

--������� ���� ���������
USE WideWorldImporters
-- For Request
CREATE MESSAGE TYPE
[//WWI/SB/RequestMessage]
VALIDATION=WELL_FORMED_XML; --������ ������������� ��� ��������, ��� ������ ������������� ���� XML(�� ����� ����� ���)
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReplyMessage]
VALIDATION=WELL_FORMED_XML; --������ ������������� ��� ��������, ��� ������ ������������� ���� XML(�� ����� ����� ���) 

--������� ��������(���������� ����� ��������� � ������ ����� ��������� ���������)
CREATE CONTRACT [//WWI/SB/Contract]
      ([//WWI/SB/RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReplyMessage]
         SENT BY TARGET
      );

--������� ������� �������(������� ����� �.�. ����� ALTER ����� �� ������ ���
CREATE QUEUE TargetQueueWWI;
--� ������ �������
CREATE SERVICE [//WWI/SB/TargetService]
       ON QUEUE TargetQueueWWI
       ([//WWI/SB/Contract]);

--�� �� ��� ����������
CREATE QUEUE InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/InitiatorService]
       ON QUEUE InitiatorQueueWWI
       ([//WWI/SB/Contract]);



--����� �������� ������� ��� ��� ����� ������ ���������� ���������� � ���������
USE [WideWorldImporters]
GO
--���� � MAX_QUEUE_READERS = 0 ����� ������� ������� ��������� � ������� ��� ������ ������� 
ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ��(� PROCEDURE_NAME)(������ �� ����� ����������� ��, �� � ������� ���������)  
										              ,PROCEDURE_NAME = Sales.ConfirmRequest
													  ,MAX_QUEUE_READERS = 0 --���������� �������(�� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��, ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��
													  ) 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = Sales.GetRequest
												   ,MAX_QUEUE_READERS = 0
												   ,EXECUTE AS OWNER 
												   ) 

GO

truncate table [WideWorldImporters].[Sales].[CustomersInvoicesForPeriod]

EXEC Sales.SendRequest
	@CustomerID = 570
	,@StartDate ='2013-02-01'
	,@EndDate ='2015-03-01'



SELECT CAST(message_body AS XML),*
FROM dbo.TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.InitiatorQueueWWI;

EXEC Sales.GetRequest;

EXEC Sales.ConfirmRequest;

SELECT  *
  FROM [WideWorldImporters].[Sales].[CustomersInvoicesForPeriod]


SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --������������� ��������(���������� ���������) ����� �� �� ����������� - --������ ��������� ������ �� �������� ������� ���������
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;