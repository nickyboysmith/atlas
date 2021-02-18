/*
	SCRIPT: Create Course Type Category Table
	Author: Miles Stewart
	Created: 28/10/2015
*/


DECLARE @ScriptName VARCHAR(100) = 'SP010_21.01_CreateTableCourseTypeCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Creates table to store the course type category';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'CourseTypeCategory'

		/*
		 *	Drop tables in this order to avoid errors due to foreign key constraints
		 */
		IF OBJECT_ID('dbo.CourseTypeCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTypeCategory;
		END
		
		/*
		 *	Create Table CourseTypeCategory
		 */
		CREATE TABLE CourseTypeCategory (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseTypeId INT NOT NULL
			, CourseCategoryId INT NOT NULL
			, Disabled bit
			, CONSTRAINT FK_CourseTypeCategory_CourseType FOREIGN KEY (CourseTypeId) REFERENCES [CourseType](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


