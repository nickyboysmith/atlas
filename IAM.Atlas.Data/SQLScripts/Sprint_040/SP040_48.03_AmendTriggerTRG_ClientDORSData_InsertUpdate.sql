/*
	SCRIPT: Amend trigger TRG_ClientDORSData_InsertUpdate
	Author: Robert Newnham
	Created: 19/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_48.03_AmendTriggerTRG_ClientDORSData_InsertUpdate.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_ClientDORSData_InsertUpdate', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientDORSData_InsertUpdate];
		END
	GO
	
	CREATE TRIGGER [dbo].[TRG_ClientDORSData_InsertUpdate] ON [dbo].[ClientDORSData] AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientDORSData', 'TRG_ClientDORSData_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE COBS
			SET COBS.DORSSchemeId = I.DORSSchemeId
			FROM INSERTED I
			INNER JOIN ClientOnlineBookingState COBS ON COBS.ClientId = I.ClientId
			WHERE I.DataValidatedAgainstDORS = 'True'
			AND COBS.DORSSchemeId IS NULL;
			/**********************************************************************************************/
			
			DECLARE @ClientId INT;
			SELECT @ClientId=I.ClientId
			FROM INSERTED I
			WHERE I.ReferringAuthorityId IS NULL;
			IF (@ClientId IS NOT NULL)
			BEGIN
				EXEC uspEnsureReferringAuthoritySetForClient @ClientId;
			END 

			/**********************************************************************************************/
			INSERT INTO [dbo].[ClientOrganisation] (ClientId, OrganisationId, DateAdded)
			SELECT 
				I.ClientId									AS ClientId
				, RA.AssociatedOrganisationId				AS OrganisationId
				, I.DateCreated								AS DateAdded
			FROM INSERTED I
			INNER JOIN dbo.ReferringAuthority RA			ON RA.Id= I.ReferringAuthorityId
			LEFT JOIN [dbo].[ClientOrganisation] CO			ON CO.ClientId = I.ClientId
															AND CO.OrganisationId = RA.AssociatedOrganisationId
			WHERE I.ReferringAuthorityId IS NOT NULL
			AND CO.Id IS NULL;
			
			INSERT INTO [dbo].[ReferringAuthorityClient] (ClientId, ReferringAuthorityId)
			SELECT 
				I.ClientId									AS ClientId
				, I.ReferringAuthorityId					AS ReferringAuthorityId
			FROM INSERTED I
			LEFT JOIN [dbo].[ReferringAuthorityClient] RAC			ON RAC.ClientId = I.ClientId
																	AND RAC.ReferringAuthorityId = I.ReferringAuthorityId
			WHERE RAC.Id IS NULL;

			
			/**********************************************************************************************/


		END --END PROCESS
	END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_48.03_AmendTriggerTRG_ClientDORSData_InsertUpdate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO