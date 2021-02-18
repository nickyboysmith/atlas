/*THIS SCRIPT WAS CREATED DURING SPRINT 9 BUT RUN AT THE START OF SPRINT 10, HENCE THE DIFFERENCE IN FILE NAME TO SCRIPT NAME: USE THE SCRIPT NAME WHEN COMPARING TO THE SCRIPT LOG ENTRY*/

/*
	SCRIPT: Create CourseLog Table
	Author: Dan Murray
	Created: 07/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_09.01_CreateTableCourseLog.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'CourseLog'

		/*
			Create Table CourseLog
		*/
		IF OBJECT_ID('dbo.[CourseLog]', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.[CourseLog];
		END

		CREATE TABLE [CourseLog](
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL 
			, DateCreated DATETIME 
			, CreatedByUserId INT NOT NULL
			, Item VARCHAR(40)
			, NewValue VARCHAR(100)
			, OldValue VARCHAR(100)	
			, CONSTRAINT FK_CourseLog_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseLog_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)					
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

