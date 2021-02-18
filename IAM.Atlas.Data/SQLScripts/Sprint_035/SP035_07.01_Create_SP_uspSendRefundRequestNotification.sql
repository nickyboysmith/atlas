/*
	SCRIPT: Create uspSendRefundRequestNotification
	Author: Dan Hough
	Created: 17/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_07.01_Create_SP_uspSendRefundRequestNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspSendRefundRequestNotification';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendRefundRequestNotification', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendRefundRequestNotification;
END		
GO
	/*
		Create uspSendRefundRequestNotification
	*/

	CREATE PROCEDURE dbo.uspSendRefundRequestNotification (@refundRequestId INT)
	AS
	BEGIN
		DECLARE @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
				, @userNameTag CHAR(13) = '<!User Name!>'
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
				, @payRefRequestUser CHAR(18) = 'PayRefRequest-User'
				, @payRefRequestAdmin CHAR(19) = 'PayRefRequest-Admin'
				, @userEmailContent VARCHAR(1000)
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
				, @userEmailSubject VARCHAR(100)
				, @emailSendAfterDate DATETIME = GETDATE()
				, @requestCreatedByUserEmail VARCHAR(320);

		SELECT @organisationId = OETM.OrganisationId
				, @userEmailContent = OETM.Content
				, @userEmailSubject = OETM.[Subject]
				, @adminEmailContent = A.AdminContent
				, @adminEmailSubject = A.AdminEmailSubject
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
				, @requestCreatedByUserEmail = VWRR.RequestCreatedByUserEmail
		FROM dbo.vwRefundRequest VWRR
		INNER JOIN dbo.OrganisationEmailTemplateMessage OETM ON VWRR.RefundRequestOrganisationId = OETM.OrganisationId
		INNER JOIN (SELECT OrganisationId
							, Content AS AdminContent
							, [Subject] as AdminEmailSubject
					FROM OrganisationEmailTemplateMessage OETM2
					WHERE Code = @payRefRequestAdmin) A ON OETM.OrganisationId = A.OrganisationId
		WHERE VWRR.RefundRequestId = @refundRequestId;

		--Update the user message content with the retrieved data
		SELECT @userEmailContent = REPLACE(@userEmailContent, @organisationDisplayNameTag, @refundRequestOrganisationName);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @userNameTag, @requestCreatedByUserName);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @dateCreatedTag, @dateCreated);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @requestDateTag, @refundRequestDate);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @actualPayeeNameTag, @refundRequestPaymentName);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @amountTag, @requestedRefundAmount);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @clientNameTag, @relatedClientName);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @clientIdTag, @relatedClientId);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @clientDobTag, @relatedClientDob);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @courseTypeTag, @relatedCourseType);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @courseRefTag, @relatedCourseReference);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @courseDateTag, @relatedCourseStartDate);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @paymentDateTag, @relatedPaymentTransactionDate);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @paymentNameTag, @relatedPaymentName);
		SELECT @userEmailContent = REPLACE(@userEmailContent, @paymentMethodTag, @relatedPaymentMethod);

		IF(@userEmailContent IS NOT NULL)
			BEGIN
				EXEC dbo.uspSendEmail @atlasSystemUserId --@requestedByUserId
									, @systemEmailFromName --@fromName
									, @systemEmailAddress --@fromEmailAddresses
									, @requestCreatedByUserEmail --@toEmailAddresses
									, NULL --@ccEmailAddresses
									, NULL --@bccEmailAddresses
									, @userEmailSubject --@emailSubject
									, @userEmailContent --@emailContent
									, NULL --@asapFlag
									, @emailSendAfterDate --@sendAfterDateTime
									, NULL --@emailServiceId
									, @organisationId --@organisationId
									, 'False' --@blindCopyToEmailAddress
									, NULL --@PendingEmailAttachmentId
			END --If @userEmailContent IS NOT NULL

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

		IF((@userEmailContent IS NOT NULL) AND (@adminEmailContent IS NOT NULL))
		BEGIN
			UPDATE dbo.RefundRequest
			SET RequestSentDate = GETDATE()
			WHERE Id = @refundRequestId;
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP035_07.01_Create_SP_uspSendRefundRequestNotification.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO