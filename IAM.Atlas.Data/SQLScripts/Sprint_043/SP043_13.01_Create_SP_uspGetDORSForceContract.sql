/*
	SCRIPT: Create uspGetDORSForceContract
	Author: Paul Tuck
	Created: 13/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_13.01_Create_SP_uspGetDORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspGetDORSForceContract';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspGetDORSForceContract', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetDORSForceContract;
	END		
	GO

	CREATE PROCEDURE [dbo].[uspGetDORSForceContract] (@courseTypeId INT, @venueId INT, @courseStartDate DATETIME)
	AS
	BEGIN
		
		DECLARE @dorsSchemeIdentifier INT;
		DECLARE @regionId INT;

		SELECT @dorsSchemeIdentifier = ds.[DORSSchemeIdentifier] 
		FROM dorsscheme ds
		INNER JOIN [dbo].[DORSSchemeCourseType] dsct ON dsct.[DORSSchemeId] = ds.id
		WHERE dsct.coursetypeid = @coursetypeid;
		
		-- venue regions
		SELECT @regionId = regionId FROM venueregion vr WHERE venueid = @venueId;

		-- var dorsForceContracts
		SELECT dfc.* 
		FROM [dbo].[DORSForceContract] dfc
		INNER JOIN OrganisationDORSForceContract odfc ON odfc.[DORSForceContractId] = dfc.id
		INNER JOIN Organisation o ON o.id = odfc.organisationid
		INNER JOIN CourseType ct ON ct.organisationid = o.id
		WHERE dfc.dorsschemeidentifier = @dorsSchemeIdentifier
		AND (dfc.startdate IS NULL OR (dfc.startdate < @courseStartDate))
		AND (dfc.enddate IS NULL OR (dfc.enddate > @courseStartDate))
		AND ct.id = @courseTypeId
		AND dfc.regionid = @regionId;

	END --END SP

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP043_13.01_Create_SP_uspGetDORSForceContract.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO