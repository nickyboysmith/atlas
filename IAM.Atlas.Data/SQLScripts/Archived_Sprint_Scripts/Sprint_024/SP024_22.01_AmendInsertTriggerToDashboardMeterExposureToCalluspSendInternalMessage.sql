/*
	SCRIPT: Amend insert trigger to the DashboardMeterExposure table
	Author: Robert Newnham
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_22.01_AmendInsertTriggerToDashboardMeterExposureToCalluspSendInternalMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend insert trigger to the DashboardMeterExposure table. Call uspSendInternalMessage for every row Inserted';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DashboardMeterExposure_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_DashboardMeterExposure_INSERT];
	END
GO
	CREATE TRIGGER TRG_DashboardMeterExposure_INSERT ON DashboardMeterExposure FOR INSERT
	AS
	BEGIN
		/*
		Create an Insert Trigger on the table "DashboardMeterExposure".
		For every row inserted create a new message using SP "uspSendInternalMessage" to 
		every Organisational Administrator (table OrganisationAdminUser) User.
		The Message Title should be "New Dashboard Meter Available" and the Content should
		be "The Dashboard Meter "<Meter Title> is now available. Please use the Dashboard
		Meter Administration to set who has access.<newline><newline>Atlas Administration."
		*/
   
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @MessageTitle VARCHAR(250) = 'New Dashboard Meter Available';
		DECLARE @CreatedByUserId INT = [dbo].[udfGetSystemUserId]();
		DECLARE @MessageContent VARCHAR(1000) = '';
		DECLARE @DashboardMeterTitle VARCHAR(100) = '';
		DECLARE @OrganisationId INT;
		DECLARE @UserId INT;
		DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('GENERAL');

		DECLARE newMeterCursor CURSOR FOR 
		SELECT 
			i.[OrganisationId]
			, OAU.[UserId]
			, ('The Dashboard Meter "' + DM.[Title]
				+ '" is now avaliable. Please use the Dashboard Meter Administration to set who has access.'
				+ @NewLineChar + @NewLineChar + 'Atlas Administration.')
				AS MessageContent
		FROM inserted i
		INNER JOIN [dbo].[DashboardMeter] DM ON DM.[Id] = i.[DashboardMeterId]
		INNER JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.[OrganisationId] = i.[OrganisationId]
		INNER JOIN [dbo].[User] U ON U.[Id] = OAU.[UserId];		
		
		OPEN newMeterCursor;			   
		FETCH NEXT FROM newMeterCursor INTO @OrganisationId, 
											@UserId, 
											@MessageContent;

		WHILE @@FETCH_STATUS = 0   
		BEGIN		
			EXEC dbo.uspSendInternalMessage 
									@MessageCategoryId = @MessageCategoryId
									, @MessageTitle = @MessageTitle
									, @MessageContent = @MessageContent
									, @SendToUserId = @UserId
									, @CreatedByUserId = @CreatedByUserId
									;
				   
			FETCH NEXT FROM newMeterCursor INTO @OrganisationId, 
												@UserId, 
												@MessageContent;
		END   
		CLOSE newMeterCursor;  
		DEALLOCATE newMeterCursor;
		
	END
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_22.01_AmendInsertTriggerToDashboardMeterExposureToCalluspSendInternalMessage.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

