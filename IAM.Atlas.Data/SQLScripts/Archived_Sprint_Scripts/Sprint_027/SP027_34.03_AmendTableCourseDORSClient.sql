/*
 * SCRIPT: Alter Table CourseDORSClient Add new columns PaidInFull, OnlyPartPaymentMade
 * Author: Robert Newnham
 * Created: 15/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_34.03_AmendTableCourseDORSClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'lter Table CourseDORSClient Add new columns PaidInFull, OnlyPartPaymentMade';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDORSClient
		ADD PaidInFull BIT DEFAULT 'False'
		, OnlyPartPaymentMade BIT DEFAULT 'False'
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
