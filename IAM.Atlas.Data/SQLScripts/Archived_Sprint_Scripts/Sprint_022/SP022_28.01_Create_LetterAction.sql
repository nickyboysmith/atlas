/*
	SCRIPT: Create LetterAction Table
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_28.01_Create_LetterAction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create LetterAction Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LetterAction'
		
		/*
		 *	Create LetterAction Table
		 */
		IF OBJECT_ID('dbo.LetterAction', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LetterAction;
		END

		CREATE TABLE LetterAction(
			Id INT IDENTITY PRIMARY KEY NOT NULL
			, Name VARCHAR(40) 
			, Title VARCHAR(100)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;