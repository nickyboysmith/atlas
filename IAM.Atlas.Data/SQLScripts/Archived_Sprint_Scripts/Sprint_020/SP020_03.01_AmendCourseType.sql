/*
 * SCRIPT: Alter Table CourseType
 * Author: Dan Hough
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_03.01_AmendCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to CourseType table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		ALTER TABLE dbo.CourseType
			ADD DORSOnly bit DEFAULT 0
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;