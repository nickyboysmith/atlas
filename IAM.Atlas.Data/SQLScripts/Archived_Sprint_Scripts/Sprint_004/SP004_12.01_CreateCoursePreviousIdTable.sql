/*
	SCRIPT: Create Table CoursePreviousId
	Author: Robert Newnham
	Created: 25/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_12.01_CreateCoursePreviousIdTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CoursePreviousId'

		/*
			Create Table CoursePreviousId
		*/
		IF OBJECT_ID('dbo.CoursePreviousId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CoursePreviousId;
		END

		CREATE TABLE CoursePreviousId(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, PreviousCourseId int NOT NULL
			, CONSTRAINT FK_CoursePreviousId_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
