/*
	SCRIPT: Create Stored procedure uspSavePaymentErrorInformation
	Author: Robert Newnham
	Created: 25/08/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_21.01_Create_SP_uspSavePaymentErrorInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspSavePaymentErrorInformation';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSavePaymentErrorInformation', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspSavePaymentErrorInformation];
END		
GO

	/*
		Create [uspSavePaymentErrorInformation]
	*/
	
	CREATE PROCEDURE [dbo].[uspSavePaymentErrorInformation] (
		@orgId INT = NULL
		, @eventUserId INT = NULL
		, @clientId INT = NULL
		, @courseId INT = NULL
		, @paymentAmount MONEY = NULL
		, @paymentName VARCHAR(320) = ''
		, @paymentProvider VARCHAR(1000) = ''
		, @paymentProviderResponseInf VARCHAR(2000) = ''
		, @otherInf VARCHAR(1000) = ''
		)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspSavePaymentErrorInformation'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY 	
			INSERT INTO [dbo].[PaymentErrorInformation] (
				EventDateTime
				, OrganisationId
				, EventUserId
				, ClientId
				, CourseId
				, PaymentAmount
				, PaymentName
				, PaymentProvider
				, PaymentProviderResponseInformation
				, OtherInformation
				)
			VALUES (
				GETDATE()
				, @orgId
				, @eventUserId
				, @clientId
				, @courseId
				, @paymentAmount
				, @paymentName
				, @paymentProvider
				, @paymentProviderResponseInf
				, @otherInf
				)
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
	END --End SP
	GO

	
DECLARE @ScriptName VARCHAR(100) = 'SP042_21.01_Create_SP_uspSavePaymentErrorInformation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
