/*
 * SCRIPT: Add CourseRegisterDocumentId to Course Table
 * Author: Nick Smith
 * Created: 28/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_12.01_Alter_Course_AddCourseRegisterDocumentId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add CourseRegisterDocumentId to Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
		ADD CourseRegisterDocumentId INT NULL
			, CONSTRAINT FK_Course_Document FOREIGN KEY (CourseRegisterDocumentId) REFERENCES Document(Id) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
