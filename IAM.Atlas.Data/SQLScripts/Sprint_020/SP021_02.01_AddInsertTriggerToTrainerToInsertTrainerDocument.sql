/*
	SCRIPT: Add insert trigger to the AllTrainerDocument table
	Author: Nick Smith
	Created: 25/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_02.01_AddInsertTriggerToTrainerToInsertTrainerDocument.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the AllTrainerDocument table. 
										Check table AllTrainerDocument and Insert TrainerDocument for Trainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_TrainerToInsertTrainerDocument_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_TrainerToInsertTrainerDocument_INSERT];
		END
GO
		CREATE TRIGGER TRG_TrainerToInsertTrainerDocument_INSERT ON AllTrainerDocument FOR INSERT
AS

		INSERT INTO [dbo].[TrainerDocument]
           ([OrganisationId]
           ,[TrainerId]
           ,[DocumentId])
        SELECT
			atd.OrganisationId
           ,i.Id
           ,atd.DocumentId 
		FROM
           inserted i
		   INNER JOIN TrainerOrganisation ton on i.Id = ton.TrainerId AND
		   INNER JOIN AllTrainerDocument atd on ton.OrganisationId = atd.OrganisationId
		   

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_02.01_AddInsertTriggerToTrainerToInsertTrainerDocument';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO