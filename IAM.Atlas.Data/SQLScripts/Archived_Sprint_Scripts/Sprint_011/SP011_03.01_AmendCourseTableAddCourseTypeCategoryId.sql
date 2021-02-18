/*
 * SCRIPT: Alter Table Trainer Add New Column UserId
 * Author: Miles Stewart
 * Created: 28/10/2015
 */

DECLARE @ScriptName VARCHAR(100) = 'SP011_03.01_AmendCourseTableAddCourseTypeCategoryId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a new column course Category Type Id to the Course Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
		ADD CourseTypeCategoryId int
		, CONSTRAINT FK_Course_CourseTypeCategory FOREIGN KEY (CourseTypeCategoryId) REFERENCES [CourseTypeCategory](Id);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

