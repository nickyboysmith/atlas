/*
	SCRIPT: Create DORSForce Table
	Author: Paul Tuck
	Created: 23/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP016_06.01_Create_DORSForceTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the DORSForce Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSForce'
		
		/*
		 *	Create DORSForce Table
		 */
		IF OBJECT_ID('dbo.DORSForce', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSForce;
		END

		CREATE TABLE DORSForce(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(100) NOT NULL
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;