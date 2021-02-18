/*
	SCRIPT: Create DORSCourse Table
	Author: Paul Tuck
	Created: 23/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP016_07.01_Create_DORSCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSCourse'
		
		/*
		 *	Create DORSCourse Table
		 */
		IF OBJECT_ID('dbo.DORSCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSCourse;
		END

		CREATE TABLE DORSCourse(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, CONSTRAINT FK_DORSCourse_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;