/*
	SCRIPT: Create Course Quick Search Table
	Author: Dan Murray
	Created: 30/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_02.01_CreateTableCourseQuickSearch.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a table to store course quick-search data';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseQuickSearch'
		
		/*
			Drop tables in this order to avoid errors due to foreign key constraints
		*/
		IF OBJECT_ID('dbo.CourseQuickSearch', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseQuickSearch;
		END
		
		
		/*
			Create Table CourseQuickSearch
		*/
		CREATE TABLE CourseQuickSearch(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SearchContent VARCHAR(640) CONSTRAINT ux_CourseSearchContent UNIQUE NONCLUSTERED NOT NULL
			, DisplayContent VARCHAR(1000)
			, [Date] DATETIME 
			, OrganisationId INT NOT NULL
			, CourseId INT NOT NULL
			, CONSTRAINT FK_CourseQuickSearch_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseQuickSearch_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
			, 
		);
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;


