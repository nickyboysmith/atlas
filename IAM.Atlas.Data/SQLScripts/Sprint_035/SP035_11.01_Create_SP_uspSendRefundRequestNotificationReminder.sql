/*
	SCRIPT: Create uspSendRefundRequestNotificationReminder
	Author: Dan Hough
	Created: 20/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_11.01_Create_SP_uspSendRefundRequestNotificationReminder.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspSendRefundRequestNotificationReminder';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendRefundRequestNotificationReminder', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendRefundRequestNotificationReminder;
END		
GO
	/*
		Create uspSendRefundRequestNotificationReminder
	*/

	CREATE PROCEDURE dbo.uspSendRefundRequestNotificationReminder (@refundRequestId INT)
	AS
	BEGIN
		DECLARE @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
				, @dateCreatedTag CHAR(15) = '<!DateCreated!>'
				, @requestDateTag CHAR(15) = '<!RequestDate!>'
				, @actualPayeeNameTag CHAR(19) = '<!ActualPayeeName!>'
				, @amountTag CHAR(10) = '<!Amount!>'
				, @clientNameTag CHAR(15) = '<!Client Name!>'
				, @clientIdTag CHAR(12) = '<!ClientId!>'
				, @clientDobTag CHAR(21) = '<!ClientDateOfBirth!>'
				, @courseTypeTag CHAR(15) = '<!Course Type!>'
				, @courseRefTag CHAR(20) = '<!Course Reference!>'
				, @courseDateTag CHAR(15) = '<!Course Date!>'
				, @paymentDateTag CHAR(16) = '<!Payment Date!>'
				, @paymentNameTag CHAR(16) = '<!Payment Name!>'
				, @paymentMethodTag CHAR(18) = '<!Payment Method!>'
				, @createdByUserNameTag CHAR(24) = '<!Created By User Name!>'
				, @payRefRequestAdmin CHAR(19) = 'PayRefRequest-Admin'
				, @adminEmailContent VARCHAR(1000)
				, @organisationId INT
				, @refundRequestOrganisationName VARCHAR(320)
				, @dateCreated DATE
				, @refundRequestDate DATE
				, @refundRequestPaymentName VARCHAR(320)
				, @requestedRefundAmount MONEY
				, @requestCreatedByUserName VARCHAR(320)
				, @relatedClientId INT
				, @relatedClientName VARCHAR(640)
				, @relatedClientDob VARCHAR(40)
				, @relatedCourseType VARCHAR(200)
				, @relatedCourseReference VARCHAR(100)
				, @relatedCourseStartDate DATE
				, @relatedPaymentTransactionDate DATE
				, @relatedPaymentName VARCHAR(320)
				, @relatedPaymentMethod VARCHAR(200)
				, @atlasSystemUserId INT = dbo.udfGetSystemUserId()
				, @systemEmailAddress VARCHAR(320) = dbo.udfGetSystemEmailAddress()
				, @systemEmailFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName()
				, @adminEmailSubject VARCHAR(100)
				, @emailSendAfterDate DATETIME = GETDATE();

		SELECT @organisationId = OETM.OrganisationId
				, @adminEmailContent = OETM.Content
				, @adminEmailSubject = '** REMINDER - ' + OETM.[Subject] + ' - REMINDER **'
				, @refundRequestOrganisationName = VWRR.RefundRequestOrganisationName
				, @refundRequestDate = VWRR.RefundRequestDate
				, @dateCreated = VWRR.DateCreated
				, @refundRequestPaymentName = VWRR.RefundRequestPaymentName
				, @requestedRefundAmount = VWRR.RequestedRefundAmount
				, @requestCreatedByUserName = VWRR.RequestCreatedByUserName
				, @relatedClientName = VWRR.RelatedClientName
				, @relatedClientId = VWRR.RelatedClientId
				, @relatedClientDob = CASE WHEN VWRR.RelatedClientDateOfBirth IS NULL THEN 'Not Provided' ELSE CAST(CAST(VWRR.RelatedClientDateOfBirth AS DATE) AS VARCHAR) END
				, @relatedCourseType = VWRR.RelatedCourseType
				, @relatedCourseReference = VWRR.RelatedCourseReference
				, @relatedCourseStartDate = VWRR.RelatedCourseStartDate
				, @relatedPaymentTransactionDate = VWRR.RelatedPaymentTransactionDate
				, @relatedPaymentName = ISNULL(VWRR.RelatedPaymentName, 'Not Provided') 
				, @relatedPaymentMethod = VWRR.RelatedPaymentMethod
		FROM dbo.vwRefundRequest VWRR
		INNER JOIN dbo.OrganisationEmailTemplateMessage OETM ON VWRR.RefundRequestOrganisationId = OETM.OrganisationId
															AND OETM.[Code] = @payRefRequestAdmin
		WHERE VWRR.RefundRequestId = @refundRequestId;

		--update the admin message content with the retrieved data
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @organisationDisplayNameTag, @refundRequestOrganisationName);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @createdByUserNameTag, @requestCreatedByUserName);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @dateCreatedTag, @dateCreated);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @requestDateTag, @refundRequestDate);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @actualPayeeNameTag, @refundRequestPaymentName);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @amountTag, @requestedRefundAmount);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @clientNameTag, @relatedClientName);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @clientIdTag, @relatedClientId);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @clientDobTag, @relatedClientDob);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @courseTypeTag, @relatedCourseType);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @courseRefTag, @relatedCourseReference);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @courseDateTag, @relatedCourseStartDate);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @paymentDateTag, @relatedPaymentTransactionDate);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @paymentNameTag, @relatedPaymentName);
		SELECT @adminEmailContent = REPLACE(@adminEmailContent, @paymentMethodTag, @relatedPaymentMethod);

		PRINT @adminEmailSubject;
		PRINT @adminEmailContent;

		--Fetch all the admin email addresses then send the email
		IF (@adminEmailContent IS NOT NULL)
		BEGIN
			DECLARE @email VARCHAR(320)
					, @combinedAdminEmail VARCHAR(400); --VARCHAR400 as 'toEmailAddresses' in uspSendEmail only allows 400 char. Advised to use this.

			DECLARE adminCursor CURSOR FOR
			SELECT DISTINCT Email 
			FROM vwSystemAdminsProvidingAtlasSupport;

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
					SELECT @combinedAdminEmail = @combinedAdminEmail + ';' + @email;
				END

				FETCH NEXT FROM adminCursor
				INTO @email;
			END

			CLOSE adminCursor;
			DEALLOCATE adminCursor;

			IF(@combinedAdminEmail IS NOT NULL)
			BEGIN
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
									, @organisationId --@organisationId
									, 'False' --@blindCopyToEmailAddress
									, NULL --@PendingEmailAttachmentId
			END --If @combinedAdminEmail IS NOT NULL
		END --@adminEmailContent IS NOT NULL

		IF(@adminEmailContent IS NOT NULL)
		BEGIN
			UPDATE dbo.RefundRequest
			SET RequestSentDate = GETDATE()
			WHERE Id = @refundRequestId;
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP035_11.01_Create_SP_uspSendRefundRequestNotificationReminder.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO