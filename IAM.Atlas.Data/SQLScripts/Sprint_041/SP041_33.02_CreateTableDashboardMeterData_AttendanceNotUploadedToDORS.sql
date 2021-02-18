/*
 * SCRIPT: Create Table DashboardMeterData_AttendanceNotUploadedToDORS
 * Author: Nick Smith
 * Created: 10/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP041_33.02_CreateTableDashboardMeterData_AttendanceNotUploadedToDORS.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DashboardMeterData_AttendanceNotUploadedToDORS';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DashboardMeterData_AttendanceNotUploadedToDORS'
		
		/*
		 *	Create DashboardMeterData_AttendanceNotUploadedToDORS Table
		 */
		IF OBJECT_ID('dbo.DashboardMeterData_AttendanceNotUploadedToDORS', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DashboardMeterData_AttendanceNotUploadedToDORS;
		END

		CREATE TABLE DashboardMeterData_AttendanceNotUploadedToDORS(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL INDEX IX_DashboardMeterData_AttendanceNotUploadedToDORSOrganisationId NONCLUSTERED
			, OrganisationName VARCHAR(320) NOT NULL
			, DateAndTimeRefreshed DateTime NOT NULL DEFAULT GETDATE()
			, TotalAttendanceNotUploadedToDORS INT NOT NULL DEFAULT 0
			, CONSTRAINT FK_DashboardMeterData_AttendanceNotUploadedToDORS_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
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