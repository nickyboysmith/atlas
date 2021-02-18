/*
	SCRIPT: Add after insert trigger on the ClientOnlineEmailChangeRequest table
	Author: Dan Hough
	Created: 24/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_34.01_AddAfterInsertTriggerOnClientOnlineEmailChangeRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add before insert trigger on the ClientOnlineEmailChangeRequest table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ClientOnlineEmailChangeRequest_AfterInsert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_AfterInsert;
		END
GO
		CREATE TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_AfterInsert ON dbo.ClientOnlineEmailChangeRequest AFTER INSERT
AS

BEGIN

	DECLARE @organisationId INT
		  , @clientName VARCHAR(640)
		  , @newEmailAddress VARCHAR(320)
		  , @previousEmailAddress VARCHAR(320)
		  , @confirmationCode VARCHAR(40)
		  , @organisationName VARCHAR(320)
		  , @emailContent VARCHAR(1000)
		  , @emailSubject VARCHAR(100)
		  , @fromName VARCHAR(320)
		  , @fromEmail VARCHAR(320)
		  , @requestedByUserId INT
		  , @emailCode CHAR(20) = 'ClientEmailChangeReq'
		  , @clientNameTag CHAR(15) = '<!Client Name!>'
		  , @previousEmailTag CHAR(18) = '<!Previous Email!>'
		  , @newEmailTag CHAR(13) = '<!New Email!>'
		  , @changeRequestCodeTag CHAR(23) = '<!Change Request Code!>'
		  , @organisationNameTag CHAR(29) = '<!Organisation Display Name!>';

	SELECT @organisationId = i.ClientOrganisationId
		 , @clientName = i.ClientName
		 , @newEmailAddress = i.NewEmailAddress
		 , @previousEmailAddress = i.PreviousEmailAddress
		 , @confirmationCode = i.ConfirmationCode
		 , @requestedByUserId = i.RequestedByUserId
		 , @organisationName = od.[Name]
		 , @fromName = osc.FromName
		 , @fromEmail = osc.FromEmail
	FROM Inserted i
	LEFT JOIN dbo.OrganisationDisplay od ON i.ClientOrganisationId = od.OrganisationId
	LEFT JOIN dbo.OrganisationSystemConfiguration osc ON i.ClientOrganisationId = osc.OrganisationId;

	SELECT @emailContent = Content
		,  @emailSubject = [Subject]
	FROM dbo.OrganisationEmailTemplateMessage
	WHERE OrganisationId = @OrganisationId AND Code = @emailCode;

	SET @emailContent = REPLACE(@emailContent, @clientNameTag, @clientName); --replace tag with client name
	SET @emailContent = REPLACE(@emailContent, @previousEmailTag, @previousEmailAddress); --replace tag with old email address
	SET @emailContent = REPLACE(@emailContent, @newEmailTag, @newEmailAddress); --replace tag with new email address
	SET @emailContent = REPLACE(@emailContent, @changeRequestCodeTag, @confirmationCode); --replace tag with confirmation code
	SET @emailContent = REPLACE(@emailContent, @organisationNameTag, @organisationName); --replace tag with organisation display name

	INSERT INTO dbo.ClientOnlineEmailChangeRequestHistory(DateRequested
														, RequestedByUserId
														, ClientId
														, ClientOrganisationId
														, NewEmailAddress
														, PreviousEmailAddress
														, ClientName
														, ConfirmationCode
														, DateConfirmed)

												  SELECT  DateRequested
														, RequestedByUserId
														, ClientId
														, ClientOrganisationId
														, NewEmailAddress
														, PreviousEmailAddress
														, ClientName
														, ConfirmationCode
														, DateConfirmed

													FROM Inserted;

		EXEC dbo.uspSendEmail @requestedByUserId --int
							, @fromName --@fromName varchar(400) = null
							, @fromEmail --@fromEmailAddresses varchar(400)
							, @newEmailAddress --@toEmailAddresses varchar(400)
							, NULL --@ccEmailAddresses varchar(400)
							, NULL --@bccEmailAddresses varchar(400) 
							, @emailSubject -- @emailSubject varchar(320)
							, @emailContent --@emailContent varchar(4000)
							, 'True' --@asapFlag
							, NULL --@sendAfterDateTime DateTime = null
							, NULL --@emailServiceId int = null
							, @organisationId; --@organisationId int = null)	
	
END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP029_34.01_AddAfterInsertTriggerOnClientOnlineEmailChangeRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO	