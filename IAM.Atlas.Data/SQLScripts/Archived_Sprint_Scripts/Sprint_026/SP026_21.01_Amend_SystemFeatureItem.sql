/*
 * SCRIPT: Alter Table Rename Column in table CourseStencil
 * Author: Robert Newnham
 * Created: 14/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_21.01_Amend_SystemFeatureItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Column in table CourseStencil';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_RENAME 'CourseStencil.DailCoursesSkipDays', 'DailyCoursesSkipDays', 'COLUMN';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
