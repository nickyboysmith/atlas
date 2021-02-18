/*
	SCRIPT: Create Insert/Update trigger to the EmailServiceCredential table
	Author: Robert Newnham
	Created: 09/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_24.04_CreateInsertUpdateTriggerOnEmailServiceCredentialTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert/Update trigger to the EmailServiceCredential table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_EmailServiceCredential_INSERTUPDATE]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_EmailServiceCredential_INSERTUPDATE];
	END
GO
	CREATE TRIGGER TRG_EmailServiceCredential_INSERTUPDATE ON EmailServiceCredential FOR INSERT, UPDATE
	AS
	BEGIN
   
		DECLARE @AtlasSystemUserId INT = [dbo].[udfGetSystemUserId]();

		INSERT INTO [dbo].[EmailServiceCredentialLog] (
								EmailServiceCredentialId
								, EmailServiceId
								, [Key]
								, Value
								, DateUpdated
								, UpdatedByUserId
								, Notes
								)
		SELECT 
				Id AS EmailServiceCredentialId
				, EmailServiceId
				, [Key]
				, Value
				, ISNULL(DateUpdated, GetDate()) AS DateUpdated
				, UpdatedByUserId
				, 'Details Changed From These Values' AS Notes
		FROM DELETED
		UNION
		SELECT 
				Id AS EmailServiceCredentialId
				, EmailServiceId
				, [Key]
				, Value
				, ISNULL(DateUpdated, GetDate()) AS DateUpdated
				, UpdatedByUserId
				, 'New Details Inserted' AS Notes
		FROM INSERTED;

	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_24.04_CreateInsertUpdateTriggerOnEmailServiceCredentialTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

