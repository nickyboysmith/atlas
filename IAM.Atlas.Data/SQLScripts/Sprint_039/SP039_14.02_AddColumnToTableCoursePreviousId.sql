/*
	SCRIPT: Add Columns To Table CoursePreviousId
	Author: Robert Newnham
	Created: 20/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_14.02_AddColumnToTableCoursePreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table CoursePreviousId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CoursePreviousId 
		ADD DateAdded DateTime NOT NULL DEFAULT GETDATE()
		, PreviousOrgId INT NULL
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END