/*
	SCRIPT: Create DashboardMeterCategory Table 
	Author: Robert Newnham
	Created: 06/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_10.01_CreateDashboardMeterCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DashboardMeterCategory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterCategory'
		
		/*
		 *	Create DashboardMeterCategory Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterCategory;
		END

		CREATE TABLE DashboardMeterCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100) NOT NULL 
			, PictureName VARCHAR(100)
			, DefaultCategory BIT NOT NULL DEFAULT 'False'
			, CONSTRAINT UX_DashboardMeterCategory_Name UNIQUE ([Name])
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END