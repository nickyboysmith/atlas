/*
 * SCRIPT: Create NetcallRequest Table
 * Author: Robert Newnham
 * Created: 30/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_01.05_CreateTableNetcallRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create NetcallRequest Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'NetcallRequest'
		
		/*
		 *	Create NetcallRequest Table
		 */
		IF OBJECT_ID('dbo.NetcallRequest', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.NetcallRequest;
		END
		
		CREATE TABLE NetcallRequest(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Date] DATETIME DEFAULT GETDATE()
			, Method VARCHAR(100)
			, InSessionIdentifier VARCHAR(40)
			, InRequestIdentifier VARCHAR(40)
			, InRequestDateTime DATETIME
			, InCallingNumber VARCHAR(40)
			, InAppContext VARCHAR(300)
			, InClientIdentifier VARCHAR(40)
			, InDateOfBirth VARCHAR(40)
			, InAuthorisationReference VARCHAR(100)
			, InAuthorisationCode VARCHAR(100)
			, OutResponseDate DATETIME
			, OutResult VARCHAR(100)
			, OutResultDescription VARCHAR(1000)
			, OutClientIdentifier VARCHAR(40)
			, OutPaymentAmountInPence INT
			, OutSurchargeToApplyInPence INT
			, OutTotalPaymentAmountInPence INT
			, OutCourseVenue VARCHAR(200)
			, OutTransactionReference VARCHAR(40)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

