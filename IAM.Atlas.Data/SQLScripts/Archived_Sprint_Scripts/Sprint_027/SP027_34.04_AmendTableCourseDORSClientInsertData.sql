/*
 * SCRIPT: Alter Table CourseDORSClient Data for new columns PaidInFull, OnlyPartPaymentMade
 * Author: Robert Newnham
 * Created: 15/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_34.04_AmendTableCourseDORSClientInsertData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table CourseDORSClient Add new columns PaidInFull, OnlyPartPaymentMade Update the Data';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.CourseDORSClient
		SET PaidInFull = 'False'
		, OnlyPartPaymentMade = 'False'
		WHERE PaidInFull IS NULL AND OnlyPartPaymentMade IS NULL
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
