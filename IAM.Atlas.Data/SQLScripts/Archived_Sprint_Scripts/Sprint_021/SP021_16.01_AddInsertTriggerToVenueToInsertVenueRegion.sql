/*
	SCRIPT: Add insert trigger to the Venue table
	Author: Nick Smith
	Created: 02/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_16.01_AddInsertTriggerToVenueToInsertVenueRegion.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Venue table. If Organisation has 1 Region create row in VenueRegion if does not exist.';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_VenueToInsertVenueRegion_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_VenueToInsertVenueRegion_INSERT];
		END
GO
		CREATE TRIGGER TRG_VenueToInsertVenueRegion_INSERT ON Venue FOR INSERT
AS

		IF OBJECT_ID('tempdb..#OrganisationRegionCount') IS NOT NULL
			BEGIN
			DROP TABLE #OrganisationRegionCount
		END

		SELECT i.OrganisationId AS OrganisationId 
		       ,COUNT(*) AS OrgRegCount
		INTO #OrganisationRegionCount
		FROM inserted i 
		INNER JOIN OrganisationRegion orgr ON orgr.OrganisationId = i.OrganisationId
		GROUP BY i.OrganisationId

		INSERT INTO [dbo].[VenueRegion]
           ([VenueId]
           ,[RegionId])
		SELECT
			i.Id
           ,orgr.RegionId 
		FROM
           Venue i
		   INNER JOIN OrganisationRegion orgr on i.OrganisationId = orgr.OrganisationId
		   INNER JOIN #OrganisationRegionCount orc on i.OrganisationId = orc.OrganisationId
		WHERE 
			 (orc.OrgRegCount = 1) AND 
			 NOT EXISTS 
				(SELECT *
					FROM VenueRegion vr
					WHERE (i.Id = vr.VenueId ) AND 
						(orgr.RegionId = vr.RegionId))

GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_16.01_AddInsertTriggerToVenueToInsertVenueRegion.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO