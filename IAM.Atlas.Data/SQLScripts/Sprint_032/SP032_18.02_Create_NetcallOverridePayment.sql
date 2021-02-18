/*
	SCRIPT: Create NetcallOverridePayment Table 
	Author: Paul Tuck
	Created: 23/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_18.02_Create_NetcallOverridePayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallOverridePayment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		CREATE TABLE NetcallOverridePayment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, NetcallOverrideId INT NOT NULL
			, PaymentId INT NOT NULL
			, CONSTRAINT FK_NetcallOverridePayment_NetcallOverride FOREIGN KEY (NetcallOverrideId) REFERENCES NetcallOverride(Id)
			, CONSTRAINT FK_NetcallOverridePayment_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;