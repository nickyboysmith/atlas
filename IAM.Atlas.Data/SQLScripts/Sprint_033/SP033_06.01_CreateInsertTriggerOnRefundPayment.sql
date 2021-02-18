/*
	SCRIPT: Create Insert trigger TRG_RefundPayment_Insert on table RefundPayment
	Author: Dan Hough
	Created: 07/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_06.01_CreateInsertTriggerOnRefundPayment';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger TRG_RefundPayment_Insert on table RefundPayment';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_RefundPayment_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_RefundPayment_Insert;
	END
GO
	CREATE TRIGGER TRG_RefundPayment_Insert ON dbo.RefundPayment AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'RefundPayment', 'dbo.TRG_RefundPayment_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @refundPaymentId INT
					, @refundId INT
					, @paymentId INT
					, @insertedPaymentId INT
					, @refundReference VARCHAR(100)
					, @clientId INT
					, @refundTransactionDate DATETIME
					, @refundAmount MONEY
					, @refundCreatedByUserId INT
					, @refundPaymentName VARCHAR(320)
					, @paymentTypeId INT
					, @paymentMethodId INT
					, @cardPayment BIT
					, @organisationId INT
					, @courseId INT
					, @atlasSystemUserId INT;


			SELECT    @refundId = i.RefundId
					, @paymentId = i.PaymentId
			 FROM Inserted i;

			SELECT @refundAmount = ISNULL(Amount * -1, 0)
					, @refundTransactionDate = TransactionDate
					, @refundReference = Reference
					, @refundCreatedByUserId = CreatedByUserId
					, @refundPaymentName = PaymentName
			FROM dbo.Refund
			WHERE Id = @refundId;

			SELECT @atlasSystemUserId = dbo.udfGetSystemUserId();

			SELECT @paymentTypeId = p.PaymentTypeId
					, @paymentMethodId = p.PaymentMethodId
					, @cardPayment = p.CardPayment
					, @organisationId = op.OrganisationId
					, @clientId = cp.ClientId
					, @courseId = ccp.CourseId
			FROM dbo.Payment p
			INNER JOIN dbo.OrganisationPayment op ON p.Id = op.PaymentId
			LEFT JOIN dbo.ClientPayment cp ON p.Id = cp.PaymentId
			LEFT JOIN dbo.CourseClientPayment ccp ON p.Id = ccp.PaymentId
			WHERE p.Id = @paymentId;

			INSERT INTO dbo.Payment (
									DateCreated
									, TransactionDate
									, Amount
									, PaymentTypeId
									, PaymentMethodId
									, CreatedByUserId
									, CardPayment
									, Refund
									, UpdatedByUserId
									, PaymentName
									, Reference
									, NetcallPayment
									)

							VALUES (
									GETDATE()
									, @refundTransactionDate 
									, @refundAmount
									, @paymentTypeId
									, @paymentMethodId
									, @refundCreatedByUserId
									, @cardPayment
									, 'True' --refund
									, NULL --UpdatedByUserId
									, @refundPaymentName
									, @refundReference--reference
									, NULL --NetcallPayment
									)

			-- Grab the new created paymentId for use in following updates and inserts.
			SELECT @insertedPaymentId = SCOPE_IDENTITY();

			PRINT @insertedPaymentId

			IF(@insertedPaymentId IS NOT NULL)
			BEGIN
				UPDATE RefundPayment
				SET RefundPaymentId = @insertedPaymentId
				WHERE PaymentId = @paymentId AND RefundPaymentId IS NULL;

				INSERT INTO dbo.OrganisationPayment (
													OrganisationId
													, PaymentId
													)

				SELECT @organisationId, @insertedPaymentId
				WHERE NOT EXISTS(SELECT * 
								FROM dbo.OrganisationPayment 
								WHERE Organisationid = @organisationId 
									AND PaymentId = @insertedPaymentId)

				IF(((SELECT COUNT(*) FROM dbo.ClientPayment WHERE PaymentId = @paymentId) > 0)
					AND (@clientId IS NOT NULL))
				BEGIN
					INSERT INTO dbo.ClientPayment (
													ClientId
													, PaymentId
													, AddedByUserId
													)

											VALUES ( 
													@clientId
													, @insertedPaymentId
													, @atlasSystemUserId
													)
				END

				IF(((SELECT COUNT(*) FROM dbo.CourseClientPayment WHERE PaymentId = @paymentId) > 0)
					AND (@clientId IS NOT NULL)
					AND (@courseId IS NOT NULL))
				BEGIN
					PRINT 'Insie of CourseClientPayment insert'
					INSERT INTO dbo.CourseClientPayment (
														CourseId
														, ClientId
														, PaymentId
														, AddedByUserId
														)

												VALUES ( 
														@courseId
														, @clientId
														, @insertedPaymentId
														, @atlasSystemUserId
														)

				END--Inserting in to CourseClientPayment
			END  --IF(@insertedPaymentId IS NOT NULL)
		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP033_06.01_CreateInsertTriggerOnRefundPayment';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO