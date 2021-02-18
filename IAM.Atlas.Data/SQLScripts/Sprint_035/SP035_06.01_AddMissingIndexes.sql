
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 17/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_06.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UIX_InterpreterAvailabilityDateInterpreterIdDateSessionNumber' 
				AND object_id = OBJECT_ID('InterpreterAvailabilityDate'))
		BEGIN
		   DROP INDEX [UIX_InterpreterAvailabilityDateInterpreterIdDateSessionNumber] ON [dbo].[InterpreterAvailabilityDate];
		END
		
		--Now Create Index
		CREATE UNIQUE INDEX [UIX_InterpreterAvailabilityDateInterpreterIdDateSessionNumber] ON [dbo].[InterpreterAvailabilityDate]
		(
			[InterpreterId], [Date], [SessionNumber]
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_InterpreterAvailabilityDateInterpreterId' 
				AND object_id = OBJECT_ID('InterpreterAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_InterpreterAvailabilityDateInterpreterId] ON [dbo].[InterpreterAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_InterpreterAvailabilityDateInterpreterId] ON [dbo].[InterpreterAvailabilityDate]
		(
			[InterpreterId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_InterpreterAvailabilityDateDate' 
				AND object_id = OBJECT_ID('InterpreterAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_InterpreterAvailabilityDateDate] ON [dbo].[InterpreterAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_InterpreterAvailabilityDateDate] ON [dbo].[InterpreterAvailabilityDate]
		(
			[Date] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_InterpreterAvailabilityDateInterpreterIdDate' 
				AND object_id = OBJECT_ID('InterpreterAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_InterpreterAvailabilityDateInterpreterIdDate] ON [dbo].[InterpreterAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_InterpreterAvailabilityDateInterpreterIdDate] ON [dbo].[InterpreterAvailabilityDate]
		(
			[InterpreterId], [Date] ASC
		) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

