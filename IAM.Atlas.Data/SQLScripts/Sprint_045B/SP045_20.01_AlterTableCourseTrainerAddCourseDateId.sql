/*
 * SCRIPT: Alter CourseTrainer Add field CourseDateId
 * Author: Nick Smith
 * Created: 29/11/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP045_20.01_AlterTableCourseTrainerAddCourseDateId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter CourseTrainer Add field CourseDateId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseTrainer
		ADD [CourseDateId] INT 
		, CONSTRAINT FK_CourseTrainer_CourseDate FOREIGN KEY (CourseDateId) REFERENCES CourseDate(Id);;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
