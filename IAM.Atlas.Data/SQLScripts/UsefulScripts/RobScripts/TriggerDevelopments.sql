


/*
--Create TestTable
SELECT * 
INTO TestTable
FROM (
	SELECT 1 AS Id, 'Test Data 1' AS TestColumn
	UNION SELECT 2 AS Id, 'Test Data 2' AS TestColumn
	UNION SELECT 3 AS Id, 'Test Data 3' AS TestColumn
	) T

--*/
/*
CREATE TABLE [dbo].[TriggerLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DateTimeRun] [datetime] NOT NULL,
	[TableName] [varchar](1000) NOT NULL,
	[TriggerName] [varchar](1000) NOT NULL,
	[InsertedTableRows] [int] NULL,
	[DeletedTableRows] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [dbo].[TriggerLog] ADD  DEFAULT (getdate()) FOR [DateTimeRun]
GO

--*/
/*
CREATE TABLE [dbo].[TriggerError](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DateTimeRun] [datetime] NOT NULL,
	[TableName] [varchar](1000) NOT NULL,
	[TriggerName] [varchar](1000) NOT NULL,
	[ErrorNumber] [varchar](10) NOT NULL,
	[ErrorLine] [varchar](10) NOT NULL,
	[ErrorMessage] [varchar](MAX) NOT NULL,
	[InsertedTableRows] [int] NULL,
	[DeletedTableRows] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)

GO

ALTER TABLE [dbo].[TriggerError] ADD  DEFAULT (getdate()) FOR [DateTimeRun]
GO

--*/
/*

	CREATE PROCEDURE [dbo].[uspLogTriggerRunning] (
		@TableName VARCHAR(1000)
		, @TriggerName VARCHAR(1000)
		, @InsertedTableRows INT = NULL
		, @DeletedTableRows INT = NULL
		)
	AS
	BEGIN
		BEGIN
			INSERT INTO [dbo].[TriggerLog] (DateTimeRun, TableName, TriggerName, InsertedTableRows, DeletedTableRows)
			VALUES (
				GETDATE()
				, @TableName
				, @TriggerName
				, @InsertedTableRows
				, @DeletedTableRows
			);
		END
	END
--*/
/*

	CREATE PROCEDURE [dbo].[uspLogTriggerError] (
		@TableName VARCHAR(1000)
		, @TriggerName VARCHAR(1000)
		, @InsertedTableRows INT = NULL
		, @DeletedTableRows INT = NULL
		, @ErrorNumber VARCHAR(10)
		, @ErrorLine VARCHAR(10)
		, @ErrorMessage VARCHAR(MAX)
		)
	AS
	BEGIN
		INSERT INTO [dbo].TriggerError (DateTimeRun, TableName, TriggerName, ErrorNumber, ErrorLine, ErrorMessage, InsertedTableRows, DeletedTableRows)
		VALUES (
			GETDATE()
			, @TableName
			, @TriggerName
			, @ErrorNumber
			, @ErrorLine
			, @ErrorMessage
			, @InsertedTableRows
			, @DeletedTableRows
		);
	END
--*/
/*

DELETE  [dbo].[TriggerLog]
DELETE  [dbo].[TriggerError]
DELETE TestTable;

INSERT INTO TestTable (Id, TestColumn)
SELECT Id, TestColumn
FROM (
	SELECT 7 AS Id, 'Test Data 7' AS TestColumn
	) T

SELECT * FROM [dbo].[TriggerLog]
SELECT * FROM [dbo].[TriggerError]
SELECT * FROM [dbo].[TestTable]

--*/
IF OBJECT_ID('dbo.TRG_TestTable_Insert1', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_TestTable_Insert1;
END
IF OBJECT_ID('dbo.TRG_TestTable_Insert2', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_TestTable_Insert2;
END
GO
	CREATE TRIGGER TRG_TestTable_Insert1 ON dbo.TestTable AFTER INSERT
	AS
	BEGIN 
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			EXEC uspLogTriggerRunning 'TestTable', 'TRG_TestTable_Insert1', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			BEGIN TRY
				/***************************************************************************************************************/
				PRINT 'B'
				UPDATE TT
				SET TT.[TestColumn] = REPLACE(TT.[TestColumn], 'Test', '**')
				FROM INSERTED I
				INNER JOIN TestTable TT ON TT.Id = I.Id;
				PRINT 'B2'
				/***************************************************************************************************************/
			END TRY
			BEGIN CATCH		
				ROLLBACK TRAN	
				PRINT 'B3'		
				DECLARE @ErrorNumber VARCHAR(10), @ErrorLine VARCHAR(10), @ErrorMessage VARCHAR(MAX);
				SELECT @ErrorNumber = CAST(ERROR_NUMBER() AS VARCHAR), @ErrorLine = CAST(ERROR_LINE() AS VARCHAR), @ErrorMessage = ERROR_MESSAGE();
				PRINT 'B4'
				BEGIN TRAN
				PRINT 'B5'
				EXEC uspLogTriggerRunning 'TestTable', 'TRG_TestTable_Insert1', @insertedRows, @deletedRows;
				EXEC uspLogTriggerError 'TestTable', 'TRG_TestTable_Insert2', @insertedRows, @deletedRows, @ErrorNumber, @ErrorLine, @ErrorMessage;
				COMMIT TRAN
				PRINT 'B6'
				RETURN;
			END CATCH
		END --END PROCESS
	END

	GO
	
IF OBJECT_ID('dbo.TRG_TestTable_Insert1', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_TestTable_Insert1;
END
IF OBJECT_ID('dbo.TRG_TestTable_Insert2', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_TestTable_Insert2;
END
GO
	CREATE TRIGGER TRG_TestTable_Insert2 ON dbo.TestTable AFTER INSERT
	AS
	BEGIN 
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			EXEC uspLogTriggerRunning 'TestTable', 'TRG_TestTable_Insert2', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			BEGIN TRY 
				/***************************************************************************************************************/
				PRINT 'A'
				DECLARE @Zero INT = 0;
				UPDATE TT
				SET TT.Id = TT.Id / @Zero
				FROM INSERTED I
				INNER JOIN TestTable TT ON TT.Id = I.Id;
				PRINT 'A2'
				/***************************************************************************************************************/
			END TRY
			BEGIN CATCH		
				ROLLBACK TRAN
				DECLARE @ErrorNumber VARCHAR(10), @ErrorLine VARCHAR(10), @ErrorMessage VARCHAR(MAX);
				SELECT @ErrorNumber = CAST(ERROR_NUMBER() AS VARCHAR), @ErrorLine = CAST(ERROR_LINE() AS VARCHAR), @ErrorMessage = ERROR_MESSAGE();
				BEGIN TRAN
					EXEC uspLogTriggerRunning 'TestTable', 'TRG_TestTable_Insert2', @insertedRows, @deletedRows;
					EXEC uspLogTriggerError 'TestTable', 'TRG_TestTable_Insert2', @insertedRows, @deletedRows, @ErrorNumber, @ErrorLine, @ErrorMessage;
				COMMIT TRAN;
				RETURN;
			END CATCH
		END --END PROCESS
	END

	GO
