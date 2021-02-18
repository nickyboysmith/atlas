/*
	SCRIPT: Drop constraints and table - DocumentTemplateOwner
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_24.01_Drop_DocumentTemplateOwner.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop constraints and table - DocumentTemplateOwner';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplateOwner'
		
		/*
		 *	Drop table
		 */
		IF OBJECT_ID('dbo.DocumentTemplateOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplateOwner;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;