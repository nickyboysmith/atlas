/*
	SCRIPT: Amend Insert trigger on the NetcallAgent table
	Author: Robert Newnham
	Created: 28/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_05.03_AmendInsertTriggerToNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger to NetcallAgent table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_NetcallAgent_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_NetcallAgent_Insert];
	END
GO
	CREATE TRIGGER TRG_NetcallAgent_Insert ON dbo.NetcallAgent AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'NetcallAgent', 'TRG_NetcallAgent_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			/****************************************************************************************************************/
			UPDATE NA
			SET NA.[Disabled] = 'True'
			FROM Inserted I
			INNER JOIN dbo.NetcallAgent NA ON NA.Id = I.Id
			WHERE LEN(ISNULL(I.DefaultCallingNumber,'')) <= 0
			AND I.[Disabled] = 'False';
			
			/****************************************************************************************************************/
			UPDATE NA
			SET NA.OrganisationId = OU.OrganisationId
			FROM Inserted I
			INNER JOIN dbo.NetcallAgent NA ON NA.Id = I.Id
			INNER JOIN dbo.OrganisationUser OU ON OU.UserId = I.UserId
			WHERE I.OrganisationId IS NULL;

			/****************************************************************************************************************/

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP034_05.03_AmendInsertTriggerToNetcallAgent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO