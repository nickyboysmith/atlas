/*
	SCRIPT: Create LoginNumber Table
	Author: Dan Hough
	Created: 24/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_01.01_Create_LoginNumber.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the LoginNumber Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'LoginNumber'
		
		/*
		 *	Create LoginNumber Table
		 */
		IF OBJECT_ID('dbo.LoginNumber', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.LoginNumber;
		END

		CREATE TABLE LoginNumber(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, LoginReference varchar(400) NOT NULL
			, DateAdded DateTime NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;