/*
	SCRIPT: Create uspDatabaseTidyUpProcess
	Author: Robert Newnham
	Created: 27/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_25.01_Amend_SP_uspDatabaseTidyUpProcess.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspDatabaseTidyUpProcess';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspDatabaseTidyUpProcess', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspDatabaseTidyUpProcess;
	END		
	GO

	CREATE PROCEDURE [dbo].[uspDatabaseTidyUpProcess] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspDatabaseTidyUpProcess'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 	
			--Tidy Up Seach History List. Remove any older than 1 week
			IF OBJECT_ID('tempdb..#SHistId', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SHistId;
			END
		
			/*****************************************************************************************************************/
			--Delete Old Search History Saves
			SELECT SHIN.Id AS ShinId, SHU.Id AS ShuId, SHI.Id AS ShiId
			INTO #SHistId
			FROM [dbo].[SearchHistoryItem] SHI
			INNER JOIN [dbo].[SearchHistoryUser] SHU ON SHU.Id = SHI.SearchHistoryUserId
			INNER JOIN [dbo].[SearchHistoryInterface] SHIN ON SHIN.Id = SHU.SearchHistoryInterfaceId
			WHERE SHU.CreationDate < DATEADD(WEEK, -1, GETDATE());

			DELETE SHI 
			FROM [dbo].[SearchHistoryItem] SHI
			WHERE SHI.Id IN (SELECT DISTINCT ShiId FROM #SHistId);
		
			DELETE SHU 
			FROM [dbo].[SearchHistoryUser] SHU
			WHERE SHU.Id IN (SELECT DISTINCT ShuId FROM #SHistId);
		
			DELETE SHIN 
			FROM [dbo].[SearchHistoryInterface] SHIN
			WHERE SHIN.Id IN (SELECT DISTINCT ShinId FROM #SHistId);
		
			IF OBJECT_ID('tempdb..#SHistId', 'U') IS NOT NULL
			BEGIN
				DROP TABLE #SHistId;
			END
			/*****************************************************************************************************************/
			--Delete Old Report Requests
			DECLARE @DeletAfterDays INT = 35;

			DELETE RQR
			FROM [dbo].[ReportRequest] RR
			INNER JOIN [dbo].[ReportQueueRequest] RQR ON RQR.[ReportRequestId] = RR.Id
			INNER JOIN [dbo].[ReportQueue] RQ ON RQ.Id = RQR.[ReportQueueId]
			WHERE RR.DateCreated < DATEADD(DAY, (@DeletAfterDays * -1), GETDATE());

			--Now Delete the ReportQueue with no ReportQueueRequestRQ
			DELETE RQ
			FROM [dbo].[ReportQueue] RQ
			LEFT JOIN [dbo].[ReportQueueRequest] RQR ON RQR.[ReportQueueId] = RQ.Id
			WHERE RQR.Id IS NULL;

			DELETE RRP
			FROM [dbo].[ReportRequestParameter] RRP
			INNER JOIN [dbo].[ReportRequest] RR ON RRP.ReportRequestId = RR.Id
			WHERE RR.DateCreated < DATEADD(DAY, (@DeletAfterDays * -1), GETDATE());

			DELETE RR
			FROM [dbo].[ReportRequest] RR
			WHERE RR.DateCreated < DATEADD(DAY, (@DeletAfterDays * -1), GETDATE());
			/******************************************************************************************************/
			--Delete Old Payment Failure Error Information
			DECLARE @DeletePaymentFailuresAfterDays INT = 366;
			DELETE PEI
			FROM dbo.PaymentErrorInformation PEI
			WHERE PEI.[EventDateTime] < DATEADD(DAY, (@DeletePaymentFailuresAfterDays * -1), GETDATE());
			/******************************************************************************************************/			
			--Delete Old System Trapped Error Information
			DECLARE @DeleteSystemTrappedErrorInformationAfterDays INT = 366;
			DELETE STE
			FROM [dbo].[SystemTrappedError] STE
			WHERE STE.DateRecorded < DATEADD(DAY, (@DeleteSystemTrappedErrorInformationAfterDays * -1), GETDATE());
			/******************************************************************************************************/						
			--Delete Old Database Error Information
			DECLARE @DeleteDatabaseErrorLogsAfterDays INT = 366;
			DELETE DEL
			FROM [dbo].[DatabaseErrorLog] DEL
			WHERE DEL.DateAndTimeRecorded < DATEADD(DAY, (@DeleteDatabaseErrorLogsAfterDays * -1), GETDATE());
			/******************************************************************************************************/
			/******************************************************************************************************/
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
DECLARE @ScriptName VARCHAR(100) = 'SP042_25.01_Amend_SP_uspDatabaseTidyUpProcess.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO