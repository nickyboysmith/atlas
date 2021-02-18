/*
 * SCRIPT: Fix Null Data In Venue Table
 * Author: Robert Newnham
 * Created: 10/03/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_13.01_FixNullDataOnTableVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Fix Null Data In Venue Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE dbo.Venue
		SET [Enabled] = 'True'
		WHERE [Enabled] IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
