/*
 * SCRIPT: Alter Table ClientOnlineBookingState
 * Author: Dan Murray
 * Created: 31/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_02.01_AmendClientOnlineBookingState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to ClientOnlineBookingState table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		ALTER TABLE dbo.ClientOnlineBookingState
			 ADD FullPaymentRecieved BIT DEFAULT 0
			,DateTimePaymentRecieved DATETIME NULL
			,EmailConfirmationSent BIT DEFAULT 0
			,DateTimeEmailSent DATETIME NULL
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;