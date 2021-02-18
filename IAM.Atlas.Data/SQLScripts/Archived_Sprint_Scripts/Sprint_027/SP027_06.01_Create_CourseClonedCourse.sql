/*
	SCRIPT: Create CourseClonedCourse Table
	Author: Dan Hough
	Created: 03/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_06.01_Create_CourseClonedCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseClonedCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseClonedCourse'
		
		/*
		 *	Create CourseClonedCourse Table
		 */
		IF OBJECT_ID('dbo.CourseClonedCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClonedCourse;
		END

		CREATE TABLE CourseClonedCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseCloneRequestId INT
			, NewCourseId INT 
			, DateCreated DATETIME
			, CONSTRAINT FK_CourseClonedCourse_CourseCloneRequest FOREIGN KEY (CourseCloneRequestId) REFERENCES CourseCloneRequest(Id)
			, CONSTRAINT FK_CourseClonedCourse_Course FOREIGN KEY (NewCourseId) REFERENCES Course(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

