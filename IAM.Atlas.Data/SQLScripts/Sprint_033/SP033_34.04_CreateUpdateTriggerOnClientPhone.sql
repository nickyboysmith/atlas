/*
	SCRIPT: Create Update trigger on ClientPhone
	Author: Robert Newnham
	Created: 19/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_34.04_CreateUpdateTriggerOnClientPhone.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on ClientPhone';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientPhone_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientPhone_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientPhone_UPDATE] ON [dbo].[ClientPhone] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientPhone', 'TRG_ClientPhone_UPDATE', @insertedRows, @deletedRows;
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
				I.ClientId												AS ClientId
				, 'Contact Detail'										AS ChangeType
				, 'Phone'												AS ColumnName
				, PTD.[Type] + ': ' + D.PhoneNumber
					+ (CASE WHEN D.DefaultNumber = 'True'
						THEN ' (Default Number)'
						ELSE '' END)									AS PreviousValue
				, PTI.[Type] + ': ' + I.PhoneNumber
					+ (CASE WHEN I.DefaultNumber = 'True'
						THEN ' (Default Number)'
						ELSE '' END)									AS NewValue
				, 'Client Phone was changed From: "' + PTD.[Type] + ': ' + D.PhoneNumber + '" '
						+ (CASE WHEN D.DefaultNumber = 'True'
							THEN ' (Default Number) '
							ELSE '' END)
					+ 'To: "' + PTI.[Type] + ': ' + I.PhoneNumber + '"'
						+ (CASE WHEN I.DefaultNumber = 'True'
							THEN ' (Default Number)'
							ELSE '' END)
																		AS Comment
				, GETDATE()												AS DateCreated
				, C.UpdatedByUserId										AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			INNER JOIN PhoneType PTI ON PTI.Id = I.PhoneTypeId
			INNER JOIN PhoneType PTD ON PTD.Id = D.PhoneTypeId
			INNER JOIN Client C ON C.Id = I.ClientId
			WHERE D.PhoneTypeId != I.PhoneTypeId
			OR D.PhoneNumber != I.PhoneNumber
			OR D.DefaultNumber != I.DefaultNumber
			;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_34.04_CreateUpdateTriggerOnClientPhone.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO