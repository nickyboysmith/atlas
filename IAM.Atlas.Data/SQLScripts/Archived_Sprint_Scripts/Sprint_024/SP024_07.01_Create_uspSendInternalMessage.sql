/*
	SCRIPT: Create stored procedure uspSendInternalMessage, sending of Internal System Messages
	Author: Nick Smith
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_07.01_Create_uspSendInternalMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspSendInternalMessage, sending of Internal System Messages';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSendInternalMessage', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSendInternalMessage;
END		
GO

/*
	Create uspSendInternalMessage
*/
CREATE PROCEDURE uspSendInternalMessage
(
	@MessageCategoryId INT = 1,
	@MessageTitle VARCHAR(250) = NULL,
	@MessageContent VARCHAR(1000) = NULL,
	@SendToOrganisationId INT = NULL,
	@SendToUserId INT = NULL,
	@CreatedByUserId INT = NULL,
	@Disabled BIT = 'False',
	@AllUsers BIT = 'False'
)
AS
BEGIN

	DECLARE @OutMessageTbl TABLE (Id INT);
	DECLARE @MessageId INT;


	IF (@SendToOrganisationId IS NULL AND @SendToUserId IS NULL)
		RETURN;

	IF (@MessageTitle IS NULL OR @MessageTitle = '') OR (@MessageContent IS NULL OR @MessageContent = '')
		RETURN;


	IF NOT EXISTS (SELECT Id FROM MessageCategory WHERE Id = @MessageCategoryId)
		SET @MessageCategoryId = 1;

				INSERT INTO [dbo].[Message]
				   ([Title]
				   ,[Content]
				   ,[CreatedByUserId]
				   ,[DateCreated]
				   ,[MessageCategoryId]
				   ,[Disabled]
				   ,[AllUsers])
				OUTPUT INSERTED.Id INTO @OutMessageTbl(Id)
				VALUES
				   (@MessageTitle
				   ,@MessageContent
				   ,@CreatedByUserId
				   ,GETDATE()
				   ,@MessageCategoryId
				   ,@Disabled
				   ,@AllUsers)

				SELECT TOP 1 @MessageId = Id from @OutMessageTbl

				IF (@SendToUserId IS NOT NULL)

					INSERT INTO [dbo].[MessageRecipient]
					   ([MessageId]
					   ,[UserId])
					VALUES
					   (@MessageId
					   ,@SendToUserId)

				IF (@SendToOrganisationId IS NOT NULL)

					INSERT INTO [dbo].[MessageRecipientOrganisation]
					   ([MessageId]
					   ,[OrganisationId])
					VALUES
					   (@MessageId
					   ,@SendToOrganisationId)


END
/***END OF SCRIPT***/
GO
/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP024_07.01_Create_uspSendInternalMessage.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


