

/*
	SCRIPT: Add VenueId column and constraint to the VenueEmail table
	Author: Dan Murray
	Created: 20/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_19.01_ExtendVenueEmailTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update VenueEmail table: add VenueId column and FK
		*/
		ALTER TABLE dbo.VenueEmail	
		ADD VenueId int 

		 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

