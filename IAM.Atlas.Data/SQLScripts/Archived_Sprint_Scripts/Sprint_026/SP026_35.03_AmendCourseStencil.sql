/*
 * SCRIPT: Alter Table Rename Column in table CourseStencil
 * Author: John Cocklin
 * Created: 27/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_35.02_AmendTableCourseStencil';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Column in table CourseStencil';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_RENAME 'CourseStencil.LastetStartDate', 'LatestStartDate', 'COLUMN';

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
