/*
	SCRIPT: Create PaymentCardSupplier Table
	Author: Dan Hough
	Created: 24/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_05.01_Create_PaymentCardSupplier.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentCardSupplier Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardSupplier'
		
		/*
		 *	Create PaymentCardSupplier Table
		 */
		IF OBJECT_ID('dbo.PaymentCardSupplier', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardSupplier;
		END

		CREATE TABLE PaymentCardSupplier(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(200)
			, [Disabled] bit DEFAULT 'FALSE'
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;