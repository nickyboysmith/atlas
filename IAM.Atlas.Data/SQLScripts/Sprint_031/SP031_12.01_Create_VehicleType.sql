/*
	SCRIPT:  Create VehicleType Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.01_Create_VehicleType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create VehicleType Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VehicleType'
		
		/*
		 *	Create VehicleType Table
		 */
		IF OBJECT_ID('dbo.VehicleType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VehicleType;
		END

		CREATE TABLE VehicleType(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;