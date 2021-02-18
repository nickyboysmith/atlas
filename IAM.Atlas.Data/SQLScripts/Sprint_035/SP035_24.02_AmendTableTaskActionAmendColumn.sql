/*
 * SCRIPT: Amend Column Size to Table TaskAction
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_24.02_AmendTableTaskActionAmendColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Column Size on Table TaskAction';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_TaskActionName' 
				AND object_id = OBJECT_ID('TaskAction'))
		BEGIN
		   DROP INDEX [UX_TaskActionName] ON [dbo].[TaskAction];
		END
		
		ALTER TABLE [dbo].[TaskAction]
		ALTER COLUMN [Name] VARCHAR(100) NOT NULL;
				
		--Now Create Index
		CREATE UNIQUE NONCLUSTERED INDEX [UX_TaskActionName] ON [dbo].[TaskAction]
		(
			[Name] ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;