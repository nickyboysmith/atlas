/*
	SCRIPT: Create DocumentType Table
	Author: Nick Smith
	Created: 07/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_34.01_CreateDocumentTypeTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentType'
		
		/*
		 *	Create DocumentType Table
		 */
		IF OBJECT_ID('dbo.DocumentType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentType;
		END

		CREATE TABLE DocumentType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			,[Type] Varchar(10) NOT NULL
			,[Description] Varchar(100)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;