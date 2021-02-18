/*
	SCRIPT: Create SystemFeatureUserNote Table
	Author: Dan Hough
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_24.01_Create_SystemFeatureUserNote.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemFeatureUserNote Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemFeatureUserNote'
		
		/*
		 *	Create SystemFeatureUserNote Table
		 */
		IF OBJECT_ID('dbo.SystemFeatureUserNote', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemFeatureUserNote;
		END

		CREATE TABLE SystemFeatureUserNote(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SystemFeatureItemId INT
			, NoteId INT
			, AddedByUserId INT
			, DateAdded DATETIME
			, [Disabled] BIT DEFAULT 'FALSE'
			, OrganisationId INT
			, ShareWithOrganisation BIT DEFAULT 'FALSE'
			, CONSTRAINT FK_SystemFeatureUserNote_SystemFeatureItem FOREIGN KEY (SystemFeatureItemId) REFERENCES SystemFeatureItem(Id)
			, CONSTRAINT FK_SystemFeatureUserNote_Note FOREIGN KEY (NoteId) REFERENCES Note(Id)
			, CONSTRAINT FK_SystemFeatureUserNote_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_SystemFeatureUserNote_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;