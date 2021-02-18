/*
	SCRIPT: Create uspInsertAnyMissingClientPaymentData
	Author: Robert Newnham
	Created: 04/09/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP043_06.01_Create_SP_uspInsertAnyMissingClientPaymentData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspInsertAnyMissingClientPaymentData';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspInsertAnyMissingClientPaymentData', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspInsertAnyMissingClientPaymentData;
	END		
	GO

	CREATE PROCEDURE [dbo].[uspInsertAnyMissingClientPaymentData] 
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspInsertAnyMissingClientPaymentData'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY
			INSERT INTO dbo.ClientPayment(ClientId, PaymentId, AddedByUserId)
			SELECT DISTINCT CCP.ClientId, CCP.PaymentId, CCP.AddedByUserId
			FROM CourseClientPayment CCP
			INNER JOIN Payment P				ON P.Id = CCP.PaymentId
			LEFT JOIN dbo.ClientPayment CP		ON CP.ClientId = CCP.ClientId
												AND CP.PaymentId = CCP.PaymentId
			WHERE CP.Id IS NULL
						
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
DECLARE @ScriptName VARCHAR(100) = 'SP043_06.01_Create_SP_uspInsertAnyMissingClientPaymentData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO