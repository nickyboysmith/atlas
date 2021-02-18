/*
 * SCRIPT: Alter Table Course
 * Author: Robert Newnham
 * Created: 13/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP033_18.01_AmendTableCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course 
		ADD
			DateCreated DATETIME NULL

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
