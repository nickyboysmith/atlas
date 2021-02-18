/*
 * SCRIPT: Add columns to CourseClientRemoved
 * Author: Dan Hough
 * Created: 19/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_01.01_Alter_CourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to CourseDORSClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientRemoved
		ADD DateAddedToCourse DATETIME NULL
			, CourseClientId INT NULL
			, CONSTRAINT FK_CourseClientRemoved_CourseClient FOREIGN KEY (CourseClientId) REFERENCES CourseClient(Id) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
