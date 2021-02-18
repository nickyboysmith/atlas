/*
 * SCRIPT: Alter Table Payment - add in new columns
 * Author: Dan Hough
 * Created: 24/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_04.01_AmendPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to Payment table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.Payment
		  ADD CardPayment bit DEFAULT 'False' 
		    , Refund bit DEFAULT 'False' 
			, UpdatedByUserId int NULL
		    , CONSTRAINT FK_Payment_User1 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;