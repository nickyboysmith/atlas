 /*
 * SCRIPT: Alter Table CourseType, Add new column DaysBeforeCourseLastBooking
 * Author: Nick Smith
 * Created: 28/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_47.01_AmendTableCourseTypeAddColumnDaysBeforeCourseLastBooking.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table CourseType, Add new column DaysBeforeCourseLastBooking';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseType
			ADD DaysBeforeCourseLastBooking  INT NOT NULL DEFAULT 2
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
