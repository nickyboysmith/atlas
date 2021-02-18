/*
 * SCRIPT: Add Columns to CancelledRefundRequest table
 * Author: Dan Hough
 * Created: 06/06/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_26.01_Alter_CancelledRefundRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Columns to CancelledRefundRequest table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CancelledRefundRequest
		ADD DateCancellationNotificationSent DATETIME NULL
			, CancellationReason VARCHAR(200) NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;