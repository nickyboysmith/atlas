/*
 * SCRIPT: Create Table DashboardMeterData_UnableToUpdateInDORS
 * Author: Nick Smith
 * Created: 02/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_26.02_CreateTableDashboardMeterData_UnableToUpdateInDORS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DashboardMeterData_UnableToUpdateInDORS';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_UnableToUpdateInDORS'
		
		/*
		 *	Create DashboardMeterData_UnableToUpdateInDORS Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_UnableToUpdateInDORS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_UnableToUpdateInDORS;
		END

		CREATE TABLE DashboardMeterData_UnableToUpdateInDORS(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_UnableToUpdateInDORSOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalClientsUnableToUpdateInDORS INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_UnableToUpdateInDORS_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		);
		/**************************************************************************************************************************/
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;