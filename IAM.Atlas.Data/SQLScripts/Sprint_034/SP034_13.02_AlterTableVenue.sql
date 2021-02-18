/*
 * SCRIPT: Alter Column in Venue Table
 * Author: Robert Newnham
 * Created: 10/03/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_13.02_AlterTableVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Column in Venue Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.Venue
		ALTER COLUMN [Enabled] BIT NOT NULL;
		
		ALTER TABLE dbo.Venue
		ADD CONSTRAINT DF_Venue_Enabled DEFAULT 'True' FOR [Enabled];

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
