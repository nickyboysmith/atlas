/*
	SCRIPT: Amend Update trigger on Client
	Author: Robert Newnham
	Created: 19/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_34.01_AmendInsertUpdateTriggerOnClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update trigger on Client';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Client_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Client_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Client_UPDATE] ON [dbo].[Client] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			/****************************************************************************************************************/
			DECLARE @userId INT
					, @clientId INT;

			SELECT @userId = I.UserId
					, @clientId = I.Id 
			FROM INSERTED I;

			EXEC uspClientEnsureUppercaseStart @ClientId;
			
			/****************************************************************************************************************/
			INSERT INTO [dbo].[ClientChangeLog] (
				ClientId
				, ChangeType
				, ColumnName
				, PreviousValue
				, NewValue
				, Comment
				, DateCreated
				, AssociatedUserId
				)
			SELECT 
				I.Id					AS ClientId
				, 'Identity'			AS ChangeType
				, 'Name'				AS ColumnName
				, D.DisplayName			AS PreviousValue
				, I.DisplayName			AS NewValue
				, 'Client Name Details was changed From: "' + D.DisplayName + '" '
					+ 'To: "' + I.DisplayName + '"'
										AS Comment
				, GETDATE()				AS DateCreated
				, I.UpdatedByUserId		AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			WHERE D.Title != I.Title
			OR D.FirstName != I.FirstName
			OR D.Surname != I.Surname
			OR D.DisplayName != I.DisplayName
			UNION SELECT 
				I.Id									AS ClientId
				, 'Identity'							AS ChangeType
				, 'Date of Birth'						AS ColumnName
				, CONVERT(VARCHAR, D.DateOfBirth, 106)	AS PreviousValue
				, CONVERT(VARCHAR, I.DateOfBirth, 106)	As NewValue
				, 'Client "Date of Birth" was changed From: "' + CONVERT(VARCHAR, D.DateOfBirth, 106) + '" '
					+ 'To: "' + CONVERT(VARCHAR, I.DateOfBirth, 106) + '"'
														AS Comment
				, GETDATE()								AS DateCreated
				, I.UpdatedByUserId						AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			WHERE D.DateOfBirth != I.DateOfBirth
			UNION SELECT 
				I.Id									AS ClientId
				, 'Identity'							AS ChangeType
				, 'Gender'								AS ColumnName
				, GD.[Name]								AS PreviousValue
				, GI.[Name]								As NewValue
				, 'Client "Gender" was changed From: "' + GD.[Name] + '" '
					+ 'To: "' + GI.[Name] + '"'
														AS Comment
				, GETDATE()								AS DateCreated
				, I.UpdatedByUserId						AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			INNER JOIN Gender GI ON GI.Id = I.GenderId
			INNER JOIN Gender GD ON GD.Id = D.GenderId
			WHERE D.GenderId != I.GenderId
			;
			/****************************************************************************************************************/

			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_34.01_AmendInsertUpdateTriggerOnClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO