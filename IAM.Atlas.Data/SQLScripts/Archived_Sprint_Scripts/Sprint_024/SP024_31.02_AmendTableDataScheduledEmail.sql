/*
 * SCRIPT: Alter Table Data ScheduledEmail 
 * Author: Robert Newnham
 * Created: 17/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP024_31.02_AmendTableDataScheduledEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend the Table Data on ScheduledEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE [dbo].[ScheduledEmail]
		SET DateUpdated = DateCreated
		WHERE DateUpdated IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
