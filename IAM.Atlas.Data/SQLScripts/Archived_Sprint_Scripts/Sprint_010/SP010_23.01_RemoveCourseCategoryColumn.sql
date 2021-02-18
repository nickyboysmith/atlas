/*
 * SCRIPT: Remove CourseCategory column from Course Table
 * Author: Miles Stewart
 * Created: 28/10/2015
 */

DECLARE @ScriptName VARCHAR(100) = 'SP010_23.01_RemoveCourseCategoryColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Remove CourseCategory column from Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.Course', 'U') IS NOT NULL
		BEGIN
			ALTER TABLE Course DROP CONSTRAINT FK_Course_CourseCategory;
			ALTER TABLE Course DROP COLUMN CourseCategoryId;
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


