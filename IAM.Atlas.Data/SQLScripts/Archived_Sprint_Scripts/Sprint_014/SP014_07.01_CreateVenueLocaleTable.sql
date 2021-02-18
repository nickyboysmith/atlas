/*
	SCRIPT:  Create Venue Locale Table
	Author:  Miles Stewart
	Created: 08/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_07.01_CreateVenueLocaleTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the VenueLocale table and add a column to the course venue page with FK';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/**
		 * Drop the constraints
		 */
		EXEC dbo.uspDropTableContraints 'VenueLocale'


		/**
		 * Create new table 'VenueLocale'
		 */
		IF OBJECT_ID('dbo.VenueLocale', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueLocale;
		END

		CREATE TABLE VenueLocale(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VenueId int 
			, Title varchar(100)
			, DefaultMaximumPlaces int 
			, DefaultReservedPlaces int 
			, Enabled bit DEFAULT 1
			, CONSTRAINT FK_VenueLocale_Venue FOREIGN KEY (VenueId) REFERENCES [Venue](Id)
		);


		/**
		 * Add
		 */
		IF OBJECT_ID('dbo.CourseVenue', 'U') IS NOT NULL
		BEGIN
			ALTER TABLE dbo.CourseVenue
				ADD VenueLocaleId int,
				CONSTRAINT FK_CourseVenue_VenueLocale FOREIGN KEY (VenueLocaleId) REFERENCES [VenueLocale](Id);
		END
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;