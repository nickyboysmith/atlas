/*
	SCRIPT: Create Stored procedure uspDashboardDataRefresh_DocumentStat
	Author: Robert Newnham
	Created: 17/07/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_40.03_Create_SP_uspDashboardDataRefresh_DocumentStat.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspDashboardDataRefresh_DocumentStat';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDashboardDataRefresh_DocumentStat', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDashboardDataRefresh_DocumentStat;
END		
GO
	/*
		Create uspDashboardDataRefresh_DocumentStat
	*/
	
	CREATE PROCEDURE [dbo].[uspDashboardDataRefresh_DocumentStat] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDashboardDataRefresh_DocumentStat'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY
			DECLARE @TempDashboardMeterData_DocumentStat TABLE (
																[OrganisationId] [int]
																, [OrganisationName] [varchar](320)
																, [NumberOfDocuments] [bigint]
																, [TotalSize] [bigint]
																, [NumberOfDocumentsThisMonth] [bigint]
																, [TotalSizeOfDocumentsThisMonth] [bigint]
																, [NumberOfDocumentsPreviousMonth] [bigint]
																, [TotalSizeOfDocumentsPreviousMonth] [bigint]
																, [NumberOfDocumentsThisYear] [bigint]
																, [TotalSizeOfDocumentsThisYear] [bigint]
																, [NumberOfDocumentsPreviousYear] [bigint]
																, [TotalSizeOfDocumentsPreviousYear] [bigint]
																, [NumberOfDocumentsPreviousTwoYears] [bigint]
																, [TotalSizeOfDocumentsPreviousTwoYears] [bigint]
																, [NumberOfDocumentsPreviousThreeYears] [bigint]
																, [TotalSizeOfDocumentsPreviousThreeYears] [bigint]
																, [DateAndTimeRefreshed] [datetime]
																);
			
			INSERT INTO @TempDashboardMeterData_DocumentStat(
															OrganisationId
															, OrganisationName
															, NumberOfDocuments
															, TotalSize
															, NumberOfDocumentsThisMonth
															, TotalSizeOfDocumentsThisMonth
															, NumberOfDocumentsPreviousMonth
															, TotalSizeOfDocumentsPreviousMonth
															, NumberOfDocumentsThisYear
															, TotalSizeOfDocumentsThisYear
															, NumberOfDocumentsPreviousYear
															, TotalSizeOfDocumentsPreviousYear
															, NumberOfDocumentsPreviousTwoYears
															, TotalSizeOfDocumentsPreviousTwoYears
															, NumberOfDocumentsPreviousThreeYears
															, TotalSizeOfDocumentsPreviousThreeYears
															, DateAndTimeRefreshed
															)
			SELECT 
				ISNULL(OrganisationId,0) AS OrganisationId
				, O.[Name] AS OrganisationName
				, NumberOfDocuments
				, TotalSize
				, NumberOfDocumentsThisMonth
				, TotalSizeOfDocumentsThisMonth
				, NumberOfDocumentsPreviousMonth
				, TotalSizeOfDocumentsPreviousMonth
				, NumberOfDocumentsThisYear
				, TotalSizeOfDocumentsThisYear
				, NumberOfDocumentsPreviousYear
				, TotalSizeOfDocumentsPreviousYear
				, NumberOfDocumentsPreviousTwoYears
				, TotalSizeOfDocumentsPreviousTwoYears
				, NumberOfDocumentsPreviousThreeYears
				, TotalSizeOfDocumentsPreviousThreeYears
				, GETDATE() AS DateAndTimeRefreshed
			FROM dbo.Organisation O
			INNER JOIN dbo.DashboardMeter_DocumentSummary DS ON DS.OrganisationId = O.Id
			;
			
			--Insert New Rows
			INSERT INTO dbo.DashboardMeterData_DocumentStat(
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalSize
				, NumberOfDocumentsThisMonth
				, TotalSizeOfDocumentsThisMonth
				, NumberOfDocumentsPreviousMonth
				, TotalSizeOfDocumentsPreviousMonth
				, NumberOfDocumentsThisYear
				, TotalSizeOfDocumentsThisYear
				, NumberOfDocumentsPreviousYear
				, TotalSizeOfDocumentsPreviousYear
				, NumberOfDocumentsPreviousTwoYears
				, TotalSizeOfDocumentsPreviousTwoYears
				, NumberOfDocumentsPreviousThreeYears
				, TotalSizeOfDocumentsPreviousThreeYears
			)
			SELECT 
				D.OrganisationId
				, D.OrganisationName
				, D.DateAndTimeRefreshed
				, ISNULL(D.TotalSize,0) AS TotalSize
				, D.NumberOfDocumentsThisMonth
				, D.TotalSizeOfDocumentsThisMonth
				, D.NumberOfDocumentsPreviousMonth
				, D.TotalSizeOfDocumentsPreviousMonth
				, D.NumberOfDocumentsThisYear
				, D.TotalSizeOfDocumentsThisYear
				, D.NumberOfDocumentsPreviousYear
				, D.TotalSizeOfDocumentsPreviousYear
				, D.NumberOfDocumentsPreviousTwoYears
				, ISNULL(D.TotalSizeOfDocumentsPreviousTwoYears,0) AS TotalSizeOfDocumentsPreviousTwoYears
				, D.NumberOfDocumentsPreviousThreeYears
				, D.TotalSizeOfDocumentsPreviousThreeYears
			FROM @TempDashboardMeterData_DocumentStat D
			LEFT JOIN DashboardMeterData_DocumentStat T ON T.OrganisationId = D.OrganisationId
			WHERE T.Id IS NULL;


			--Update Existing
			UPDATE T
			SET
				T.OrganisationId = D.OrganisationId
				, T.OrganisationName = D.OrganisationName
				, T.DateAndTimeRefreshed = D.DateAndTimeRefreshed
				, T.TotalSize = ISNULL(D.TotalSize,0)
				, T.NumberOfDocumentsThisMonth = D.NumberOfDocumentsThisMonth
				, T.TotalSizeOfDocumentsThisMonth = D.TotalSizeOfDocumentsThisMonth
				, T.NumberOfDocumentsPreviousMonth = D.NumberOfDocumentsPreviousMonth
				, T.TotalSizeOfDocumentsPreviousMonth = D.TotalSizeOfDocumentsPreviousMonth
				, T.NumberOfDocumentsThisYear = D.NumberOfDocumentsThisYear
				, T.TotalSizeOfDocumentsThisYear = D.TotalSizeOfDocumentsThisYear
				, T.NumberOfDocumentsPreviousYear = D.NumberOfDocumentsPreviousYear
				, T.TotalSizeOfDocumentsPreviousYear = D.TotalSizeOfDocumentsPreviousYear
				, T.NumberOfDocumentsPreviousTwoYears = D.NumberOfDocumentsPreviousTwoYears
				, T.TotalSizeOfDocumentsPreviousTwoYears = ISNULL(D.TotalSizeOfDocumentsPreviousTwoYears,0)
				, T.NumberOfDocumentsPreviousThreeYears = D.NumberOfDocumentsPreviousThreeYears
				, T.TotalSizeOfDocumentsPreviousThreeYears = D.TotalSizeOfDocumentsPreviousThreeYears
			FROM @TempDashboardMeterData_DocumentStat D
			INNER JOIN DashboardMeterData_DocumentStat T ON T.OrganisationId = D.OrganisationId
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP040_40.03_Create_SP_uspDashboardDataRefresh_DocumentStat.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
