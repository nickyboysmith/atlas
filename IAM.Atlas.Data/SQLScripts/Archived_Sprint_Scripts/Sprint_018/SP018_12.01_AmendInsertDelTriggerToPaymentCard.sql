/*
	SCRIPT: Amend update, insert, delete trigger on the PaymentCard table - adds in PaymentCardTypeId
	Author: Dan Hough
	Created: 31/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_12.01_AmendInsertDelTriggerToPaymentCard.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert, delete trigger on the PaymentCard table - adds in PaymentCardTypeId';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_PaymentCard_InsertUpdateDelete]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_PaymentCard_InsertUpdateDelete];
		END
GO
		CREATE TRIGGER TRG_PaymentCard_InsertUpdateDelete ON PaymentCard AFTER INSERT, UPDATE, DELETE
AS

BEGIN

/* When a new record is inserted on to the PaymentCard table */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
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
					, PaymentCardTypeId)

		    SELECT    i.id
		 			, ChangeType = 'Insert'
		   			, LogType = 'New'
					, DateChanged = GETDATE()
					, i.PaymentId 
					, i.PaymentCardSupplierId 
					, i.PaymentProviderId 
					, i.PaymentProviderTransactionReference
					, i.TransactionDate 
					, i.DateCreated 
					, i.CreatedByUserId
					, LogDate = GETDATE()
					, i.PaymentCardTypeId

			FROM	inserted i INNER JOIN
					PaymentCard PC ON i.id = PC.id 
					AND NOT EXISTS(SELECT id from deleted d where d.id = PC.id)

/* When a record is deleted on the PaymentCard table */ 


	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
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
					, PaymentCardTypeId)

			SELECT    d.id
		 			, ChangeType = 'Delete'
		   			, LogType = 'Delete'
					, DateChanged = GETDATE()
					, d.PaymentId 
					, d.PaymentCardSupplierId 
					, d.PaymentProviderId 
					, d.PaymentProviderTransactionReference
					, d.TransactionDate 
					, d.DateCreated 
					, d.CreatedByUserId
					, LogDate = GETDATE()
					, d.PaymentCardTypeId

			FROM	deleted d

/* When a record is updated on to the PaymentCard table - inserts previous values */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
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
					, PaymentCardTypeId)

			SELECT    d.id
		 			, ChangeType = 'Update'
		   			, LogType = 'Previous Values'
					, DateChanged = GETDATE()
					, d.PaymentId 
					, d.PaymentCardSupplierId 
					, d.PaymentProviderId 
					, d.PaymentProviderTransactionReference
					, d.TransactionDate 
					, d.DateCreated 
					, d.CreatedByUserId
					, LogDate = GETDATE()
					, d.PaymentCardTypeId

			FROM	deleted d INNER JOIN
					inserted i ON d.id = i.id INNER JOIN
					PaymentCard PC ON PC.id = d.id

/* When a record is updated on to the PaymentCard table - inserts new values */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
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
					, PaymentCardTypeId)

			SELECT    i.id
		 			, ChangeType = 'Update'
		   			, LogType = 'New Values'
					, DateChanged = GETDATE()
					, i.PaymentId 
					, i.PaymentCardSupplierId 
					, i.PaymentProviderId 
					, i.PaymentProviderTransactionReference
					, i.TransactionDate 
					, i.DateCreated 
					, i.CreatedByUserId
					, LogDate = GETDATE()
					, i.PaymentCardTypeId

			FROM	deleted d INNER JOIN
					inserted i ON d.id = i.id INNER JOIN
					PaymentCard PC ON PC.id = d.id

END

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP018_12.01_AmendInsertDelTriggerToPaymentCard.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO