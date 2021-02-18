/*
	SCRIPT: Add Payment Provider Id Constraint To Payment Card Table
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_04.01_AddConstraintToPaymentCardTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Payment Provider Id Constraint To Payment Card Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		/*
		 *	Add Constraint 
		 */		

		ALTER TABLE PaymentCard 		
		ADD CONSTRAINT FK_PaymentCard_PaymentProvider FOREIGN KEY (PaymentProviderId) REFERENCES [PaymentProvider](Id);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;