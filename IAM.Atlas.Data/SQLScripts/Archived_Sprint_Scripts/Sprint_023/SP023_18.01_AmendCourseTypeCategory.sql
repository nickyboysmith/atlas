/*
 * SCRIPT: Alter Table CourseTypeCategory
 * Author: Dan Murray
 * Created: 18/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_18.01_AmendCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column DaysBeforeCourseLastBooking to CourseTypeCategory table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		ALTER TABLE dbo.CourseTypeCategory
			ADD DaysBeforeCourseLastBooking INT DEFAULT 1;
			
			 
		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;