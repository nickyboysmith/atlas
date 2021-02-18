/*
	SCRIPT: Alter insert trigger to the DORSTrainerLicence table to Insert into DORSTrainerLicenceState and DORSTrainerLicenceType
	Author: Nick Smith
	Created: 05/01/2017
*/


DECLARE @ScriptName VARCHAR(100) = 'SP031_22.01_AlterInsertTriggerToDORSTrainerLicenceToInsertDORSTrainerLicenceStateAndDORSTrainerLicenceType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter insert trigger to the DORSTrainerLicence table to Insert into DORSTrainerLicenceState and DORSTrainerLicenceType';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DORSTrainerLicenceForDORSTrainerLicenceStateAndDORSTrainerLicenceType_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_DORSTrainerLicenceForDORSTrainerLicenceStateAndDORSTrainerLicenceType_INSERT];
	END
GO
	CREATE TRIGGER TRG_DORSTrainerLicenceForDORSTrainerLicenceStateAndDORSTrainerLicenceType_INSERT ON DORSTrainerLicence AFTER INSERT
	AS

		INSERT INTO [dbo].[DORSTrainerLicenceState]
				   ([Identifier]
				   ,[Name]
				   ,[UpdatedByUserId])
		SELECT
				(CASE WHEN NOT EXISTS(SELECT * FROM [dbo].[DORSTrainerLicenceState])
					THEN 1
					ELSE (SELECT MAX([Identifier]) + 1 FROM [dbo].[DORSTrainerLicenceState])
					END) AS Identifier
					,i.DORSTrainerLicenceStateName AS [Name]
					,[dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
		FROM Inserted i
		LEFT JOIN [dbo].[DORSTrainerLicenceState] T ON T.[Name] = i.DORSTrainerLicenceStateName
		WHERE T.Id IS NULL;

		INSERT INTO [dbo].[DORSTrainerLicenceType]
				   ([Identifier]
				   ,[Name]
				   ,[UpdatedByUserId])
		SELECT
				(CASE WHEN NOT EXISTS(SELECT * FROM [dbo].[DORSTrainerLicenceType])
					THEN 1
					ELSE (SELECT MAX([Identifier]) + 1 FROM [dbo].[DORSTrainerLicenceType])
					END) AS Identifier
					,i.DORSTrainerLicenceTypeName AS [Name]
					,[dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
		FROM Inserted i
		LEFT JOIN [dbo].[DORSTrainerLicenceType] T ON T.[Name] = i.DORSTrainerLicenceTypeName
		WHERE T.Id IS NULL;

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP031_22.01_AlterInsertTriggerToDORSTrainerLicenceToInsertDORSTrainerLicenceStateAndDORSTrainerLicenceType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

