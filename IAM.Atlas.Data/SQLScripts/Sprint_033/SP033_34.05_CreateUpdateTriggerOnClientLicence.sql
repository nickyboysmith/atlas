/*
	SCRIPT: Create Update trigger on ClientLicence
	Author: Robert Newnham
	Created: 19/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_34.05_CreateUpdateTriggerOnClientLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on ClientLicence';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientLicence_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientLicence_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientLicence_UPDATE] ON [dbo].[ClientLicence] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientLicence', 'TRG_ClientLicence_UPDATE', @insertedRows, @deletedRows;
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
				, 'Licence'												AS ChangeType
				, 'Licence'												AS ColumnName
				, D.LicenceNumber
					+ (CASE WHEN D.DriverLicenceTypeId IS NOT NULL
						THEN ' (' + DLTD.[Name] + ')'
						ELSE '' END)									AS PreviousValue
				, I.LicenceNumber
					+ (CASE WHEN I.DriverLicenceTypeId IS NOT NULL
						THEN ' (' + DLTI.[Name] + ')'
						ELSE '' END)									AS NewValue
				, 'Client Licence Change; From: "' + D.LicenceNumber + '" '
						+ (CASE WHEN D.DriverLicenceTypeId IS NOT NULL
								THEN ' (' + DLTD.[Name] + ')'
								ELSE '' END)
						+ (CASE WHEN D.LicenceExpiryDate IS NOT NULL
								THEN '; Expires:' +  CONVERT(VARCHAR, D.LicenceExpiryDate, 106)
								ELSE '' END)
					+ 'To: "' + I.LicenceNumber + '" '
						+ (CASE WHEN I.DriverLicenceTypeId IS NOT NULL
								THEN ' (' + DLTI.[Name] + ')'
								ELSE '' END)
						+ (CASE WHEN I.LicenceExpiryDate IS NOT NULL
								THEN '; Expires:' +  CONVERT(VARCHAR, I.LicenceExpiryDate, 106)
								ELSE '' END)
																		AS Comment
				, GETDATE()												AS DateCreated
				, C.UpdatedByUserId										AS AssociatedUserId
			FROM INSERTED I 
			INNER JOIN DELETED D On D.Id = I.Id
			LEFT JOIN DriverLicenceType DLTI ON DLTI.Id = I.DriverLicenceTypeId
			LEFT JOIN DriverLicenceType DLTD ON DLTD.Id = D.DriverLicenceTypeId
			INNER JOIN Client C ON C.Id = I.ClientId
			WHERE D.LicenceNumber != I.LicenceNumber
			OR D.LicenceExpiryDate != I.LicenceExpiryDate
			OR D.DriverLicenceTypeId != I.DriverLicenceTypeId
			;
			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_34.05_CreateUpdateTriggerOnClientLicence.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO