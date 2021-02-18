/*
	SCRIPT: Add insert trigger to the AllTrainerDocument table
	Author: Nick Smith
	Created: 25/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_03.01_AddInsertTriggerToAllTrainerDocumentToInsertTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the AllTrainerDocument table. 
										Insert a row into table TrainerDocument for every trainer in the Organisation 
										where the Documentid does not exist for that trainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT];
		END
GO
		CREATE TRIGGER TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT ON AllTrainerDocument FOR INSERT
AS

		INSERT INTO [dbo].[TrainerDocument]
           ([OrganisationId]
           ,[TrainerId]
           ,[DocumentId])
        SELECT
			i.OrganisationId
           ,t.TrainerId
           ,i.DocumentId 
		FROM
           inserted i
		   INNER JOIN TrainerOrganisation t on i.OrganisationId = t.OrganisationId
		WHERE NOT EXISTS 
			(SELECT *
				FROM TrainerDocument td
				WHERE (i.OrganisationId = td.OrganisationId ) AND 
					(t.TrainerId = td.TrainerId ) AND 
					(i.DocumentId = td.DocumentId ))

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_03.01_AddInsertTriggerToAllTrainerDocumentToInsertTrainerDocument.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO