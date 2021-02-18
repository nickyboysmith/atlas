/*
	SCRIPT: Create ClientEmailTemplate Table
	Author: Dan Hough
	Created: 14/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_32.01_CreateTable_ClientEmailTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientEmailTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientEmailTemplate'
		
		/*
		 *	Create ClientEmailTemplate Table
		 */
		IF OBJECT_ID('dbo.ClientEmailTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientEmailTemplate;
		END

		CREATE TABLE ClientEmailTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, Code VARCHAR(20) NULL INDEX IX_ClientEmailTemplateCode NONCLUSTERED
			, Title VARCHAR(320) NULL
			, Content VARCHAR(8000) NULL
			, CONSTRAINT FK_ClientEmailTemplate_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END