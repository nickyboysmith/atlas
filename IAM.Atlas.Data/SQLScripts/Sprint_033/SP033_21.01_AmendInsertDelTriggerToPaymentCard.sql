/*
	SCRIPT: Amend update, insert, delete trigger on the PaymentCard table - adds in PaymentCardTypeId
	Author: Robert Newnham
	Created: 15/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_21.01_AmendInsertDelTriggerToPaymentCard.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert, delete trigger on the PaymentCard table - adds in PaymentCardTypeId';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_PaymentCard_InsertUpdateDelete', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_PaymentCard_InsertUpdateDelete;
END
GO
	CREATE TRIGGER TRG_PaymentCard_InsertUpdateDelete ON PaymentCard AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_LogChange_InsertUpdateDelete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			UPDATE P
			SET P.PaymentMethodId = PCTPM.PaymentMethodId
			FROM INSERTED I
			INNER JOIN [dbo].[Payment] P ON P.Id = I.PaymentId
			INNER JOIN [dbo].[PaymentCardTypePaymentMethod] PCTPM ON PCTPM.PaymentCardTypeId = I.PaymentCardTypeId
			WHERE P.PaymentMethodId IS NULL;

			--Log Payment Transactions
			INSERT INTO	[dbo].[PaymentCardLog] (
				PaymentCardId
				, ChangeType
				, LogType 
				, DateChanged 
				, PaymentId 
				, PaymentCardSupplierId 
				, PaymentProviderId 
				, PaymentProviderTransactionReference
				, TransactionDate 
				, DateCreated 
				, CreatedByUserId
				, LogDate
				, PaymentCardTypeId
				)
			SELECT
				ISNULL(D.Id, I.Id)												AS Id
		 		, (CASE WHEN I.Id IS NOT NULL AND D.Id IS NULL
						THEN 'Insert'
		 				WHEN I.Id IS NULL AND D.Id IS NOT NULL
						THEN 'Delete'
						ELSE 'Update' END)										AS ChangeType
		 		, (CASE WHEN I.Id IS NOT NULL AND D.Id IS NULL
						THEN 'New'
		 				WHEN I.Id IS NULL AND D.Id IS NOT NULL
						THEN 'Delete'
						ELSE 'Previous Values' END)								AS LogType
				, DateChanged = GETDATE()
				, ISNULL(D.PaymentId, I.PaymentId)								AS PaymentId
				, ISNULL(D.PaymentCardSupplierId, I.PaymentCardSupplierId)		AS PaymentCardSupplierId
				, ISNULL(D.PaymentProviderId, I.PaymentProviderId)				AS PaymentProviderId
				, ISNULL(D.PaymentProviderTransactionReference
						, I.PaymentProviderTransactionReference)				AS PaymentProviderTransactionReference
				, ISNULL(D.TransactionDate, I.TransactionDate)					AS TransactionDate
				, ISNULL(D.DateCreated, I.DateCreated)							AS DateCreated
				, ISNULL(D.CreatedByUserId, I.CreatedByUserId)					AS CreatedByUserId
				, GETDATE()														AS LogDate
				, ISNULL(D.PaymentCardTypeId, I.PaymentCardTypeId)				AS PaymentCardTypeId
			FROM INSERTED I
			FULL OUTER JOIN DELETED D ON D.Id = I.Id
			;
		END --END PROCESS
	END


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_21.01_AmendInsertDelTriggerToPaymentCard.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO