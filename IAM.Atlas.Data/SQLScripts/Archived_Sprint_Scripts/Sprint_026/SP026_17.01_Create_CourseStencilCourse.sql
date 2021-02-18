/*
	SCRIPT: Create CourseStencilCourse Table
	Author: Dan Hough
	Created: 12/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_17.01_Create_CourseStencilCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseStencilCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseStencilCourse'
		
		/*
		 *	Create CourseStencilCourse Table
		 */
		IF OBJECT_ID('dbo.CourseStencilCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseStencilCourse;
		END

		CREATE TABLE CourseStencilCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT
			, CourseStencilId INT
			, DateCreated DATETIME
			, CONSTRAINT FK_CourseStencilCourse_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseStencilCourse_CourseStencil FOREIGN KEY (CourseStencilId) REFERENCES CourseStencil(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

