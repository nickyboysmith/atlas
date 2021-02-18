/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_Course
	Author: Robert Newnham
	Created: 17/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.02_Create_SP_uspDashboardDataRefresh_Course.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_Course';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_Course', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_Course;
END		
GO
	/*
		Create uspDashboardDataRefresh_Course
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_Course] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_Course'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 

			DECLARE @TempDashboardMeterData_Course TABLE (
															[OrganisationId] [int]
															, [OrganisationName] [varchar](320)
															, [CoursesWithoutAttendance] [int]
															, [CoursesWithoutAttendanceVerfication] [int]
															, [TotalAmountUnpaid] [money]
															, [NumberOfUnpaidCourses] [int]
															, [DateAndTimeRefreshed] [datetime]
															);

			INSERT INTO @TempDashboardMeterData_Course(
														OrganisationId
														, OrganisationName
														, CoursesWithoutAttendance
														, CoursesWithoutAttendanceVerfication
														, TotalAmountUnpaid
														, NumberOfUnpaidCourses
														, DateAndTimeRefreshed
														)
			SELECT 
				O.[Id] As OrganisationId
				, O.[Name] AS OrganisationName
				, ISNULL(CourseAttendance.CoursesWithoutAttendance,0) AS CoursesWithoutAttendance
				, ISNULL(CourseAttendanceVerfication.CoursesWithoutAttendanceVerfication,0) AS CoursesWithoutAttendanceVerfication
				, ISNULL(UBC.TotalAmountUnpaid,0) AS TotalAmountUnpaid	
				, ISNULL(UBC.TotalNumberUnpaid,0) AS NumberOfUnpaidCourses
				, GETDATE() AS DateAndTimeRefreshed
			FROM [dbo].[Organisation] O
			LEFT JOIN (SELECT O2.Id
							, COUNT(*) AS CoursesWithoutAttendance
						FROM [dbo].[Organisation] O2
						INNER JOIN [dbo].[Course] C ON C.[OrganisationId] = O2.[Id]
						INNER JOIN [dbo].[CourseDate] CD ON CD.CourseId = C.Id
						INNER JOIN [dbo].[CourseTrainer] CT ON CT.CourseId = C.Id
						WHERE C.AttendanceCheckRequired = 'True'
						AND C.AttendanceCheckVerified = 'False'
						AND CT.AttendanceCheckRequired = 'True'
						AND CD.DateEnd <= GetDate()
						AND NOT EXISTS (SELECT [Id] 
										FROM [dbo].[CourseDateClientAttendance] CDCA
										WHERE CDCA.[CourseId] = C.[Id]
										AND CDCA.TrainerId = CT.Id)
						GROUP BY O2.[Id]
						) CourseAttendance ON CourseAttendance.[Id] = O.[Id]
			LEFT JOIN (SELECT O3.Id
							, COUNT(DISTINCT C3.Id) AS CoursesWithoutAttendanceVerfication
						FROM [dbo].[Organisation] O3
						INNER JOIN [dbo].[Course] C3 ON C3.[OrganisationId] = O3.[Id]
						INNER JOIN [dbo].[CourseDate] CD3 ON CD3.CourseId = C3.Id
						INNER JOIN [dbo].[CourseTrainer] CT3 ON CT3.CourseId = C3.Id
						WHERE C3.AttendanceCheckRequired = 'True'
						AND C3.AttendanceCheckVerified = 'False'
						AND CD3.DateEnd <= GetDate()
						GROUP BY O3.[Id]
						) CourseAttendanceVerfication ON CourseAttendanceVerfication.[Id] = O.[Id]
			LEFT JOIN vwDashboardMeter_UnpaidBookedCourses UBC ON UBC.OrganisationId = O.[Id]
			;
			
			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_Course(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, CoursesWithoutAttendance
				, CoursesWithoutAttendanceVerfication
				, NumberOfUnpaidCourses
				, TotalAmountUnpaid
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, D.CoursesWithoutAttendance
				, D.CoursesWithoutAttendanceVerfication
				, D.NumberOfUnpaidCourses
				, D.TotalAmountUnpaid
			FROM @TempDashboardMeterData_Course D
			LEFT JOIN DashboardMeterData_Course T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.CoursesWithoutAttendance = D.CoursesWithoutAttendance
				, T.CoursesWithoutAttendanceVerfication = D.CoursesWithoutAttendanceVerfication
				, T.NumberOfUnpaidCourses = D.NumberOfUnpaidCourses
				, T.TotalAmountUnpaid = D.TotalAmountUnpaid
			FROM @TempDashboardMeterData_Course D
			INNER JOIN DashboardMeterData_Course T ON T.OrganisationId = D.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.02_Create_SP_uspDashboardDataRefresh_Course.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
