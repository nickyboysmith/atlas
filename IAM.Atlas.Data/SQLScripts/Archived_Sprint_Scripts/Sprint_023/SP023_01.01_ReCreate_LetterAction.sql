/*
	SCRIPT: Re-Create LetterAction Table
	Author: Robert Newnham
	Created: 07/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_01.01_ReCreate_LetterAction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create LetterAction Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		
		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_LetterAction')
		   AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE dbo.LetterTemplate
			DROP CONSTRAINT FK_LetterTemplate_LetterAction;
		END
		
		EXEC dbo.uspDropTableContraints 'LetterAction'

		/*
		 *	Create LetterAction Table
		 */
		IF OBJECT_ID('dbo.LetterAction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterAction;
		END

		CREATE TABLE LetterAction(
			Id INT PRIMARY KEY NOT NULL
			, Name VARCHAR(40) 
			, Title VARCHAR(100)
		);
				
		IF NOT EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_LetterTemplate_LetterAction')
		   AND parent_object_id = OBJECT_ID(N'dbo.LetterTemplate')
		)
		BEGIN
			ALTER TABLE dbo.LetterTemplate
			ADD CONSTRAINT FK_LetterTemplate_LetterAction FOREIGN KEY (LetterActionId) REFERENCES LetterAction(Id);
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;