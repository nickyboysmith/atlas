/*
	SCRIPT: Add Columns To Table CourseClientRemoved
	Author: Robert Newnham
	Created: 27/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_22.01_AddColumnToTableCourseClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table CourseClientRemoved';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientRemoved 
		ADD PartOfDorsCourseTransfer BIT NOT NULL DEFAULT 'False'
		;

		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END