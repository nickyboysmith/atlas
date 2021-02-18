/*
	SCRIPT: Create Trigger on ClientView
	Author: Dan Hough
	Created: 02/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_10.01_AmendInsertTriggerOnClientView.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create insert trigger on ClientView';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_ClientView_Insert', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_ClientView_Insert;
END

GO

CREATE TRIGGER [dbo].[TRG_ClientView_Insert] ON [dbo].[ClientView] AFTER INSERT
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'ClientView', 'TRG_ClientView_Insert', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------

		DELETE cv
		FROM dbo.ClientView cv
		INNER JOIN Inserted i ON cv.ClientId = i.ClientId
								AND cv.ViewedByUserId = i.ViewedByUserId
								AND cv.DateTimeViewed < i.DateTimeViewed;

	END
END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP037_10.01_AmendInsertTriggerOnClientView.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

