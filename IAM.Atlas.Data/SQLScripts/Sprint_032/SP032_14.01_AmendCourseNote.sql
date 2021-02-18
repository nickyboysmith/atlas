/*
 * SCRIPT: Alter Table CourseNote
 * Author: Robert Newnham
 * Created: 18/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_14.01_AmendCourseNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseNote Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseNote 
		ADD
			OrganisationOnly BIT NOT NULL DEFAULT 'False'

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
