/*
	SCRIPT: Create Update trigger on Email
	Author: Robert Newnham
	Created: 19/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_34.02_CreateUpdateTriggerOnEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on Email';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Email_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Email_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Email_UPDATE] ON [dbo].[Email] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Email', 'TRG_Email_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
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
				CE.ClientId					AS ClientId
				, 'Contact Detail'			AS ChangeType
				, 'Email'					AS ColumnName
				, D.[Address]				AS PreviousValue
				, I.[Address]				AS NewValue
				, 'Client Email Address was changed From: "' + D.[Address] + '" '
					+ 'To: "' + I.[Address] + '"'
											AS Comment
				, GETDATE()					AS DateCreated
				, C.UpdatedByUserId			AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			INNER JOIN ClientEmail CE ON CE.EmailId = I.Id
			INNER JOIN Client C ON C.Id = CE.ClientId
			WHERE D.[Address] != I.[Address]
			;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_34.02_CreateUpdateTriggerOnEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO