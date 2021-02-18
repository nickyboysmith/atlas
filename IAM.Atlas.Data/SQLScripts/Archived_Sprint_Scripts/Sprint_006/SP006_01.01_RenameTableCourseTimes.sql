

/*
	SCRIPT: Rename Table CourseTimes CourseSchedule
	Author: Robert Newnham
	Created: 24/07/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP006_01.01_RenameTableCourseTimes.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		--At this time the Table is not Used. Therfore a Drop and Recreate is all That is needed
		EXEC dbo.uspDropTableContraints 'CourseTimes'	
		EXEC dbo.uspDropTableContraints 'CourseSchedule'	
		
						
		/*
		 * Course Schedule
		 */
		IF OBJECT_ID('dbo.CourseTimes', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseTimes;
		END 
		IF OBJECT_ID('dbo.CourseSchedule', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseSchedule;
		END 
		
		CREATE TABLE CourseSchedule (
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, [Date] Date
			, StartTime Time
			, EndTime Time
			, CONSTRAINT FK_CourseSchedule_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);	
	
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

