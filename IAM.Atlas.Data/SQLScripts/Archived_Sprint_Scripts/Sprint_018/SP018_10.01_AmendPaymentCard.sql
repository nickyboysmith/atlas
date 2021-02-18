/*
 * SCRIPT: Alter Table PaymentCard - add in PaymentCardTypeId
 * Author: Dan Hough
 * Created: 31/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_10.01_AmendPaymentCard.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to PaymentCard table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.PaymentCard
		  ADD PaymentCardTypeId int 
		, CONSTRAINT FK_PaymentCard_PaymentCardType FOREIGN KEY (PaymentCardTypeId) REFERENCES PaymentCardType(Id);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;