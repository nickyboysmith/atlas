/*
	SCRIPT: Amend uspGetDORSForceContract
	Amended: Robert Newnham
	Amended: 07/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_13.01_Amend_SP_uspGetDORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspGetDORSForceContract';
		
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
		DECLARE @ProcedureName VARCHAR(200) = 'uspGetDORSForceContract'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 		
			DECLARE @dorsSchemeIdentifier INT;
			DECLARE @regionId INT;

			SELECT @dorsSchemeIdentifier = ds.[DORSSchemeIdentifier] 
			FROM dorsscheme ds
			INNER JOIN [dbo].[DORSSchemeCourseType] dsct ON dsct.[DORSSchemeId] = ds.id
			WHERE dsct.coursetypeid = @coursetypeid;
		
			-- venue regions
			SELECT @regionId = regionId FROM venueregion vr WHERE venueid = @venueId;

			-- var dorsForceContracts
			--SELECT dfc.* /*BAD CODING*/
			SELECT dfc.[Id]
				, dfc.[DORSForceContractIdentifier]
				, dfc.[DORSForceIdentifier]
				, dfc.[DORSSchemeIdentifier]
				, dfc.[StartDate]
				, dfc.[EndDate]
				, dfc.[CourseAdminFee]
				, dfc.[DORSAccreditationIdentifier]
				, dfc.[RegionId]
			FROM [dbo].[DORSForceContract] dfc
			INNER JOIN OrganisationDORSForceContract odfc ON odfc.[DORSForceContractId] = dfc.id
			INNER JOIN Organisation o ON o.id = odfc.organisationid
			INNER JOIN CourseType ct ON ct.organisationid = o.id
			WHERE dfc.dorsschemeidentifier = @dorsSchemeIdentifier
			AND (dfc.startdate IS NULL OR (dfc.startdate < @courseStartDate))
			AND (dfc.enddate IS NULL OR (dfc.enddate > @courseStartDate))
			AND ct.id = @courseTypeId
			AND dfc.regionid = @regionId;
			
		END TRY  
		BEGIN CATCH  
			SELECT 
				@ErrorNumber = ERROR_NUMBER()
				, @ErrorSeverity = ERROR_SEVERITY()
				, @ErrorState = ERROR_STATE()
				, @ErrorProcedure = ERROR_PROCEDURE()
				, @ErrorLine = ERROR_LINE()
				, @ErrorMessage = ERROR_MESSAGE()
				;

			EXECUTE uspSaveDatabaseError @ProcedureName
										, @ErrorMessage
										, @ErrorNumber
										, @ErrorSeverity
										, @ErrorState
										, @ErrorProcedure
										, @ErrorLine
										;
		END CATCH
	END --END SP

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP045_13.01_Amend_SP_uspGetDORSForceContract.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO