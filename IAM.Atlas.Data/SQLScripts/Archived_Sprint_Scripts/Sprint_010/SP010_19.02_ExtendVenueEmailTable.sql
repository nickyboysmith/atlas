

/*
	SCRIPT: Add VenueId column and constraint to the VenueEmail table
	Author: Dan Murray
	Created: 20/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_19.02_ExtendVenueEmailTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
				

		/*
			Populate default values for existing tables
		*/
		UPDATE dbo.VenueEmail
		SET VenueId = 1
		
		/*
			Add the constraint
		*/
		ALTER TABLE dbo.VenueEmail 
		ALTER COLUMN VenueId int not null

		ALTER TABLE dbo.VenueEmail
		ADD CONSTRAINT FK_VenueEmail_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
		 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

