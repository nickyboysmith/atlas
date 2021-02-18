/*
 * SCRIPT: Alter Table DORSCourse - add in DORSCourseId
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_22.01_AmendDORSCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to DORSCourse table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.DORSCourse
		  ADD DORSCourseId int 

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;