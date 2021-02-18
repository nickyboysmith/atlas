

/*
	SCRIPT: Create CourseLanguage Table
	Author: Dan Murray
	Created: 23/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_04.01_CreateTableCourseLanguage.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseLanguage'

		/*
			Create Table CourseLanguage
		*/
		IF OBJECT_ID('dbo.[CourseLanguage]', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.[CourseLanguage];
		END

		CREATE TABLE [CourseLanguage](
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, OrganisationLanguageId int NOT NULL 
			, CONSTRAINT FK_CourseLanguage_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseLanguage_OrganisationLanguage FOREIGN KEY (OrganisationLanguageId) REFERENCES [OrganisationLanguage](Id)					
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

