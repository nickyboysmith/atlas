/*
 * SCRIPT: Add Column to Table SystemControl
 * Author: Nick Smith
 * Created: 18/10/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP045_03.01_AmendTableSystemControl.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Online Booking Blocked Control Columns to SystemControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[SystemControl]
		ADD OnlineBookingBlocked BIT NOT NULL DEFAULT 'False'
		, OnlineBookingSystemNoticeOn BIT NOT NULL DEFAULT 'False'
		, OnlineBookingSystemNoticeMessage VARCHAR(100)
		, OnlineBookingSystemNoticeClickHereOn BIT NOT NULL DEFAULT 'False'
		, OnlineBookingSystemNoticeClickHereMessage VARCHAR(100)
		, OnlineBookingSystemNoticeClickHereLink VARCHAR(200)
		, OnlineBookingSystemNoticeColour VARCHAR(40);
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;