/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_AttendanceNotUploadedToDORS
	Author: Nick Smith
	Created: 10/08/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_33.03_Create_SP_uspDashboardDataRefresh_AttendanceNotUploadedToDORS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_AttendanceNotUploadedToDORS';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_AttendanceNotUploadedToDORS', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_AttendanceNotUploadedToDORS;
END		
GO
	/*
		Create uspDashboardDataRefresh_AttendanceNotUploadedToDORS
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_AttendanceNotUploadedToDORS] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_AttendanceNotUploadedToDORS'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 
			DECLARE @TempDashboardMeterData_AttendanceNotUploadedToDORS TABLE (
																			[OrganisationId] [int]
																			, [OrganisationName] [varchar](320)
																			, [TotalAttendanceNotUploadedToDORS] [int]
																			, [DateAndTimeRefreshed] [datetime]
																			);
			INSERT INTO @TempDashboardMeterData_AttendanceNotUploadedToDORS(
																			OrganisationId
																			, OrganisationName
																			, TotalAttendanceNotUploadedToDORS
																			, DateAndTimeRefreshed
																			)
			SELECT 
				T.OrganisationId As OrganisationId
				,T.OrganisationName AS OrganisationName
				, COUNT(*) AS TotalAttendanceNotUploadedToDORS
				, GETDATE()	AS DateAndTimeRefreshed
			FROM (
				SELECT DISTINCT
					O.[Id]										As OrganisationId
					, O.[Name]									AS OrganisationName
					, CL.Id										AS ClientId
					, C.Id										AS CourseId
				FROM DORSClientCourseAttendanceLog DCCAL
				INNER JOIN ClientDORSData CDD ON CDD.DORSAttendanceRef = DCCAL.DORSClientIdentifier
				INNER JOIN DORSCourse DC ON DC.DORSCourseIdentifier = DCCAL.DORSCourseIdentifier
				INNER JOIN CourseClient CC ON CC.ClientId = CDD.ClientId and CC.CourseId = DC.CourseId
				INNER JOIN Client CL ON CL.Id = CDD.ClientId
				INNER JOIN Course C ON C.Id = DC.CourseId
				INNER JOIN Organisation O ON O.Id = C.OrganisationId
				WHERE ISNULL(DCCAL.DORSNotified, 'false') = 'false' 
						AND (DCCAL.DateCreated IS NULL
						OR GetDate() > DateAdd(Hour, 1,  DCCAL.DateCreated))
			) As T
			GROUP BY T.OrganisationId, T.OrganisationName
			;


			INSERT INTO dbo.DashboardMeterData_AttendanceNotUploadedToDORS(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalAttendanceNotUploadedToDORS
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.TotalAttendanceNotUploadedToDORS
			FROM @TempDashboardMeterData_AttendanceNotUploadedToDORS D
			LEFT JOIN DashboardMeterData_AttendanceNotUploadedToDORS T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalAttendanceNotUploadedToDORS = D.TotalAttendanceNotUploadedToDORS
			FROM @TempDashboardMeterData_AttendanceNotUploadedToDORS D
			INNER JOIN DashboardMeterData_AttendanceNotUploadedToDORS T ON T.OrganisationId = D.OrganisationId
			;
			
			--Delete Unwanted
			DELETE T
			FROM DashboardMeterData_AttendanceNotUploadedToDORS T
			LEFT JOIN @TempDashboardMeterData_AttendanceNotUploadedToDORS D ON D.OrganisationId = T.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP041_33.03_Create_SP_uspDashboardDataRefresh_AttendanceNotUploadedToDORS.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
