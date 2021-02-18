/*
	SCRIPT: Create CourseDocument Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_13.01_Create_CourseDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDocument Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDocument'
		
		/*
		 *	Create CourseDocument Table
		 */
		IF OBJECT_ID('dbo.CourseDocument', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDocument;
		END

		CREATE TABLE CourseDocument(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int
			, DocumentId int
			, CONSTRAINT FK_CourseDocument_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDocument_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;