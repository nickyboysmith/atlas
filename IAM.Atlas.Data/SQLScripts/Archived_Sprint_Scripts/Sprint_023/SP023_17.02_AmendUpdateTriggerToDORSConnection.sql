/*
	SCRIPT: Amend The Update and Insert triggers on the DORSConnection table
	Author: Robert Newnham
	Created: 15/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_17.02_AmendUpdateTriggerToDORSConnection.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend The Update and Insert triggers on the DORSConnection table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.[TRG_DORSConnection_UPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_DORSConnection_UPDATE];
	END
	GO
	
	IF OBJECT_ID('dbo.[TRG_DORSConnection_UPDATE_AND_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_DORSConnection_UPDATE_AND_INSERT];
	END
	GO

	CREATE TRIGGER TRG_DORSConnection_UPDATE_AND_INSERT ON DORSConnection AFTER UPDATE, INSERT
	AS

	BEGIN

		DECLARE @DorsCode Varchar(4) = 'DORS';
		DECLARE @DorsEnabled Varchar(4) = 'DORS Enabled';
		DECLARE @DorsDisabled Varchar(4) = 'DORS Disabled';
		
		--Update DORS Status if Exists
		UPDATE SSS
		SET   Code = @DorsCode
			, [Message] = (CASE WHEN i.[enabled] = 'true' 
								THEN @DorsEnabled
								ELSE @DorsDisabled 
								END)
			, SystemStateId = (CASE WHEN i.[enabled] = 'true' 
								THEN 1 -- Green
								ELSE 4 -- Red
								END)
			, DateUpdated = GETDATE()
			, AddedByUserId = (CASE WHEN i.UpdatedByUserId IS NULL
									THEN dbo.udfGetSystemUserId()
									ELSE i.UpdatedByUserId
									END) 
		FROM SystemStateSummary SSS 
		INNER JOIN Inserted i ON SSS.OrganisationId = i.OrganisationId
		INNER JOIN Deleted d ON i.id = d.id 
							AND i.[enabled] <> d.[enabled] 
		WHERE SSS.Code = @DorsCode;
		
		--Create DORS Status if Not Exists
		INSERT INTO  SystemStateSummary (
					OrganisationId
					, Code
					, [Message]
					, SystemStateId
					, DateUpdated
					, AddedByUserId
					)	
		SELECT		i.OrganisationId
					, @DorsCode as Code
					, (CASE WHEN i.[enabled] = 'true' 
							THEN @DorsEnabled
							ELSE @DorsDisabled 
							END) AS [Message]
					, (CASE WHEN i.[enabled] = 'true' 
							THEN 1 -- Green
							ELSE 4 -- Red
							END) AS SystemStateId
					, DateUpdated = GETDATE()
					, (CASE WHEN i.UpdatedByUserId IS NULL
							THEN dbo.udfGetSystemUserId()
							ELSE i.UpdatedByUserId
							END) AS AddedByUserId
		FROM Inserted i 
		WHERE NOT EXISTS (SELECT * 
							FROM SystemStateSummary SSS 
							WHERE SSS.OrganisationId = i.OrganisationId 
							AND SSS.Code = @DorsCode)
	END

	GO


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_17.02_AmendUpdateTriggerToDORSConnection.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO