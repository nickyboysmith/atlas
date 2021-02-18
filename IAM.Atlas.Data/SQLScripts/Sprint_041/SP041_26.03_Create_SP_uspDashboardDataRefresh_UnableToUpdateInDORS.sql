/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_UnableToUpdateInDORS
	Author: Nick Smith
	Created: 02/08/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_26.03_Create_SP_uspDashboardDataRefresh_UnableToUpdateInDORS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_UnableToUpdateInDORS';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_UnableToUpdateInDORS', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_UnableToUpdateInDORS;
END		
GO
	/*
		Create uspDashboardDataRefresh_UnableToUpdateInDORS
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_UnableToUpdateInDORS] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_UnableToUpdateInDORS'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_UnableToUpdateInDORS TABLE (
																		[OrganisationId] [int]
																		, [OrganisationName] [varchar](320)
																		, [TotalClientsUnableToUpdateInDORS] [int]
																		, [DateAndTimeRefreshed] [datetime]
																		);
			INSERT INTO @TempDashboardMeterData_UnableToUpdateInDORS(
																		OrganisationId
																		, OrganisationName
																		, TotalClientsUnableToUpdateInDORS
																		, DateAndTimeRefreshed
																		)
			SELECT  
				O.[Id]										As OrganisationId
				, O.[Name]									AS OrganisationName
				, COUNT(CL.Id)								AS TotalClientsUnableToUpdateInDORS
				, GETDATE()									AS DateAndTimeRefreshed
			FROM CourseDORSClient CDC
			INNER JOIN Client CL ON CL.Id = CDC.ClientId
			INNER JOIN Course C ON C.Id = CDC.CourseId
			INNER JOIN Organisation O ON O.Id = C.OrganisationId
			WHERE ISNULL(CDC.DORSNotified, 'false') = 'false' 
					AND (CDC.DateAdded IS NULL
					OR GetDate() > DateAdd(Hour, 1,  CDC.DateAdded))
			GROUP BY O.[Id], O.[Name];


			INSERT INTO dbo.DashboardMeterData_UnableToUpdateInDORS(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalClientsUnableToUpdateInDORS
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.TotalClientsUnableToUpdateInDORS
			FROM @TempDashboardMeterData_UnableToUpdateInDORS D
			LEFT JOIN DashboardMeterData_UnableToUpdateInDORS T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalClientsUnableToUpdateInDORS = D.TotalClientsUnableToUpdateInDORS
			FROM @TempDashboardMeterData_UnableToUpdateInDORS D
			INNER JOIN DashboardMeterData_UnableToUpdateInDORS T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_UnableToUpdateInDORS T
			LEFT JOIN @TempDashboardMeterData_UnableToUpdateInDORS D ON D.OrganisationId = T.OrganisationId
			WHERE D.OrganisationId IS NULL --Not Found
			;
			
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
		END CATCH;   

		/*****************************************************************************************************************************/
	END
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_26.03_Create_SP_uspDashboardDataRefresh_UnableToUpdateInDORS.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
