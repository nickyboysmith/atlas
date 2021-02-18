/*
	SCRIPT: Create Stored procedure uspEnsureOrganisationalData
	Author: Robert Newnham
	Created: 01/02/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_30.01_Create_SP_uspEnsureOrganisationalData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspEnsureOrganisationalData';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspEnsureOrganisationalData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspEnsureOrganisationalData;
END		
GO
	/*
		Create uspEnsureOrganisationalData
	*/

	CREATE PROCEDURE dbo.uspEnsureOrganisationalData 
	AS
	BEGIN
	
		PRINT('');PRINT(' .. Organisation');
		-- Ensure Certain Columns have the Correct Default Values
		UPDATE dbo.Organisation
		SET Active = (CASE WHEN Active IS NULL THEN 'True' ELSE Active END)
		WHERE Active IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationDisplay');
		-- Ensure We have an OrganisationDisplay Row
		INSERT INTO dbo.OrganisationDisplay (OrganisationId, SystemFontId, ChangedByUserId, [Name], DisplayName, DateChanged)
		SELECT DISTINCT 
			O.Id									AS OrganisationId
			, (SELECT TOP 1 Id FROM SystemFont)		AS SystemFontId
			, dbo.udfGetSystemUserId()				AS ChangedByUserId
			, O.[Name]								AS [Name]
			, O.[Name]								AS DisplayName
			, GETDATE()								AS DateChanged
		FROM dbo.Organisation O
		LEFT JOIN dbo.OrganisationDisplay OD ON OD.OrganisationId = O.Id
		WHERE OD.Id IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationDisplay 2');
		-- Ensure Certain Columns have the Correct Default Values
		UPDATE OD
		SET OD.[Name] = (CASE WHEN OD.[Name] IS NULL THEN O.[Name] ELSE OD.[Name] END)
		, OD.DisplayName = (CASE WHEN OD.DisplayName IS NULL THEN O.[Name] ELSE OD.DisplayName END)
		, OD.HasLogo = (CASE WHEN OD.HasLogo IS NULL THEN 'False' ELSE OD.HasLogo END)
		, OD.ShowLogo = (CASE WHEN OD.ShowLogo IS NULL THEN 'False' ELSE OD.ShowLogo END)
		, OD.ShowDisplayName = (CASE WHEN OD.ShowDisplayName IS NULL THEN 'False' ELSE OD.ShowDisplayName END)
		, OD.ChangedByUserId = dbo.udfGetSystemUserId()
		, OD.DateChanged = GETDATE()
		FROM dbo.OrganisationDisplay OD
		INNER JOIN dbo.Organisation O ON O.Id = OD.OrganisationId
		WHERE OD.[Name] IS NULL
		OR OD.DisplayName IS NULL
		OR OD.HasLogo IS NULL
		OR OD.ShowLogo IS NULL
		OR OD.ShowDisplayName IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationSelfConfiguration 1');
		-- Ensure We have an OrganisationSelfConfiguration Row
		INSERT INTO dbo.OrganisationSelfConfiguration (OrganisationId)
		SELECT DISTINCT
				O.Id								AS OrganisationId
		FROM dbo.Organisation O
		LEFT JOIN dbo.OrganisationSelfConfiguration OSC ON OSC.OrganisationId = O.Id
		WHERE OSC.Id IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationSelfConfiguration 2');
		-- Ensure Certain Columns have the Correct Default Values
		UPDATE dbo.OrganisationSelfConfiguration
		SET ShowManulCarCourseRestriction = (CASE WHEN ShowManulCarCourseRestriction IS NULL THEN 'False' ELSE ShowManulCarCourseRestriction END)
		, ShowLicencePhotocardDetails = (CASE WHEN ShowLicencePhotocardDetails IS NULL THEN 'False' ELSE ShowLicencePhotocardDetails END)
		, ShowTrainerCosts = (CASE WHEN ShowTrainerCosts IS NULL THEN 'False' ELSE ShowTrainerCosts END)
		, AllowAutoEmailCourseVenuesOnCreationToBeSent = (CASE WHEN AllowAutoEmailCourseVenuesOnCreationToBeSent IS NULL THEN 'False' ELSE AllowAutoEmailCourseVenuesOnCreationToBeSent END)
		, MinutesToHoldOnlineUnpaidCourseBookings = (CASE WHEN MinutesToHoldOnlineUnpaidCourseBookings IS NULL THEN 15 ELSE MinutesToHoldOnlineUnpaidCourseBookings END)
		, MaximumMinutesToLockClientsFor = (CASE WHEN MaximumMinutesToLockClientsFor IS NULL THEN 120 ELSE MaximumMinutesToLockClientsFor END)
		, OnlineBookingCutOffDaysBeforeCourse = (CASE WHEN OnlineBookingCutOffDaysBeforeCourse IS NULL THEN 2 ELSE OnlineBookingCutOffDaysBeforeCourse END)
		, NewClientMessage = (CASE WHEN NewClientMessage IS NULL THEN 'Welcome to the Booking System' ELSE NewClientMessage END)
		, ClientWelcomeMessage = (CASE WHEN ClientWelcomeMessage IS NULL THEN 'Welcome to the Booking System' ELSE ClientWelcomeMessage END)
		, ClientApplicationDescription = (CASE WHEN ClientApplicationDescription IS NULL THEN 'Driver Booking' ELSE ClientApplicationDescription END)
		, DateUpdated = GETDATE()
		, UpdatedByUserId = dbo.udfGetSystemUserId()
		WHERE ShowManulCarCourseRestriction IS NULL
		OR ShowLicencePhotocardDetails IS NULL
		OR ShowTrainerCosts IS NULL
		OR AllowAutoEmailCourseVenuesOnCreationToBeSent IS NULL
		OR MinutesToHoldOnlineUnpaidCourseBookings IS NULL
		OR MaximumMinutesToLockClientsFor IS NULL
		OR OnlineBookingCutOffDaysBeforeCourse IS NULL
		OR NewClientMessage IS NULL
		OR ClientWelcomeMessage IS NULL
		OR ClientApplicationDescription IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationSystemConfiguration 1');
		-- Ensure We have an OrganisationSystemConfiguration Row
		INSERT INTO dbo.OrganisationSystemConfiguration (OrganisationId)
		SELECT DISTINCT O.Id AS OrganisationId
		FROM dbo.Organisation O
		LEFT JOIN dbo.OrganisationSystemConfiguration OSC ON OSC.OrganisationId = O.Id
		WHERE OSC.Id IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationSystemConfiguration 2');
		-- Ensure Certain Columns have the Correct Default Values
		UPDATE dbo.OrganisationSystemConfiguration
		SET HoursToEmailCourseVenuesAfterCreation = (CASE WHEN HoursToEmailCourseVenuesAfterCreation IS NULL THEN 24 ELSE HoursToEmailCourseVenuesAfterCreation END)
		, ArchiveSMSAfterDays = (CASE WHEN ArchiveSMSAfterDays IS NULL THEN 50 ELSE ArchiveSMSAfterDays END)
		, DeleteSMSAfterDays = (CASE WHEN DeleteSMSAfterDays IS NULL THEN 100 ELSE DeleteSMSAfterDays END)
		, ShowNetcallFeatures = (CASE WHEN ShowNetcallFeatures IS NULL THEN 'False' ELSE ShowNetcallFeatures END)
		, MinimumAdministrators = (CASE WHEN MinimumAdministrators IS NULL THEN 2 ELSE MinimumAdministrators END)
		, DateUpdated = GETDATE()
		, UpdatedByUserId = dbo.udfGetSystemUserId()
		WHERE HoursToEmailCourseVenuesAfterCreation IS NULL
		OR ArchiveSMSAfterDays IS NULL
		OR DeleteSMSAfterDays IS NULL
		OR ShowNetcallFeatures IS NULL
		OR MinimumAdministrators IS NULL
		;
		
		PRINT('');PRINT(' .. OrganisationArchiveControl');
		-- Ensure We have an OrganisationArchiveControl Row
		INSERT INTO dbo.OrganisationArchiveControl (OrganisationId, ArchiveEmailsAfterDays, ArchiveSMSsAfterDays, DeleteEmailsAfterDays, DeleteSMSsAfterDays)
		SELECT DISTINCT 
			O.Id									AS OrganisationId
			, SC.ArchiveEmailsAfterDaysDefault		AS ArchiveEmailsAfterDays
			, SC.ArchiveSMSsAfterDaysDefault		AS ArchiveSMSsAfterDays
			, SC.DeleteEmailsAfterDaysDefault		AS DeleteEmailsAfterDays
			, SC.DeleteSMSsAfterDaysDefault			AS DeleteSMSsAfterDays
		FROM dbo.Organisation O
		INNER JOIN SystemControl SC ON SC.Id = 1
		LEFT JOIN dbo.OrganisationArchiveControl OAC ON OAC.OrganisationId = O.Id
		WHERE OAC.Id IS NULL
		;
				
		PRINT('');PRINT(' .. OrganisationContact');
		-- Ensure We have an OrganisationContact Row
		INSERT INTO dbo.OrganisationContact (OrganisationId)
		SELECT DISTINCT
				O.Id								AS OrganisationId
		FROM dbo.Organisation O
		LEFT JOIN dbo.OrganisationContact OC ON OC.OrganisationId = O.Id
		WHERE OC.Id IS NULL
		;		
		
		DECLARE @stopCount INT = 0;
		DECLARE @nextOrg INT = -1;
		DECLARE @LocationId INT = -1;
		DECLARE @EmailId INT = -1;

		WHILE (EXISTS(SELECT * FROM dbo.OrganisationContact WHERE LocationId IS NULL) AND @stopCount < 1000)
		BEGIN
			SELECT TOP 1 @nextOrg=OrganisationId
			FROM dbo.OrganisationContact
			WHERE LocationId IS NULL;
			PRINT('');PRINT(' .. ' + CAST(@stopCount AS VARCHAR) + '- OrganisationContact - Dummy Loaction for: ' + CAST(@nextOrg AS VARCHAR));

			INSERT INTO [dbo].[Location] ([Address], [PostCode])
			VALUES ('(Dummy Address)', '(N0 PC)');
			SET @LocationId = SCOPE_IDENTITY();

			UPDATE dbo.OrganisationContact 
			SET LocationId = @LocationId
			WHERE OrganisationId = @nextOrg
			AND LocationId IS NULL;
			
			SET @stopCount = @stopCount + 1; --Stops Infinite Loop... Just in case :-)
		END
		
		SET @stopCount = 0;

		WHILE (EXISTS(SELECT * FROM dbo.OrganisationContact WHERE EmailId IS NULL) AND @stopCount < 1000)
		BEGIN
			SELECT TOP 1 @nextOrg=OrganisationId
			FROM dbo.OrganisationContact
			WHERE EmailId IS NULL;
			PRINT('');PRINT(' .. ' + CAST(@stopCount AS VARCHAR) + '- OrganisationContact - Dummy Email for: ' + CAST(@nextOrg AS VARCHAR));

			INSERT INTO [dbo].[Email] ([Address])
			VALUES ('(dummy@FakeEmailAddress.com)');
			SET @EmailId = SCOPE_IDENTITY();

			UPDATE dbo.OrganisationContact 
			SET EmailId = @EmailId
			WHERE OrganisationId = @nextOrg
			AND EmailId IS NULL;
			
			SET @stopCount = @stopCount + 1; --Stops Infinite Loop... Just in case :-)
		END
		
		PRINT('');PRINT(' .. OrganisationSystemTaskMessaging');
		-- Ensure We have an OrganisationSystemTaskMessaging Row
		INSERT INTO dbo.OrganisationSystemTaskMessaging (
			OrganisationId
			, SystemTaskId
			, SendMessagesViaEmail
			, SendMessagesViaInternalMessaging
			, UpdatedByUserId
			, DateUpdated
			)
		SELECT 
			O.Id AS OrganisationId
			, ST.Id AS SystemTaskId
			, 'True' AS SendMessagesViaEmail
			, 'True' AS SendMessagesViaInternalMessaging
			, dbo.udfGetSystemUserId() AS UpdatedByUserId
			, GetDate() AS DateUpdated
		FROM Organisation O, dbo.SystemTask ST
		WHERE NOT EXISTS (SELECT * 
							FROM OrganisationSystemTaskMessaging OSTM
							WHERE OSTM.OrganisationId = O.Id
							AND OSTM.SystemTaskId = ST.Id
							);

	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_30.01_Create_SP_uspEnsureOrganisationalData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

