/*
	SCRIPT: Add update trigger on the NetcallAgent table
	Author: Dan Hough
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_26.01_AddUpdateTriggerToNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger to NetcallAgent table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_NetcallAgent_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NetcallAgent_Update];
		END
GO
		CREATE TRIGGER TRG_NetcallAgent_Update ON dbo.NetcallAgent AFTER UPDATE
AS

BEGIN
	IF UPDATE (DefaultCallingNumber)
	BEGIN
		INSERT INTO dbo.NetcallAgentNumberHistory
				   (NetcallAgentId
				   ,PreviousCallingNumber
				   ,NewCallingNumber
				   ,DateChanged
				   ,ChangedByUserId)

		SELECT d.Id
			, d.DefaultCallingNumber
			, i.DefaultCallingNumber
			, GETDATE()
			, i.UpdateByUserId
		FROM Deleted d
		INNER JOIN Inserted i ON d.id = i.id

		UPDATE dbo.NetcallAgent
		SET [Disabled] = 'True'
		FROM Inserted i
		WHERE (i.DefaultCallingNumber IS NULL OR i.DefaultCallingNumber = '') AND (NetCallAgent.Id = i.Id)

	END

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_26.01_AddUpdateTriggerToNetcallAgent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO