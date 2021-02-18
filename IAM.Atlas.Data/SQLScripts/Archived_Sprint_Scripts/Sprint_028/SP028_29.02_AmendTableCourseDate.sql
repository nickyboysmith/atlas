/*
 * SCRIPT: Alter Table CourseDate, Add new column AssociatedSessionNumber 
 * Author: Robert Newnham
 * Created: 02/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_29.02_AmendTableCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table CourseDate, Add new column AssociatedSessionNumber ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDate
			ADD AssociatedSessionNumber INT
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
