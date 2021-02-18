/*
	SCRIPT:  Log DORSConnection changes
	Author:  Miles Stewart
	Created: 05/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_05.01_CreateUpdateTriggerOnDORSConnectionTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Trigger to Log DORSConnection Table changes on update';


EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DORSConnection_UPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_DORSConnection_UPDATE];
	END
GO
	CREATE TRIGGER TRG_DORSConnection_UPDATE ON DORSConnection FOR UPDATE
AS
	BEGIN
		INSERT INTO DORSConnectionHistory (DORSConnectionId, ColumnName, PreviousValue, NewValue, ChangedByUserId, DateChanged)
		SELECT 
			d.id AS DORSConnectionId
			, 'LoginName'
			, d.LoginName AS PreviousValue
			, i.LoginName AS NewValue
			, i.UpdatedByUserId AS ChangedByUserId
			, GetDate() AS DateChanged
		FROM deleted d 
		INNER JOIN inserted i ON i.id = d.id
		WHERE d.LoginName <> i.LoginName

		INSERT INTO DORSConnectionHistory (DORSConnectionId, ColumnName, PreviousValue, NewValue, ChangedByUserId, DateChanged)
		SELECT 
			d.id AS DORSConnectionId
			, 'Password'
			, d.Password AS PreviousValue
			, i.Password AS NewValue
			, i.UpdatedByUserId AS ChangedByUserId
			, GetDate() AS DateChanged
		FROM deleted d 
		INNER JOIN inserted i ON i.id = d.id
		WHERE d.Password <> i.Password

		UPDATE DORSConnection
		SET PasswordLastChanged = GetDate()
		WHERE id in (SELECT d.id FROM deleted d 
					INNER JOIN inserted i ON i.id = d.id
					WHERE d.Password <> i.Password)

		INSERT INTO DORSConnectionHistory (DORSConnectionId, ColumnName, PreviousValue, NewValue, ChangedByUserId, DateChanged)
		SELECT 
			d.id AS DORSConnectionId
			, 'OrganisationId'
			, CAST(d.OrganisationId AS Varchar) AS PreviousValue
			, CAST(i.OrganisationId AS Varchar) AS NewValue
			, i.UpdatedByUserId AS ChangedByUserId
			, GetDate() AS DateChanged
		FROM deleted d 
		INNER JOIN inserted i ON i.id = d.id
		WHERE d.OrganisationId <> i.OrganisationId

		INSERT INTO DORSConnectionHistory (DORSConnectionId, ColumnName, PreviousValue, NewValue, ChangedByUserId, DateChanged)
		SELECT 
			d.id AS DORSConnectionId
			, 'Enabled'
			, CAST(d.Enabled AS Varchar) AS PreviousValue
			, CAST(i.Enabled AS Varchar) AS NewValue
			, i.UpdatedByUserId AS ChangedByUserId
			, GetDate() AS DateChanged
		FROM deleted d 
		INNER JOIN inserted i ON i.id = d.id
		WHERE d.Enabled <> i.Enabled

		INSERT INTO DORSConnectionHistory (DORSConnectionId, ColumnName, PreviousValue, NewValue, ChangedByUserId, DateChanged)
		SELECT 
			d.id AS DORSConnectionId
			, 'NotificationEmail'
			, d.NotificationEmail AS PreviousValue
			, i.NotificationEmail AS NewValue
			, i.UpdatedByUserId AS ChangedByUserId
			, GetDate() AS DateChanged
		FROM deleted d 
		INNER JOIN inserted i ON i.id = d.id
		WHERE d.NotificationEmail <> i.NotificationEmail
	END 
	GO


	/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP014_05.01_CreateUpdateTriggerOnDORSConnectionTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO