/*
	SCRIPT: Create Stored procedure uspVenuesWithNoRegionAssigned
	Author: Paul Tuck
	Created: 19/10/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_05.01_CreateSP_uspVenuesWithNoRegionAssigned.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspVenuesWithNoRegionAssigned';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspVenuesWithNoRegionAssigned', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspVenuesWithNoRegionAssigned];
END		
GO
	/*
		Amend [uspVenuesWithNoRegionAssigned]
	*/
	
	CREATE PROCEDURE [dbo].[uspVenuesWithNoRegionAssigned]
	AS
	BEGIN
		

		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
		DECLARE @organisationId INT;
		DECLARE @venueId INT;
		DECLARE @venueTitle VARCHAR(200);
		DECLARE @EmailSubject VARCHAR(320);
		DECLARE @EmailContent VARCHAR(1000);


		SELECT TOP 1 @venueId = Venueid, @organisationId = OrganisationId, @venueTitle = VenueTitle FROM vwVenuesWithNoRegionAssigned ORDER BY venueid;

		WHILE @venueId IS NOT NULL
		BEGIN

			DECLARE @regionId INT;
			DECLARE @regionCount INT;

			select @regionCount = count(regionid) from organisationRegion 
			where organisationRegion.organisationid = @organisationId;

			IF @regionCount = 1
			BEGIN
				SELECT @regionId = regionid from organisationRegion where organisationRegion.organisationid = @organisationId;
				INSERT INTO VenueRegion (VenueId, RegionId) VALUES (@venueId, @regionId);
			END
			ELSE IF @regionCount > 1
			BEGIN
				-- check to see when the last notification was sent
				DECLARE @notificationId INT;
				SELECT @notificationId = id FROM OrganisationNotificationLog 
				WHERE 
					NotificationCode = 'VenueRegionCheck' and 
					AssociatedItemId = @venueId and
					DateSent > dateadd(week, -1, getdate())
				ORDER BY id DESC;

				-- if a notification has been a sent within the last week do nothing, otherwise...
				IF @notificationId IS NULL
				BEGIN
					SET @EmailSubject = 'Venue ' + @venueTitle + ' Not Associated to a Region';
					SET @EmailContent = 'Venue ' + @venueTitle + ' does not have the Associated Region Assigned. Please Assign the relevant Region or contact Atlas System Administration to do it for you. Use the Venue Maintenance in Administration Menu to Add the Region. ' + @NewLine + ' Best Regards ' + @NewLine + ' Atlas System.';
					EXEC uspSendEmailContentToAllOrganisationSupport @organisationId, @atlasSystemUserId, @EmailSubject, @EmailContent;
					
					-- enter the notification into OrganisationNotificationLog
					INSERT INTO OrganisationNotificationLog (NotificationCode, DateSent, AssociatedItemId) VALUES ('VenueRegionCheck', GETDATE(), @venueId);
				END
			END

			SELECT TOP 1 @venueId = Venueid, @organisationId = OrganisationId, @venueTitle = VenueTitle FROM vwVenuesWithNoRegionAssigned WHERE venueid > @venueId ORDER BY venueid;

			IF @@ROWCOUNT = 0
			BREAK

		END


	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP045_05.01_CreateSP_uspVenuesWithNoRegionAssigned.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
