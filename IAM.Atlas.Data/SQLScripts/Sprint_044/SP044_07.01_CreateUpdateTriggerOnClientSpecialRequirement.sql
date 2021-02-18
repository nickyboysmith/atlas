/*
	SCRIPT: Amend Update trigger on ClientSpecialRequirement
	Author: Robert Newnham
	Created: 27/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP044_07.01_CreateUpdateTriggerOnClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Update Trigger on ClientSpecialRequirement';

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
				WHERE I.SpecialRequirementId != D.SpecialRequirementId --This will Ensure that the Organisation is Renotified if the Special Requirement Changes
				AND I.OrganisationNotified = 'True' --Only Update if Required
				;
				
			END
			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP044_07.01_CreateUpdateTriggerOnClientSpecialRequirement.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO