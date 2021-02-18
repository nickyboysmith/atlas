/*
	SCRIPT: Amend Insert trigger on ScheduledEmail
	Author: Dan Hough
	Created: 27/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_07.01_AmendInsertTriggerOnScheduledEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on ScheduledEmail';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_ScheduledEmail_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_ScheduledEmail_Insert;
	END
GO

	CREATE TRIGGER [dbo].[TRG_ScheduledEmail_Insert] ON [dbo].[ScheduledEmail] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ScheduledEmail', 'TRG_ScheduledEmail_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @id INT
				, @content VARCHAR(4000)
				, @startCheck BIT
				, @carriageReturnLineFeed VARCHAR(40) = CHAR(13) + CHAR(10)
				, @LineFeedLineFeed VARCHAR(40) = CHAR(10) + CHAR(10)
				, @paragraph CHAR(7) = '</p><p>';

			SELECT @id = id
					, @content = Content
			FROM Inserted i;

			SELECT @startCheck = CASE WHEN LEFT(@content, 3) = '<p>' THEN 1 ELSE 0 END;

			IF(@startCheck = 'False')
			BEGIN
				SET @content = '<p>' + @content + '</p>';
				SET @content = REPLACE(REPLACE(@content, @carriageReturnLineFeed, @carriageReturnLineFeed + @paragraph), @LineFeedLineFeed, @LineFeedLineFeed + @paragraph);

				UPDATE dbo.ScheduledEmail
				SET Content = @content
				WHERE Id = @id;
			END --IF(@startCheck = 'False')

			UPDATE SE
			SET SE.ASAP = 'True'
			FROM INSERTED I
			INNER JOIN dbo.ScheduledEmail SE ON SE.Id = I.Id
			WHERE I.ASAP IS NULL;

		END --END PROCESS
	END


GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP045_07.01_AmendInsertTriggerOnScheduledEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO
