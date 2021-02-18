/*
	SCRIPT: Add update, insert trigger to Organisation table
	Author: Dan Hough
	Created: 19/04/2016
*/
DECLARE @ScriptName VARCHAR(100) = 'SP019_05.01_AddUpdateInsertTriggerToOrganisation';
DECLARE @ScriptComments VARCHAR(800) = 'Add update, insert trigger to Organisation table';

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
	IF EXISTS (SELECT id FROM inserted)
	BEGIN
		/*update*/
		IF EXISTS (SELECT * FROM Deleted)

			BEGIN
			
			INSERT INTO OrganisationSelfConfiguration 
						(OrganisationId
						, NewClientMessage
						, DateUpdated
						, ClientApplicationDescription
						, ClientWelcomeMessage)

			SELECT		 i.Id
						, NewClientMessage = 'Welcome to the Booking System'
						, DateUpdated = GETDATE()
						, ClientApplicationDescription = 'Driver Booking'
						, ClientWelcomeMessage = 'Welcome to the Booking System'

			FROM inserted i INNER JOIN 
			Organisation o ON o.id = i.Id 
			WHERE NOT EXISTS (SELECT * FROM OrganisationSelfConfiguration WHERE OrganisationId = i.id)

			INSERT INTO OrganisationSystemConfiguration
						(OrganisationId
					   , DateUpdated)

			SELECT	     i.id
					   , DateUpdated = GETDATE()

			FROM inserted i INNER JOIN 
			Organisation o ON o.id = i.Id 
			WHERE NOT EXISTS (SELECT * FROM OrganisationSystemConfiguration WHERE OrganisationId = i.id)


			END

		ELSE
			/*INSERT*/
		BEGIN
			IF NOT EXISTS (SELECT id FROM deleted)
			INSERT INTO OrganisationSelfConfiguration 
						(OrganisationId
						, NewClientMessage
						, DateUpdated
						, ClientApplicationDescription
						, ClientWelcomeMessage)

			SELECT		 i.Id
						, NewClientMessage = 'Welcome to the Booking System'
						, DateUpdated = GETDATE()
						, ClientApplicationDescription = 'Driver Booking'
						, ClientWelcomeMessage = 'Welcome to the Booking System'

			FROM inserted i 

			INSERT INTO OrganisationSystemConfiguration
						(OrganisationId
					   ,DateUpdated)

			SELECT	   i.id
					   ,DateUpdated = GETDATE()


			FROM inserted i INNER JOIN 
			Organisation o ON o.id = i.Id 
		END
	END
	ELSE
		/*Delete*/
	BEGIN
		PRINT 'DELETE'
	END
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP019_05.01_AddUpdateInsertTriggerToOrganisation';

EXEC dbo.uspScriptCompleted @ScriptName;/*LOG SCRIPT COMPLETED*/
GO


