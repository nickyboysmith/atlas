/*
	SCRIPT: Create udfGetDORSForceContractId
	Author: Paul Tuck
	Created: 18/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_14.01_Create_Function_udfGetDORSForceContractId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create udfGetDORSForceContractId';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetDORSForceContractId', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetDORSForceContractId;
	END		
	GO

	CREATE FUNCTION [dbo].[udfGetDORSForceContractId] (@courseTypeId INT, @venueId INT, @courseStartDate DATETIME)
	RETURNS INT
	AS
	BEGIN
		
		DECLARE @dorsSchemeIdentifier INT;
		DECLARE @regionId INT;
		DECLARE @dorsForceContractId INT;

		SELECT @dorsSchemeIdentifier = ds.[DORSSchemeIdentifier] 
		FROM dorsscheme ds
		INNER JOIN [dbo].[DORSSchemeCourseType] dsct ON dsct.[DORSSchemeId] = ds.id
		WHERE dsct.coursetypeid = @coursetypeid;
		
		-- venue regions
		SELECT @regionId = regionId FROM venueregion vr WHERE venueid = @venueId;

		-- var dorsForceContracts
		SELECT @dorsForceContractId = dfc.Id 
		FROM [dbo].[DORSForceContract] dfc
		INNER JOIN OrganisationDORSForceContract odfc ON odfc.[DORSForceContractId] = dfc.id
		INNER JOIN Organisation o ON o.id = odfc.organisationid
		INNER JOIN CourseType ct ON ct.organisationid = o.id
		WHERE dfc.dorsschemeidentifier = @dorsSchemeIdentifier
		AND (dfc.startdate IS NULL OR (dfc.startdate < @courseStartDate))
		AND (dfc.enddate IS NULL OR (dfc.enddate > @courseStartDate))
		AND ct.id = @courseTypeId
		AND dfc.regionid = @regionId;

		IF @dorsForceContractId IS NULL
		BEGIN
			SET @dorsForceContractId = -1;
		END

		RETURN @dorsForceContractId;

	END --END SP

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP043_14.01_Create_Function_udfGetDORSForceContractId.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO