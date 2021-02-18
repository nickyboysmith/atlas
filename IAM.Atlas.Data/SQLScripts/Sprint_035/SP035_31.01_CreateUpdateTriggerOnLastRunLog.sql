/*
	SCRIPT: Create an Update Trigger on the Table LastRunLog
	Author: Nick Smith
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_31.01_CreateUpdateTriggerOnLastRunLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Update trigger on LastRunLog';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_LastRunLog_Update', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_LastRunLog_Update;
END

GO

CREATE TRIGGER TRG_LastRunLog_Update ON dbo.LastRunLog AFTER UPDATE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'LastRunLog', 'TRG_LastRunLog_Update', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------

		DECLARE @ItemName VARCHAR(100);
		DECLARE @LastRunError VARCHAR(2000);
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);

		SELECT @ItemName = i.ItemName,
			   @LastRunError = i.LastRunError
		FROM Inserted i
		INNER JOIN Deleted d ON d.Id = i.Id
		WHERE d.DateLastRunError != i.DateLastRunError

		IF (@ItemName IS NOT NULL)
		BEGIN
			DECLARE @email VARCHAR(320)
			, @combinedAdminEmail VARCHAR(400) = NULL; --VARCHAR400 as 'toEmailAddresses' in uspSendEmail only allows 400 char. Advised to use this.

			DECLARE adminCursor CURSOR FOR
			SELECT DISTINCT u.Email 
			FROM SystemAdminUser sau
			INNER JOIN [User] u ON u.Id = sau.UserId

			OPEN adminCursor

			FETCH NEXT FROM adminCursor
			INTO @email;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF(@combinedAdminEmail IS NULL)
				BEGIN
					SELECT @combinedAdminEmail = @email;
				END
				ELSE
				BEGIN
					IF ((LEN(@combinedAdminEmail) + LEN(@email)) <= 400)
						SELECT @combinedAdminEmail = @combinedAdminEmail + ';' + @email;

				END

				FETCH NEXT FROM adminCursor
				INTO @email;
			END

			CLOSE adminCursor;
			DEALLOCATE adminCursor;

			IF(@combinedAdminEmail IS NOT NULL)
			BEGIN

				DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
				DECLARE @systemEmailAddress VARCHAR(320) = dbo.udfGetSystemEmailAddress();
				DECLARE @systemEmailFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName();
				DECLARE @adminEmailSubject VARCHAR(320) = 'Error on Feature: ' + @ItemName;
				DECLARE @adminEmailContent VARCHAR(1000) = 'Error on Feature: ' + @ItemName + @NewLine + 'Error: ' + @LastRunError;
				DECLARE @emailSendAfterDate DATETIME = GETDATE();

				EXEC dbo.uspSendEmail @atlasSystemUserId --@requestedByUserId
									, @systemEmailFromName --@fromName
									, @systemEmailAddress --@fromEmailAddresses
									, @combinedAdminEmail --@toEmailAddresses
									, NULL --@ccEmailAddresses
									, NULL --@bccEmailAddresses
									, @adminEmailSubject --@emailSubject
									, @adminEmailContent --@emailContent
									, NULL --@asapFlag
									, @emailSendAfterDate --@sendAfterDateTime
									, NULL --@emailServiceId
									, NULL --@organisationId
									, 'False' --@blindCopyToEmailAddress
									, NULL --@PendingEmailAttachmentId
			END --If @combinedAdminEmail IS NOT NULL
		END --Change to DateLastRunError

		
	END
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_31.01_CreateUpdateTriggerOnLastRunLog.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

