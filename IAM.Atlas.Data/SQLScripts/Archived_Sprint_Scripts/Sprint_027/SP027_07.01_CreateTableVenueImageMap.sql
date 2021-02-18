/*
 * SCRIPT: Create VenueImageMap Table
 * Author: Paul Tuck
 * Created: 04/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_07.01_CreateTableVenueImageMap.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create VenueImageMap Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VenueImageMap'
		
		/*
		 *	Create VenueImageMap Table
		 */
		IF OBJECT_ID('dbo.VenueImageMap', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VenueImageMap;
		END
		
		CREATE TABLE VenueImageMap(
			[Id] INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [VenueId] INT NOT NULL
			, [DocumentId] INT NOT NULL
			, [DateAdded] DATETIME NOT NULL
			, [AddedByUserId] INT NOT NULL
			, CONSTRAINT FK_VenueImageMap_Venue FOREIGN KEY (VenueId) REFERENCES Venue(Id)
			, CONSTRAINT FK_VenueImageMap_Document FOREIGN KEY (DocumentId) REFERENCES Document(Id)
			, CONSTRAINT FK_VenueImageMap_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

