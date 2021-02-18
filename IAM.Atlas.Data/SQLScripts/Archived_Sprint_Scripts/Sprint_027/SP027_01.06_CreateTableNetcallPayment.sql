/*
 * SCRIPT: Create NetcallPayment Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.06_CreateTableNetcallPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallPayment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallPayment'
		
		/*
		 *	Create NetcallPayment Table
		 */
		IF OBJECT_ID('dbo.NetcallPayment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallPayment;
		END
		
		CREATE TABLE NetcallPayment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, NetcallRequestId INT NOT NULL
			, PaymentId  INT NULL
			, CONSTRAINT FK_NetcallPayment_NetcallRequest FOREIGN KEY (NetcallRequestId) REFERENCES NetcallRequest(Id)
			, CONSTRAINT FK_NetcallPayment_Payment FOREIGN KEY (PaymentId) REFERENCES Payment(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

