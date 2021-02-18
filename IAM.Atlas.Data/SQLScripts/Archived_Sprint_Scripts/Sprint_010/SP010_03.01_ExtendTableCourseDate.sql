/*THIS SCRIPT WAS CREATED DURING SPRINT 9 BUT RUN AT THE START OF SPRINT 10, HENCE THE DIFFERENCE IN FILE NAME TO SCRIPT NAME: USE THE SCRIPT NAME WHEN COMPARING TO THE SCRIPT LOG ENTRY*/

/*
	SCRIPT: Add additional columns to the CourseDate table
	Author: Dan Murray
	Created: 07/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_11.01_ExtendTableCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table CourseDate
		*/
		

		ALTER TABLE dbo.CourseDate	
		ADD CreatedByUserId int NOT NULL DEFAULT 1
		, DateUpdated DATETIME
		, CONSTRAINT FK_CourseDate_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

