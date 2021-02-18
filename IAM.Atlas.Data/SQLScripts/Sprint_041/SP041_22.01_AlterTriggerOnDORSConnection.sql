/*
	SCRIPT: Alter update trigger to only send Emails for Active Organisations
	Author: Nick Smith
	Created: 28/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_22.01_AlterTriggerOnDORSConnection.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Update trigger on DORSConnection to only send email for Active Organisations';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 
IF OBJECT_ID('dbo.TRG_DORSConnection_Update', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_DORSConnection_Update;
END

GO

CREATE TRIGGER TRG_DORSConnection_Update ON dbo.DORSConnection AFTER UPDATE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'DORSConnection', 'TRG_DORSConnection_Update', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------

		DECLARE @OrganisationName VARCHAR(320);
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);

		SELECT @OrganisationName = o.Name
		FROM Organisation o
		INNER JOIN Inserted i ON i.OrganisationId = o.Id
		INNER JOIN Deleted d ON d.Id = i.Id
		WHERE d.DateLastConnectionFailure != i.DateLastConnectionFailure AND o.Active = 'True'

		IF (@OrganisationName IS NOT NULL)
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
				DECLARE @adminEmailSubject VARCHAR(320) = 'DORS Connection Failure For Organisation: ' + @OrganisationName;
				DECLARE @adminEmailContent VARCHAR(1000) = 'DORS Connection Failure For Organisation: ' + @OrganisationName + @NewLine + 'The Connection has been disabled.';
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

		END --Change to DateLastConnectionFailure
		
	END
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP041_22.01_AlterTriggerOnDORSConnection.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

