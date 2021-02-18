
/*
	SCRIPT: Create VenueRegion
	Author: NickSmith
	Created: 24/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_48.01_CreateVenueRegion.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create VenueRegion Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'VenueRegion'

		/*
			Create Table VenueRegion
		*/
		IF OBJECT_ID('dbo.VenueRegion', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueRegion;
		END

		CREATE TABLE VenueRegion(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, RegionId int NOT NULL
			, CONSTRAINT FK_VenueRegion_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
			, CONSTRAINT FK_VenueRegion_Region FOREIGN KEY (RegionId) REFERENCES [Region](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

