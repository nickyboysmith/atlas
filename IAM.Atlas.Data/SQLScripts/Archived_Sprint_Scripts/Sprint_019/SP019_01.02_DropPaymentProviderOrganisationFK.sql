/*
	SCRIPT: Drop PaymentProvider Organisation FK
	Author: Miles Stewart
	Created: 15/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_01.02_DropPaymentProviderOrganisationFK.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Drop PaymentProvider Organisation FK';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_PaymentProvider_Organisation')
				   AND parent_object_id = OBJECT_ID(N'dbo.PaymentProvider')
		)
		BEGIN
			ALTER TABLE PaymentProvider DROP CONSTRAINT FK_PaymentProvider_Organisation;
		END
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;