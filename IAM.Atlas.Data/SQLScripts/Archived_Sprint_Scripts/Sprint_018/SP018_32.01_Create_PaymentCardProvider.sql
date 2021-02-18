/*
	SCRIPT: Create PaymentCardProvider Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_32.01_Create_PaymentCardProvider.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the PaymentCardProvider Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'PaymentCardProvider'
		
		/*
		 *	Create PaymentCardProvider Table
		 */
		IF OBJECT_ID('dbo.PaymentCardProvider', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.PaymentCardProvider;
		END

		CREATE TABLE PaymentCardProvider(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(200)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;