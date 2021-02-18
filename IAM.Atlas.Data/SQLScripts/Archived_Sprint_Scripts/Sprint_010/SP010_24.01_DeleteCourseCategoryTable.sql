/*
 * SCRIPT: Remove CourseCategory column from Course Table
 * Author: Miles Stewart
 * Created: 28/10/2015
 */

DECLARE @ScriptName VARCHAR(100) = 'SP010_24.01_DeleteCourseCategoryTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Delete CourseCategory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.CourseCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseCategory;
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


