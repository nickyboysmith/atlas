/*
	SCRIPT: Add update trigger on the LoginNumber table
	Author: Dan Hough
	Created: 22/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_02.01_AddUpdateTriggerToLoginNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update trigger on the LoginNumber table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_LoginNumber_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_LoginNumber_UPDATE];
		END
GO
		CREATE TRIGGER TRG_LoginNumber_UPDATE ON LoginNumber AFTER INSERT
AS
	
BEGIN

	UPDATE LN

	SET   DateAdded = GETDATE()
	FROM	LoginNumber LN INNER JOIN
	inserted i ON LN.id = i.id
	WHERE LN.DateAdded IS NULL AND i.id = LN.id

END

GO


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP018_02.01_AddUpdateTriggerToLoginNumber.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO