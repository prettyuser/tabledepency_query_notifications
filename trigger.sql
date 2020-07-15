USE [TestDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[tr_dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771_Sender] ON [dbo].[Stocks] 
WITH EXECUTE AS SELF
AFTER insert, update, delete AS 
BEGIN
    SET NOCOUNT ON;

    DECLARE @rowsToProcess INT
    DECLARE @currentRow INT
    DECLARE @records XML
    DECLARE @theMessageContainer NVARCHAR(MAX)
    DECLARE @dmlType NVARCHAR(10)
    DECLARE @modifiedRecordsTable TABLE ([RowNumber] INT IDENTITY(1, 1), [Price] decimal(18,0), [Code] nvarchar(50), [Name] nvarchar(50))
    DECLARE @exceptTable TABLE ([RowNumber] INT, [Price] decimal(18,0), [Code] nvarchar(50), [Name] nvarchar(50))
	DECLARE @deletedTable TABLE ([RowNumber] INT IDENTITY(1, 1), [Price] decimal(18,0), [Code] nvarchar(50), [Name] nvarchar(50))
    DECLARE @insertedTable TABLE ([RowNumber] INT IDENTITY(1, 1), [Price] decimal(18,0), [Code] nvarchar(50), [Name] nvarchar(50))
    DECLARE @var1 decimal(18,0)
    DECLARE @var2 nvarchar(50)
    DECLARE @var3 nvarchar(50)

    DECLARE @conversationHandlerExists INT
    SELECT @conversationHandlerExists = COUNT(*) FROM sys.conversation_endpoints WHERE conversation_handle = '7876b908-6fc6-ea11-8444-50465da1a754';
    IF @conversationHandlerExists = 0
    BEGIN
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
        RETURN
    END
    
    IF NOT EXISTS(SELECT 1 FROM INSERTED)
    BEGIN
        SET @dmlType = 'Delete'
        INSERT INTO @modifiedRecordsTable SELECT [Price], [Code], [Name] FROM DELETED 
    END
    ELSE
    BEGIN
        IF NOT EXISTS(SELECT * FROM DELETED)
        BEGIN
            SET @dmlType = 'Insert'
            INSERT INTO @modifiedRecordsTable SELECT [Price], [Code], [Name] FROM INSERTED 
        END
        ELSE
        BEGIN
            SET @dmlType = 'Update';
            INSERT INTO @deletedTable SELECT [Price],[Code],[Name] FROM DELETED
            INSERT INTO @insertedTable SELECT [Price],[Code],[Name] FROM INSERTED
            INSERT INTO @exceptTable SELECT [RowNumber],[Price],[Code],[Name] FROM @insertedTable EXCEPT SELECT [RowNumber],[Price],[Code],[Name] FROM @deletedTable

            INSERT INTO @modifiedRecordsTable SELECT [Price],[Code],[Name] FROM @exceptTable e 
        END
    END

    SELECT @rowsToProcess = COUNT(1) FROM @modifiedRecordsTable    

    BEGIN TRY
        WHILE @rowsToProcess > 0
        BEGIN
            SELECT	@var1 = [Price], @var2 = [Code], @var3 = [Name]
            FROM	@modifiedRecordsTable
            WHERE	[RowNumber] = @rowsToProcess
                
            IF @dmlType = 'Insert' 
            BEGIN
                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Insert] (CONVERT(NVARCHAR, @dmlType))

                IF @var1 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (CONVERT(NVARCHAR(MAX), @var1))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (0x)
                END
                IF @var2 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (CONVERT(NVARCHAR(MAX), @var2))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (0x)
                END
                IF @var3 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (CONVERT(NVARCHAR(MAX), @var3))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (0x)
                END

                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/EndMessage] (0x)
            END
        
            IF @dmlType = 'Update'
            BEGIN
                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Update] (CONVERT(NVARCHAR, @dmlType))

                IF @var1 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (CONVERT(NVARCHAR(MAX), @var1))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (0x)
                END
                IF @var2 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (CONVERT(NVARCHAR(MAX), @var2))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (0x)
                END
                IF @var3 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (CONVERT(NVARCHAR(MAX), @var3))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (0x)
                END

                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/EndMessage] (0x)
            END

            IF @dmlType = 'Delete'
            BEGIN
                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/StartMessage/Delete] (CONVERT(NVARCHAR, @dmlType))

                IF @var1 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (CONVERT(NVARCHAR(MAX), @var1))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Price] (0x)
                END
                IF @var2 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (CONVERT(NVARCHAR(MAX), @var2))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Code] (0x)
                END
                IF @var3 IS NOT NULL BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (CONVERT(NVARCHAR(MAX), @var3))
                END
                ELSE BEGIN
                    ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/Name] (0x)
                END

                ;SEND ON CONVERSATION '7876b908-6fc6-ea11-8444-50465da1a754' MESSAGE TYPE [dbo_Stocks_b02e6e35-d636-4b70-919a-787e187aa771/EndMessage] (0x)
            END

            SET @rowsToProcess = @rowsToProcess - 1
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT

        SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState) 
    END CATCH
END