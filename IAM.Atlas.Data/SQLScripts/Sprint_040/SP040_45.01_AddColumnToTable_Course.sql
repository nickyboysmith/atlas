/*
 * SCRIPT: Add New Column to Table Course
 * Author: Paul Tuck
 * Created: 19/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_45.01_AddColumnToTable_Course.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table Course';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
		ADD CourseAttendanceSignInDocumentId INT NULL,
		CONSTRAINT FK_Course_Document_AttendanceSignIn FOREIGN KEY (CourseAttendanceSignInDocumentId) REFERENCES Document(Id); 
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;