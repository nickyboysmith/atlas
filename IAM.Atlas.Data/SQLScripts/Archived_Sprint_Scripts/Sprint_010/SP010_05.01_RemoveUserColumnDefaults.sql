

/*
	SCRIPT: Remove default value for the CreatedByUserId column of the Course and CourseDate tables
	Author: Dan Murray
	Created: 09/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_05.01_RemoveUserColumnDefaults.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course and CourseDate
		*/
		ALTER TABLE dbo.Course	
		ALTER COLUMN CreatedByUserId int NOT NULL 

		ALTER TABLE dbo.CourseDate	
		ALTER COLUMN CreatedByUserId int NOT NULL 
					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

