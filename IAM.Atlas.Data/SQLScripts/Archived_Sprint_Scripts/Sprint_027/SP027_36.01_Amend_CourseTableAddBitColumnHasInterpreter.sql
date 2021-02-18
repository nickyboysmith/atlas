/*
 * SCRIPT: Alter Table Course, Add HasInterpreter column.
 * Author: Nick Smith
 * Created: 17/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_36.01_Alter_CourseTableAddBitColumnHasInterpreter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Course Table Add Bit Column HasInterpreter';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Course
		ADD
			HasInterpreter BIT DEFAULT 'False';
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

