/*
	SCRIPT:  Update User Feedback Table
	Author:  Dan Murray
	Created: 11/01/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_08.01_UpdateUserFeedbackTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the User Feedback table: add additional column AditionalInfo';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update [UserFeedback] Table
		*/
		ALTER TABLE dbo.[UserFeedback] 
			ADD AdditionalInfo VARCHAR(400) NULL;		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;