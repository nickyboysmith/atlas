/*
	SCRIPT: Create TaskRelatedToCourse Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.12_Create_TaskRelatedToCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskRelatedToCourse Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskRelatedToCourse'
		
		/*
		 *	Create TaskRelatedToCourse Table
		 */
		IF OBJECT_ID('dbo.TaskRelatedToCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskRelatedToCourse;
		END

		CREATE TABLE TaskRelatedToCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TaskId INT NOT NULL
			, CourseId INT NOT NULL
			, CONSTRAINT FK_TaskRelatedToCourse_Task FOREIGN KEY (TaskId) REFERENCES Task(Id)
			, CONSTRAINT FK_TaskRelatedToCourse_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, INDEX IX_TaskRelatedToCourseTaskId NONCLUSTERED (TaskId)
			, INDEX IX_TaskRelatedToCourseCourseId NONCLUSTERED (CourseId)
			, INDEX UX_TaskCompletedForUserTaskIdCourseId UNIQUE NONCLUSTERED (TaskId, CourseId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;