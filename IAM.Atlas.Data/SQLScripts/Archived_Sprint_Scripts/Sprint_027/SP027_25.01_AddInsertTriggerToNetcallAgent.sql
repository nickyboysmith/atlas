/*
	SCRIPT: Add insert trigger on the NetcallAgent table
	Author: Dan Hough
	Created: 11/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_25.01_AddInsertTriggerToNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to NetcallAgent table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_NetcallAgent_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_NetcallAgent_Insert];
		END
GO
		CREATE TRIGGER TRG_NetcallAgent_Insert ON dbo.NetcallAgent AFTER INSERT
AS

BEGIN

	UPDATE dbo.NetcallAgent
	SET [Disabled] = 'True'
	FROM Inserted i
	WHERE (i.DefaultCallingNumber IS NULL OR i.DefaultCallingNumber = '') AND (i.Id = NetCallAgent.Id)

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_25.01_AddInsertTriggerToNetcallAgent.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO