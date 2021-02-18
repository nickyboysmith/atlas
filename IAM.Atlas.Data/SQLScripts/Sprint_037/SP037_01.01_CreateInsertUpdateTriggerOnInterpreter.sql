/*
	SCRIPT: Create Insert Update trigger on Interpreter.
	Author: Dan Hough
	Created: 27/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_01.01_CreateInsertUpdateTriggerOnInterpreter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Update trigger on Interpreter';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Interpreter_InsertUpdateForInterpreterAvailabilityDate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Interpreter_InsertUpdateForInterpreterAvailabilityDate;
	END

	GO

	CREATE TRIGGER dbo.TRG_Interpreter_InsertUpdateForInterpreterAvailabilityDate ON dbo.Interpreter AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Interpreter', 'TRG_Interpreter_InsertUpdateForInterpreterAvailabilityDate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			DECLARE @interpreterId INT;

			SELECT @interpreterId = i.Id
			FROM Inserted i;

			INSERT INTO dbo.InterpreterAvailabilityDate (InterpreterId, [Date], SessionNumber)
			SELECT DT2.InterpreterId
					, DT2.[Date]
					, DT2.SessionNumber
			FROM
				(
				SELECT	@interpreterId AS InterpreterId
						, CAST(DT.Dates AS DATE) AS [Date]
						, 1 AS SessionNumber
				FROM
					(
						SELECT TOP (DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, 1, GETDATE())) + 1) Dates = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, GETDATE())
						FROM sys.all_objects a 
						CROSS JOIN sys.all_objects b
					) DT
				UNION
				SELECT	@interpreterId AS InterpreterId
						, CAST(DT.Dates AS DATE) AS [Date]
						, 2 AS SessionNumber
				FROM
					(
						SELECT TOP (DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, 1, GETDATE())) + 1) Dates = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, GETDATE())
						FROM sys.all_objects a 
						CROSS JOIN sys.all_objects b
					) DT
				UNION
				SELECT	@interpreterId AS InterpreterId
						, CAST(DT.Dates AS DATE) AS [Date]
						, 3 AS SessionNumber
				FROM
					(
						SELECT TOP (DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, 1, GETDATE())) + 1) Dates = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, GETDATE())
						FROM sys.all_objects a 
						CROSS JOIN sys.all_objects b
					) DT
				) DT2
				LEFT JOIN InterpreterAvailabilityDate IAD2 ON DT2.InterpreterId = IAD2.InterpreterId
															AND DT2.[Date] = IAD2.[Date]
															AND DT2.SessionNumber = IAD2.SessionNumber
				WHERE IAD2.Id IS NULL
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_01.01_CreateInsertUpdateTriggerOnInterpreter.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO