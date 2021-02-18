/*
	SCRIPT: Create uspCancelRefundRequest
	Author: Dan Hough
	Created: 07/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_28.01_Create_SP_uspCancelRefundRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspCancelRefundRequest';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCancelRefundRequest', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCancelRefundRequest;
END		
GO
	/*
		Create uspCancelRefundRequest
	*/

	CREATE PROCEDURE dbo.uspCancelRefundRequest (@refundRequestId INT, @userId INT)
	AS
	BEGIN
		INSERT INTO dbo.CancelledRefundRequest (RefundRequestId, DateCancelled, CancelledByUserId)
		VALUES(@refundRequestId, GETDATE(), @userId)
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP038_28.01_Create_SP_uspCancelRefundRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
