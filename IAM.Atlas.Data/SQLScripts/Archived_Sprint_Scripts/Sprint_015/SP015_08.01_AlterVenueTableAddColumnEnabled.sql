/*
	SCRIPT: Alter Table Venue Table, add column Enabled to table
	Author: Miles Stewart
	Created: 29/01/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_08.01_AlterVenueTableAddColumnEnabled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Venue Table, add column Enabled to table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Venue
			ADD [Enabled] bit;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
