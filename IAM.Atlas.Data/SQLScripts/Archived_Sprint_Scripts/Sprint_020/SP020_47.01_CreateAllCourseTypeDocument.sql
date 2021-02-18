
/*
	SCRIPT: Create AllCourseTypeDocument
	Author: NickSmith
	Created: 24/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_47.01_CreateAllCourseTypeDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create AllCourseTypeDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'AllCourseTypeDocument'

		/*
			Create Table AllCourseTypeDocument
		*/
		IF OBJECT_ID('dbo.AllCourseTypeDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.AllCourseTypeDocument;
		END

		CREATE TABLE AllCourseTypeDocument(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseTypeId int NOT NULL
			, DocumentId int NOT NULL
			, DateAdded DateTime 
			, AddByUserId int NOT NULL
			, CONSTRAINT FK_AllCourseTypeDocument_CourseType FOREIGN KEY (CourseTypeId) REFERENCES [CourseType](Id)
			, CONSTRAINT FK_AllCourseTypeDocument_Document FOREIGN KEY (DocumentId) REFERENCES [Document](Id)
			, CONSTRAINT FK_AllCourseTypeDocument_User FOREIGN KEY (AddByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


