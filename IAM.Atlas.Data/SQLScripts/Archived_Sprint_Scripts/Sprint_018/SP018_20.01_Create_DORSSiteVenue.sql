/*
	SCRIPT: Create DORSSiteVenue Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_20.01_Create_DORSSiteVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSSiteVenue Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSSiteVenue'
		
		/*
		 *	Create DORSSiteVenue Table
		 */
		IF OBJECT_ID('dbo.DORSSiteVenue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSSiteVenue;
		END

		CREATE TABLE DORSSiteVenue(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int NOT NULL
			, DORSSiteId int NOT NULL
			, CONSTRAINT FK_DORSSiteVenue_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			, CONSTRAINT FK_DORSSiteVenue_DORSSite FOREIGN KEY (DORSSiteId) REFERENCES DORSSite(Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;