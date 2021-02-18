/*
	SCRIPT: Create Update trigger on ClientSpecialRequirement
	Author: Nick Smith
	Created: 30/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_09.02_CreateUpdateTriggerOnClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update Trigger on ClientSpecialRequirement';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientSpecialRequirement_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientSpecialRequirement_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientSpecialRequirement_UPDATE] ON [dbo].[ClientSpecialRequirement] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientSpecialRequirement', 'TRG_ClientSpecialRequirement_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			BEGIN
				
				
				UPDATE ClientSpecialRequirement 
				SET OrganisationNotified = 'False'
				FROM Inserted I
				INNER JOIN Deleted D ON I.Id = D.Id
				WHERE I.SpecialRequirementId != D.SpecialRequirementId
				
			END
			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_09.02_CreateUpdateTriggerOnClientSpecialRequirement.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO