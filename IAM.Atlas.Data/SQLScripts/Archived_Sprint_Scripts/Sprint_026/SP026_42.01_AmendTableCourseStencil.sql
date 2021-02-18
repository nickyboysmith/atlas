/*
	SCRIPT: Alter CourseStencil Table
	Author: John_Cocklin
	Created: 28/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_42.01_AmendTableCourseStencil';
DECLARE @ScriptComments VARCHAR(800) = 'Amend CourseStencil Table Rename Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_RENAME 'CourseStencil.CourseRemoveInitialByUserId', 'CourseRemoveInitiatedByUserId', 'COLUMN';		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;