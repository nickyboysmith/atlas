/*
	SCRIPT: Create DocumentTemplate Table
	Author: Dan Hough
	Created: 01/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_27.01_Create_DocumentTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentTemplate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentTemplate'
		
		/*
		 *	Create DocumentTemplate Table
		 */
		IF OBJECT_ID('dbo.DocumentTemplate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentTemplate;
		END

		CREATE TABLE DocumentTemplate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DocumentId INT 
			, Title VARCHAR(100)
			, DateCreated DATETIME
			, CreatedByUserId INT NULL
			, Replaced BIT DEFAULT 0
			, DateReplaced DATETIME NULL
			, ReplacedByUserId INT NULL
			, CONSTRAINT FK_DocumentTemplate_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_DocumentTemplate_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_DocumentTemplate_User2 FOREIGN KEY (ReplacedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;