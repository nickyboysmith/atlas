/*
	SCRIPT: Create DocumentOwner Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_12.01_Create_DocumentOwner.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentOwner Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentOwner'
		
		/*
		 *	Create DocumentOwner Table
		 */
		IF OBJECT_ID('dbo.DocumentOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentOwner;
		END

		CREATE TABLE DocumentOwner(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId int
			, OrganisationId int
			, CONSTRAINT FK_DocumentOwner_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentOwner_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;