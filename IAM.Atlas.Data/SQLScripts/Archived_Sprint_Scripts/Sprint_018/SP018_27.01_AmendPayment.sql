/*
 * SCRIPT: Alter Table Payment
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_27.01_AmendPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to Payment table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Payment
		 ADD PaymentName varchar(320) NULL
		, Reference varchar(100) NULL
		, DEFAULT GETDATE() FOR DateCreated


		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;