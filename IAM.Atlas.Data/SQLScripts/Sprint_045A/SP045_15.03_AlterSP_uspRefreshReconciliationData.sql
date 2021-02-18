/*
	SCRIPT: Alter Stored procedure uspRefreshReconciliationData
	Author: Paul Tuck
	Created: 09/11/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_15.03_AlterSP_uspRefreshReconciliationData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspRefreshReconciliationData';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments;
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspRefreshReconciliationData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.[uspRefreshReconciliationData];
END		
GO

	/*
		Create [uspRefreshReconciliationData]
	*/
	
	CREATE PROCEDURE [dbo].[uspRefreshReconciliationData] (@ReconciliationId INT)
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspRefreshReconciliationData'
			, @ErrorMessage VARCHAR(4000) = ''
			, @ErrorNumber INT = NULL
			, @ErrorSeverity INT = NULL
			, @ErrorState INT = NULL
			, @ErrorProcedure VARCHAR(140) = NULL
			, @ErrorLine INT = NULL;
			
		/*****************************************************************************************************************************/
			
		BEGIN TRY
			DECLARE @paymentId INT = NULL;
			DECLARE @paymentStartDate DATETIME;
			DECLARE @paymentEndDate DATETIME;
			DECLARE @paymentTransactionDate DATETIME;
			DECLARE @paymentAmount MONEY;
			DECLARE @paymentAuthCode VARCHAR(100); 
			DECLARE @paymentReceiptNumber VARCHAR(100);

			-- Clear the existing data to be ready for the new reconciliation
			DELETE FROM ReconciliationData 
			WHERE ReconciliationId = @ReconciliationId 
			AND	ReconciliationTransactionDate IS NULL
			AND	ReconciliationTransactionAmount IS NULL;

			UPDATE ReconciliationData
			SET PaymentId = NULL, 
				PaymentTransactionDate = NULL, 
				PaymentAmount = NULL, 
				PaymentAuthCode = NULL, 
				ReceiptNumber = NULL, 
				Duplicate = 'False'
			WHERE ReconciliationId = @ReconciliationId;

			SELECT @paymentStartDate = paymentStartDate, @paymentEndDate = paymentEndDate
			FROM Reconciliation
			WHERE Id = @ReconciliationId;
		
			-- Traverse all the reconciliationData for this reconciliationId
			DECLARE @reconciliationDataId INT = NULL;

			SELECT TOP 1 @reconciliationDataId = Id from ReconciliationData WHERE ReconciliationId = @ReconciliationId ORDER BY Id ASC;

			WHILE @reconciliationDataId IS NOT NULL
			BEGIN
				-- reset the payment parameters
				SET @paymentId = NULL;
				SET @paymentTransactionDate = NULL;
				SET @paymentAmount = NULL;
				SET @paymentAuthCode = NULL; 
				SET @paymentReceiptNumber = NULL;

				-- find the corresponding payment for this reconciliationData entry
				SELECT 
					@paymentId = p.Id,
					@paymentTransactionDate = p.TransactionDate, 
					@paymentAmount = p.amount, 
					@paymentAuthCode = p.authCode,
					@paymentReceiptNumber = p.receiptNumber
				FROM payment p
				INNER JOIN 
					reconciliationData rd 
					ON 
						p.amount = rd.ReconciliationTransactionAmount AND 
						p.transactionDate = rd.ReconciliationTransactionDate AND
						(
							(
								p.authCode = rd.ReconciliationReference1
								OR
								p.authCode = rd.ReconciliationReference2
								OR
								p.authCode = rd.ReconciliationReference3
							)
							OR
							(
								p.receiptNumber = rd.ReconciliationReference1
								OR
								p.receiptNumber = rd.ReconciliationReference2
								OR
								p.receiptNumber = rd.ReconciliationReference3
							)
						)
				WHERE rd.Id = @reconciliationDataId;

				IF @paymentId IS NOT NULL
				BEGIN
					UPDATE ReconciliationData
					SET
						PaymentId = @paymentId, 
						PaymentTransactionDate = @paymentTransactionDate, 
						PaymentAmount = @paymentAmount, 
						PaymentAuthCode = @paymentAuthCode, 
						ReceiptNumber = @paymentReceiptNumber
					WHERE Id = @reconciliationDataId;
				END

				-- mark duplicate payments
				DECLARE @paymentIdCount INT = 0;
				SELECT @paymentIdCount = COUNT(paymentId) FROM reconciliationData WHERE ReconciliationId = @ReconciliationId GROUP BY paymentId;

				IF @paymentIdCount > 1
				BEGIN
					UPDATE reconciliationData
					SET duplicate = 'true'
					WHERE 
						ReconciliationId = @ReconciliationId AND
						paymentId = @paymentId;
				END
			
				-- set @reconciliationDataId to the next reconciliationDataId
				DECLARE @newReconciliationDataId INT = NULL;

				SELECT TOP 1 @newReconciliationDataId = Id 
				FROM ReconciliationData 
				WHERE 
					ReconciliationId = @ReconciliationId AND
					 Id > @reconciliationDataId
				ORDER BY Id ASC;

				IF @newReconciliationDataId IS NULL	-- this is to ensure the @reconciliationDataId was being set to null at the end to stop an infinite loop.
				BEGIN
					SET @reconciliationDataId = NULL;
				END
				ELSE
				BEGIN
					SET @reconciliationDataId = @newReconciliationDataId;
				END
			END

			-- insert into reconciliationData the payments for this timespan that aren't in the reconciliationData table already.
			INSERT INTO ReconciliationData (ReconciliationId, PaymentId, PaymentTransactionDate, PaymentAmount, PaymentAuthCode, ReceiptNumber)
			SELECT @ReconciliationId, Id, TransactionDate, Amount, AuthCode, ReceiptNumber
			FROM
				Payment
			WHERE
				transactionDate >= @paymentStartDate AND 
				transactionDate <= @paymentEndDate AND
				Id NOT IN (SELECT Distinct PaymentId from reconciliationData where reconciliationId = @ReconciliationId AND paymentid IS NOT NULL);

			-- set the flag so the reconciliation isn't run again.
			UPDATE Reconciliation SET RefreshPaymentData = 'false' where Id = @ReconciliationId;
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

	
DECLARE @ScriptName VARCHAR(100) = 'SP045_15.03_AlterSP_uspRefreshReconciliationData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
