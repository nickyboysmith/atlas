/*
	SCRIPT: Amend Update trigger on the ClientOnlineEmailChangeRequest table
	Author: Robert Newnham
	Created: 07/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_08.01_AmendUpdateTriggerToClientOnlineEmailChangeRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger on the ClientOnlineEmailChangeRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientOnlineEmailChangeRequest_Update]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_ClientOnlineEmailChangeRequest_Update];
		END
GO
		CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_Update ON dbo.ClientOnlineEmailChangeRequest AFTER UPDATE
		AS

		BEGIN
			UPDATE COECRH
			SET COECRH.DateConfirmed = I.DateConfirmed
			FROM dbo.ClientOnlineEmailChangeRequestHistory COECRH
			INNER JOIN Inserted I	ON I.DateRequested = COECRH.DateRequested
									AND I.ClientId = COECRH.ClientId
									AND I.ClientOrganisationId = COECRH.ClientOrganisationId
									AND I.ConfirmationCode = COECRH.ConfirmationCode
			INNER JOIN Deleted D	ON D.DateRequested = I.DateRequested
									AND D.ClientId = I.ClientId
									AND D.ClientOrganisationId = I.ClientOrganisationId
									AND D.ConfirmationCode = I.ConfirmationCode
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;

			UPDATE E
			SET E.[Address] = I.NewEmailAddress
			FROM Inserted I
			INNER JOIN Deleted D			ON D.DateRequested = I.DateRequested
											AND D.ClientId = I.ClientId
											AND D.ClientOrganisationId = I.ClientOrganisationId
											AND D.ConfirmationCode = I.ConfirmationCode
			INNER JOIN dbo.ClientEmail CE	ON CE.ClientId = I.ClientId
			INNER JOIN dbo.Email E			ON E.Id = CE.EmailId
											AND E.[Address] = I.PreviousEmailAddress
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;
			
			DELETE COECR
			FROM dbo.ClientOnlineEmailChangeRequest COECR
			INNER JOIN Inserted I	ON I.DateRequested = COECR.DateRequested
									AND I.ClientId = COECR.ClientId
									AND I.ClientOrganisationId = COECR.ClientOrganisationId
									AND I.ConfirmationCode = COECR.ConfirmationCode
			INNER JOIN Deleted D	ON D.DateRequested = I.DateRequested
									AND D.ClientId = I.ClientId
									AND D.ClientOrganisationId = I.ClientOrganisationId
									AND D.ConfirmationCode = I.ConfirmationCode
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;
		END
		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP030_08.01_AmendUpdateTriggerToClientOnlineEmailChangeRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO