/*
 * SCRIPT: Remove CourseCategory column from Course Table
 * Author: Miles Stewart
 * Created: 28/10/2015
 */
DECLARE @ScriptName VARCHAR(100) = 'SP010_25.01_AmendCourseTypeCategoryTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		ALTER TABLE dbo.CourseTypeCategory DROP COLUMN CourseCategoryId;
		ALTER TABLE dbo.CourseTypeCategory ADD Name varchar(10); 					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
