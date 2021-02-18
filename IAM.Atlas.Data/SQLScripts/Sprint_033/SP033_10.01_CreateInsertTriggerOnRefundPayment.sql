/*
	SCRIPT: Create Insert trigger TRG_CancelledRefund_Insert on table CancelledRefund
	Author: Dan Hough
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_10.01_CreateInsertTriggerOnRefundPayment';
DECLARE @ScriptComments VARCHAR(800) = 'Create Delete trigger TRG_CancelledRefund_Insert on table CancelledRefund';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CancelledRefund_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CancelledRefund_Insert;
	END
GO
	CREATE TRIGGER TRG_CancelledRefund_Insert ON dbo.CancelledRefund AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CancelledRefund', 'dbo.TRG_CancelledRefund_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @refundId INT
					, @organisationPaymentId INT
					, @refundPaymentId INT;

			SELECT @refundId = i.RefundId
					, @organisationPaymentId = op.Id
					, @refundPaymentId = rp.RefundPaymentId
			FROM Inserted i
			LEFT JOIN dbo.RefundPayment rp ON i.RefundId = rp.RefundId
			LEFT JOIN dbo.OrganisationPayment op ON rp.RefundPaymentId = op.PaymentId;

			IF (@organisationPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.OrganisationPayment
				WHERE Id = @organisationPaymentId;
			END

			IF(@refundPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.RefundPayment
				WHERE RefundPaymentId = @refundPaymentId;

				DELETE FROM dbo.Payment
				WHERE Id = @refundPaymentId;
			END
		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_10.01_CreateInsertTriggerOnRefundPayment';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO