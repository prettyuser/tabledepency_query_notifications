USE [TestDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver') DROP SERVICE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender') DROP SERVICE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver') DROP QUEUE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender') DROP QUEUE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771') DROP CONTRACT [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Update') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/EndMessage') DROP MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_QueueActivationSender];

        
    END
END