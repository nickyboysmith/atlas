/*
 * SCRIPT: Alter DashboardMeterData_Payment
 * Author: Nick Smith
 * Created: 04/10/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP044_15.01_AlterTableDashboardMeterData_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter DashboardMeterData_Payment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DashboardMeterData_Payment
		ADD NumberOfPhonePaymentsTakenToday INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenYesterday INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenThisWeek INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenThisMonth INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenPreviousMonth INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenThisYear INT NOT NULL DEFAULT ((0))
			, NumberOfPhonePaymentsTakenPreviousYear INT NOT NULL DEFAULT ((0))
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;