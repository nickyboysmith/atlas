/*
 * SCRIPT: Alter Table CourseTrainer 
 * Author: Robert Newnham
 * Created: 19/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP025_02.01_AmendCourseTrainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseTrainer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseTrainer
			ADD AttendanceCheckRequired bit DEFAULT 'True'
			, AttendanceLastUpdated DateTime

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
