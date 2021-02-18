/*
	SCRIPT: Alter Table Venue Locale Table, add column Description to table
	Author: Miles Stewart
	Created: 29/01/2015
*/
DECLARE @ScriptName VARCHAR(100) = 'SP015_10.01_AlterVenueLocaleAddDescription.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Venue Locale Table, add column Description to table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.VenueLocale
			ADD [Description] varchar(200);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;