/*
	SCRIPT: Create DocumentTemplateOwner Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_11.01_Create_DocumentTemplateOwner.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplateOwner Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplateOwner'
		
		/*
		 *	Create DocumentTemplateOwner Table
		 */
		IF OBJECT_ID('dbo.DocumentTemplateOwner', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplateOwner;
		END

		CREATE TABLE DocumentTemplateOwner(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentTemplateId int
			, OrganisationId int
			, CONSTRAINT FK_DocumentTemplateOwner_DocumentTemplate FOREIGN KEY (DocumentTemplateId) REFERENCES DocumentTemplate(Id)
			, CONSTRAINT FK_DocumentTemplateOwner_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;