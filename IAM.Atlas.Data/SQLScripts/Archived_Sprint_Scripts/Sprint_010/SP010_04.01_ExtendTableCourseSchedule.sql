

/*
	SCRIPT: Add additional columns to the CourseSchedule table
	Author: Dan Murray
	Created: 07/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_12.01_ExtendTableCourseSchedule.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table CourseSchedule
		*/
		

		ALTER TABLE dbo.CourseSchedule	
		ADD CreatedByUserId int NOT NULL
		, DateUpdated DATETIME
		, CONSTRAINT FK_CourseSchedule_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

