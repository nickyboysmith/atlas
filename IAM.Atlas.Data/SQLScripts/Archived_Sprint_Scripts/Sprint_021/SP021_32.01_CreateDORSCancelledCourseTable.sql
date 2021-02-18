/*
	SCRIPT: Create DORS Cancelled Course Table
	Author: Nick Smith
	Created: 07/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_32.01_CreateDORSCancelledCourseTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSCancelledCourse Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSCancelledCourse'
		
		/*
		 *	Create DORSCancelledCourse Table
		 */
		IF OBJECT_ID('dbo.DORSCancelledCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSCancelledCourse;
		END

		CREATE TABLE DORSCancelledCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, DORSNotified bit NOT NULL DEFAULT 'False'
			, DateDORSNotified DateTime NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_DORSCancelledCourse_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;