/*
	SCRIPT: Create Table DashboardMeterExposure
	Author: Nick Smith	
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_11.01_Create_DashboardMeterExposureTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DashboardMeterExposure Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterExposure'
		
		/*
		 *	Create DashboardMeterExposure Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterExposure', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterExposure;
		END

		CREATE TABLE DashboardMeterExposure(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DashboardMeterId INT
			, OrganisationId INT
			, CONSTRAINT FK_DashboardMeterExposure_DashboardMeter FOREIGN KEY (DashboardMeterId) REFERENCES [DashboardMeter](Id)
			, CONSTRAINT FK_DashboardMeterExposure_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;