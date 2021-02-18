/*
	SCRIPT: Amend update, insert trigger to Organisation table
	Author: Robert Newnham
	Created: 14/08/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP024_29.01_AmendUpdateInsertTriggerToOrganisation';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert trigger to Organisation table';

EXEC dbo.uspScriptStarted @ScriptName
	,@ScriptComments;/*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_Organisation_InsertUpdate]', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.[TRG_Organisation_InsertUpdate];
END
GO

	CREATE TRIGGER TRG_Organisation_InsertUpdate ON Organisation
	AFTER INSERT, UPDATE
	AS
	BEGIN
		INSERT INTO OrganisationSelfConfiguration 
					(OrganisationId
					, NewClientMessage
					, DateUpdated
					, ClientApplicationDescription
					, ClientWelcomeMessage)
		SELECT		 i.Id AS OrganisationId
					, 'Welcome to the Booking System' AS NewClientMessage
					, GETDATE() AS DateUpdated
					, 'Driver Booking' AS ClientApplicationDescription
					, 'Welcome to the Booking System' AS ClientWelcomeMessage
		FROM inserted i
		INNER JOIN Organisation o ON o.id = i.Id 
		WHERE NOT EXISTS (SELECT * FROM OrganisationSelfConfiguration WHERE OrganisationId = i.id);

		INSERT INTO OrganisationSystemConfiguration
					(OrganisationId
					, DateUpdated)
		SELECT	     i.id AS OrganisationId
					, GETDATE() AS DateUpdated
		FROM inserted i 
		INNER JOIN Organisation o ON o.id = i.Id 
		WHERE NOT EXISTS (SELECT * FROM OrganisationSystemConfiguration WHERE OrganisationId = i.id);
	END
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_29.01_AmendUpdateInsertTriggerToOrganisation';
EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO


