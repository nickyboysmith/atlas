/*
	SCRIPT: Create Update trigger on Location
	Author: Robert Newnham
	Created: 19/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_34.03_CreateUpdateTriggerOnLocation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on Location';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_Location_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_Location_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_Location_UPDATE] ON [dbo].[Location] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Location', 'TRG_Location_UPDATE', @insertedRows, @deletedRows;
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
				CL.ClientId												AS ClientId
				, 'Contact Detail'										AS ChangeType
				, 'Postal Address'										AS ColumnName
				, D.[Address] + ' (Post Code: ' + D.PostCode + ')" '	AS PreviousValue
				, I.[Address] + ' (Post Code: ' + I.PostCode + ')"'		AS NewValue
				, 'Client Postal Address was changed From: "' + D.[Address] + ' (Post Code: ' + D.PostCode + ')" '
					+ 'To: "' + I.[Address] + ' (Post Code: ' + I.PostCode + ')"'
																		AS Comment
				, GETDATE()												AS DateCreated
				, C.UpdatedByUserId										AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			INNER JOIN ClientLocation CL ON CL.LocationId = I.Id
			INNER JOIN Client C ON C.Id = CL.ClientId
			WHERE D.[Address] != I.[Address]
			OR D.PostCode != I.PostCode
			;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_34.03_CreateUpdateTriggerOnLocation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO