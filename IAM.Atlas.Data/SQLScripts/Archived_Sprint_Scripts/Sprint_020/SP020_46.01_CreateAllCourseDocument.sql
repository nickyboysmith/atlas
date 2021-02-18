
/*
	SCRIPT: Create AllCourseDocument
	Author: NickSmith
	Created: 24/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_46.01_CreateAllCourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create AllCourseDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'AllCourseDocument'

		/*
			Create Table AllCourseDocument
		*/
		IF OBJECT_ID('dbo.AllCourseDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AllCourseDocument;
		END

		CREATE TABLE AllCourseDocument(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, DocumentId int NOT NULL
			, DateAdded DateTime 
			, AddByUserId int NOT NULL
			, CONSTRAINT FK_AllCourseDocument_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, CONSTRAINT FK_AllCourseDocument_Document FOREIGN KEY (DocumentId) REFERENCES [Document](Id)
			, CONSTRAINT FK_AllCourseDocument_User FOREIGN KEY (AddByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


