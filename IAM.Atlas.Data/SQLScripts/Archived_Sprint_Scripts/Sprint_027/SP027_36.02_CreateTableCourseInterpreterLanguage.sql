/*
 * SCRIPT: Create Table CourseInterpreterLanguage 
 * Author: Nick Smith
 * Created: 17/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_36.02_CreateTableCourseInterpreterLanguage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table CourseInterpreterLanguage';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseInterpreterLanguage'
		
		/*
		 *	Create CourseInterpreterLanguage Table
		 */
		IF OBJECT_ID('dbo.CourseInterpreterLanguage', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseInterpreterLanguage;
		END
		
		CREATE TABLE CourseInterpreterLanguage(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [CourseId] INT NOT NULL
			, [LanguageId] INT NOT NULL
			, CONSTRAINT FK_CourseInterpreterLanguage_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseInterpreterLanguage_Language FOREIGN KEY (LanguageId) REFERENCES [Language](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

