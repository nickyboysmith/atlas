/*
 * SCRIPT: Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_02.03_CorrectWronglyNamedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct wrongly named Table, from ScheduledSMSStatus to ScheduledSMSState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		INSERT INTO [dbo].[ScheduledSMSState] ([Name])
		SELECT [Name]
		FROM (SELECT 'Pending' AS [Name]
			UNION SELECT 'Sent' AS [Name]
			UNION SELECT 'Failed - Retrying' AS [Name]
			UNION SELECT 'Failed' AS [Name]
			) T
		WHERE T.[Name] NOT IN (SELECT DISTINCT [Name] FROM [dbo].[ScheduledSMSState]);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

