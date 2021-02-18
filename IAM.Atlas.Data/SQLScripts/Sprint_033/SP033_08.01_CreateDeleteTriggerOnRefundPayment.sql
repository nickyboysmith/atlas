/*
	SCRIPT: Create Delete trigger TRG_RefundPayment_Delete on table RefundPayment
	Author: Dan Hough
	Created: 08/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_08.01_CreateDeleteTriggerOnRefundPayment';
DECLARE @ScriptComments VARCHAR(800) = 'Create Delete trigger TRG_RefundPayment_Delete on table RefundPayment';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_RefundPayment_Delete', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_RefundPayment_Delete;
	END
GO
	CREATE TRIGGER TRG_RefundPayment_Delete ON dbo.RefundPayment AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'RefundPayment', 'dbo.TRG_RefundPayment_Delete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @refundPaymentId INT
					, @organisationPaymentId INT
					, @clientPaymentId INT
					, @courseClientPaymentId INT;

			SELECT @refundPaymentId = d.RefundPaymentId
					, @organisationPaymentId = op.Id
					, @clientPaymentId = cp.Id
					, @courseClientPaymentId = ccp.Id
			FROM Deleted d
			LEFT JOIN dbo.OrganisationPayment op ON d.RefundPaymentId = op.PaymentId
			LEFT JOIN dbo.ClientPayment cp ON d.RefundPaymentId = cp.PaymentId
			LEFT JOIN dbo.CourseClientPayment ccp ON d.RefundPaymentId = ccp.PaymentId;

			IF(@organisationPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.OrganisationPayment
				WHERE Id = @organisationPaymentId;
			END

			IF(@clientPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.ClientPayment
				WHERE Id = @clientPaymentId;
			END

			IF(@courseClientPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.CourseClientPayment
				WHERE Id = @courseClientPaymentId;
			END

			IF(@refundPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.Payment
				WHERE Id = @refundPaymentId;
			END
		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_08.01_CreateDeleteTriggerOnRefundPayment';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO