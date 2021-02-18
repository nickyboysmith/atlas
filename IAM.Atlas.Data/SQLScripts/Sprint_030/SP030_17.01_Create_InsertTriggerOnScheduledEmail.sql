/*
	SCRIPT: Add insert trigger on ScheduledEmail
	Author: Dan Hough
	Created: 13/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_17.01_Create_InsertTriggerOnScheduledEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger on the ScheduledEmail table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ScheduledEmail_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ScheduledEmail_Insert;
		END
GO
		CREATE TRIGGER TRG_ScheduledEmail_Insert ON dbo.ScheduledEmail AFTER INSERT
AS

BEGIN
	DECLARE @id INT
			, @content VARCHAR(4000)
			, @startCheck BIT
			, @carriageReturnLineFeed VARCHAR(40) = CHAR(10) + CHAR(13)
			, @paragraph CHAR(7) = '</p><p>';

	SELECT @id = id
		 , @content = Content
	FROM Inserted i;

	SELECT @startCheck = CASE WHEN LEFT(@content, 3) = '<p>' THEN 1 ELSE 0 END;

	IF(@startCheck = 'False')
	BEGIN
		SET @content = '<p>' + @content + '</p>';
		SET @content = REPLACE(@content, @carriageReturnLineFeed, @paragraph);

		UPDATE dbo.ScheduledEmail
		SET Content = @content
		WHERE Id = @id;
	END --IF(@startCheck = 'False')

END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP030_17.01_Create_InsertTriggerOnScheduledEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	