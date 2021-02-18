


/*
	SCRIPT: Create CourseCategory Table
	Author: Robert Newnham
	Created: 19/06/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP004_05.01_CreateTableCourseCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseCategory'

		/*
			Create Table CourseCategory
		*/
		IF OBJECT_ID('dbo.CourseCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseCategory;
		END

		CREATE TABLE CourseCategory(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(10)
			, Disabled bit DEFAULT 0 NOT NULL
			, OrganisationId int NOT NULL
			, CONSTRAINT FK_CourseCategory_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);

		/*
			UPDATE Table Course. Add new column CourseCategory
		*/
		ALTER TABLE Course
			ADD CourseCategoryId int NULL,
			CONSTRAINT FK_Course_CourseCategory FOREIGN KEY(CourseCategoryId) REFERENCES CourseCategory(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

