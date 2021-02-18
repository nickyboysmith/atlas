/*
	SCRIPT: Create SystemTask Table
	Author: Dan Murray	
	Created: 22/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_30.01_Create_SystemTask.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemTask Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemTask'
		
		/*
		 *	Create SystemTask Table
		 */
		IF OBJECT_ID('dbo.SystemTask', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemTask;
		END

		CREATE TABLE SystemTask(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , Name VARCHAR(100) UNIQUE
		  , Title VARCHAR(100)
		  , [Description] VARCHAR(400)
		  , DevelopersNotes VARCHAR(1000)
		  , EmailOptionCaption VARCHAR(100)
		  , InternalMessageOptionCaption VARCHAR(100)
		  , [Disabled] BIT DEFAULT (0) 
		  , DateCreated DATETIME DEFAULT GETDATE()
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;