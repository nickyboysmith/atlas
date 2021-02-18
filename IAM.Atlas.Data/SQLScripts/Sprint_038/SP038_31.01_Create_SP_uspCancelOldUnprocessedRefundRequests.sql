/*
	SCRIPT: Create uspCancelOldUnprocessedRefundRequests
	Author: Dan Hough
	Created: 07/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_31.01_Create_SP_uspCancelOldUnprocessedRefundRequests.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspCancelOldUnprocessedRefundRequests';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCancelOldUnprocessedRefundRequests', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCancelOldUnprocessedRefundRequests;
END		
GO
	/*
		Create uspCancelOldUnprocessedRefundRequests
	*/

	CREATE PROCEDURE dbo.uspCancelOldUnprocessedRefundRequests
	AS
	BEGIN
		DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId()
				, @refundRequestId INT
				, @cancellationReason CHAR(50) = 'Request Automatically Cancelled, due to inactivity';

		DECLARE unprocessedReqs CURSOR FOR
		SELECT RR.Id
		FROM dbo.RefundRequest RR
		LEFT JOIN dbo.CancelledRefundRequest CRR ON RR.Id = CRR.RefundRequestId
		WHERE (CRR.Id IS NULL) AND (RequestDone = 'False') AND (RequestDate <= DATEADD(DAY, -14, GETDATE()))

		OPEN unprocessedReqs;
		FETCH NEXT FROM unprocessedReqs
		INTO @refundRequestId;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF (@refundRequestId IS NOT NULL AND @atlasSystemUserId IS NOT NULL)
			BEGIN
				EXEC uspCancelRefundRequest @refundRequestId, @atlasSystemUserId;
				EXEC uspSendCancelledRefundRequestNotification @refundRequestId, @cancellationReason;
			END

			FETCH NEXT FROM unprocessedReqs
			INTO @refundRequestId;
		END

		CLOSE unprocessedReqs;
		DEALLOCATE unprocessedReqs;
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP038_31.01_Create_SP_uspCancelOldUnprocessedRefundRequests.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO