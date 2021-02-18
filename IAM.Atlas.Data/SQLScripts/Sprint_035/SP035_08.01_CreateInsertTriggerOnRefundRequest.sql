/*
	SCRIPT: Create insert trigger on RefundRequest
	Author: Dan Hough
	Created: 17/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_08.01_CreateInsertTriggerOnRefundRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create insert trigger on RefundRequest';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_RefundRequest_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_RefundRequest_Insert;
	END

	GO

	CREATE TRIGGER TRG_RefundRequest_Insert ON dbo.RefundRequest AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'RefundRequest', 'TRG_RefundRequest_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			DECLARE @refundRequestId INT;
			SELECT @refundRequestId = Id FROM Inserted i;
			EXEC dbo.uspSendRefundRequestNotification @refundRequestId;

		END
	END


	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_08.01_CreateInsertTriggerOnRefundRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO