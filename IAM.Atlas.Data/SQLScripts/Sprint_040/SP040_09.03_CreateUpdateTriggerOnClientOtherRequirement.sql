/*
	SCRIPT: Create Update trigger on ClientOtherRequirement
	Author: Nick Smith
	Created: 30/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_09.03_CreateUpdateTriggerOnClientOtherRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update Trigger on ClientOtherRequirement';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ClientOtherRequirement_UPDATE', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ClientOtherRequirement_UPDATE;
	END
GO
	CREATE TRIGGER [dbo].[TRG_ClientOtherRequirement_UPDATE] ON [dbo].[ClientOtherRequirement] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientOtherRequirement', 'TRG_ClientOtherRequirement_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			BEGIN
				
				
				UPDATE ClientOtherRequirement 
				SET OrganisationNotified = 'False'
				FROM Inserted I
				INNER JOIN Deleted D ON I.Id = D.Id
				WHERE I.Name != D.Name
				
			END
			/****************************************************************************************************************/

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_09.03_CreateUpdateTriggerOnClientOtherRequirement.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO