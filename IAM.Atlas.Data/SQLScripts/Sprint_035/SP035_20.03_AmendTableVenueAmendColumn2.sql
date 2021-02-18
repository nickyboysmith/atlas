/*
 * SCRIPT: Amend Column Size to Table Venue
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_20.03_AmendTableVenueAmendColumn2.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Column Size to Table Venue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		
		ALTER TABLE [dbo].[Venue]
		ALTER COLUMN Description VARCHAR(400) NOT NULL;
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;