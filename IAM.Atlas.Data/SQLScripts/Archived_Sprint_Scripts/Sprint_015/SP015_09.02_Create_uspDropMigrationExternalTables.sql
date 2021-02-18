
/*
	SCRIPT: Create a stored procedure to Drop the Migration External Tables from Old Atlas
	Author: Robert Newnham
	Created: 29/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP015_08.01_Create_uspDropMigrationExternalTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to Drop the Migration External Tables from Old Atlas';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDropMigrationExternalTables', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDropMigrationExternalTables;
END		
GO

/*
	Create uspDropMigrationExternalTables
*/
CREATE PROCEDURE uspDropMigrationExternalTables
AS
BEGIN
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_AdminLevels')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_AdminLevels];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_AdminLevels_Groups')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_AdminLevels_Groups];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_AdminLevels_SecurityItems')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_AdminLevels_SecurityItems];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_allowBookingsWhenDORSUnavailableHistory')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_allowBookingsWhenDORSUnavailableHistory];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Anonymisation')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Anonymisation];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Area_CourseTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Area_CourseTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_BulkDeletions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_BulkDeletions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Calendars')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Calendars];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_DeletedReferences')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_DeletedReferences];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_Documents')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_Documents];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_DorsData')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_DorsData];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_Fleet')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_Fleet];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_History')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_History];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_InstructorRole')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_InstructorRole];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_LetterFields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_LetterFields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Course_Resource')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Course_Resource];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_courseInstructorAttendance')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_courseInstructorAttendance];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseInstructorLetters')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseInstructorLetters];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseInstructorNotes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseInstructorNotes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseRegisterFields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseRegisterFields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseSignInFields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseSignInFields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseSignInFields_Custom')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseSignInFields_Custom];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseWizard')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseWizard];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CourseWizard_Course')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CourseWizard_Course];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_CustomUserFields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_CustomUserFields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DeletedClients')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DeletedClients];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DeletedClients_Bulk')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DeletedClients_Bulk];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DirectoryStructure')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DirectoryStructure];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_AttendanceStatuses')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_AttendanceStatuses];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_CourseCompletions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_CourseCompletions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_CreateDriverHistory')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_CreateDriverHistory];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_ForceContracts')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_ForceContracts];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_Forces')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_Forces];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_LicenceLookups')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_LicenceLookups];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_Log')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_Log];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_Logins')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_Logins];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_Schemes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_Schemes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_UpdateFailures_Courses')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_UpdateFailures_Courses];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DORS_UpdateFailures_Drivers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DORS_UpdateFailures_Drivers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_driver_archive')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_driver_archive];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Data')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Data];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Documents')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Documents];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_DorsData')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_DorsData];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_DuplicateData')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_DuplicateData];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_History')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_History];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_HomepageStatuses')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_HomepageStatuses];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Letters')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Letters];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Notes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Notes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Rebooking')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Rebooking];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Sessions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Sessions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_driver_tempMigratedDrivers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_driver_tempMigratedDrivers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_ThirdParties')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_ThirdParties];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Driver_Withdrawn')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Driver_Withdrawn];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DriverAccessLockHistory')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DriverAccessLockHistory];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DriverNotArchived')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DriverNotArchived];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_DriverSessions_Archive')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_DriverSessions_Archive];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_ExpiredDrivers_Deleted')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_ExpiredDrivers_Deleted];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_External_Duplicates')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_External_Duplicates];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_External_Serco')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_External_Serco];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_External_StarTraq')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_External_StarTraq];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_External_VPFPO')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_External_VPFPO];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Files')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Files];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Fora')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Fora];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Groups')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Groups];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_CourseTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_CourseTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_DisallowedVenues')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_DisallowedVenues];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_Documents')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_Documents];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_LicenceNumbers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_LicenceNumbers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_MonitoringDates')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_MonitoringDates];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Instructor_OtherRegions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Instructor_OtherRegions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_InstructorCourseType_Role')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_InstructorCourseType_Role];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LetterFields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LetterFields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Letters_Pending')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Letters_Pending];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Log_Removals')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Log_Removals];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Log_UserLogins')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Log_UserLogins];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Area')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Area];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Area_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Area_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_ChargeType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_ChargeType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_CjsCodes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_CjsCodes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_ContactSources')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_ContactSources];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Course_ResourceType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Course_ResourceType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_CourseRatio')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_CourseRatio];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_CourseType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_CourseType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_CourseType_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_CourseType_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_CourseType_RegionalNames')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_CourseType_RegionalNames];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_DriverVehicleType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_DriverVehicleType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_FleetClients')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_FleetClients];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_FleetVehicleType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_FleetVehicleType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_IncidentTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_IncidentTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Instructor_Availability')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Instructor_Availability];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_LicenceType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_LicenceType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_LicenceType_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_LicenceType_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Module')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Module];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Organisation')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Organisation];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Organisation_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Organisation_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_PaymentMethod')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_PaymentMethod];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_PaymentProvider')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_PaymentProvider];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Region')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Region];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Region_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Region_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_RejectionReasons')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_RejectionReasons];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Role')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Role];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Role_FeeGroups')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Role_FeeGroups];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Systems')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Systems];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_TrainingType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_TrainingType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_VehicleType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_VehicleType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_VehicleType_CourseType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_VehicleType_CourseType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_VehicleType_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_VehicleType_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Venue')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Venue];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Venue_CourseType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Venue_CourseType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Venue_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Venue_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_VoucherTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_VoucherTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_LU_Zone')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_LU_Zone];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Messages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Messages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Netcall_Request')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Netcall_Request];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_NetcallLog')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_NetcallLog];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Note_Users')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Note_Users];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_NotePriorities')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_NotePriorities];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Notes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Notes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Organisation_CourseTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Organisation_CourseTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Organisation_CourseTypes_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Organisation_CourseTypes_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Organisation_RegCrseType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Organisation_RegCrseType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Organisations_OrgOptions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Organisations_OrgOptions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_OrgOption_Groups')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_OrgOption_Groups];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_OrgOptions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_OrgOptions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Payment')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Payment];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Payment_Archive')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Payment_Archive];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Payment_Pending')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Payment_Pending];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Payment_Reconciliation')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Payment_Reconciliation];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Payment_Transaction')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Payment_Transaction];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Permissions_Temp')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Permissions_Temp];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PrintCsvQueue')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_PrintCsvQueue];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PrintQueue')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_PrintQueue];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PrintQueue_Delayed')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_PrintQueue_Delayed];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_PrintQueueBAK')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_PrintQueueBAK];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Queries')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Queries];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Region_CourseType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Region_CourseType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_Charges')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_Charges];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_Fields')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_Fields];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_Languages')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_Languages];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_Locking')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_Locking];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_RebookingFee')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_RebookingFee];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_RegionalSettings')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_RegionalSettings];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RegionCourseType_VehicleTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RegionCourseType_VehicleTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RejectionReason_CourseTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RejectionReason_CourseTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Report_Financials')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Report_Financials];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Report_Financials_Month')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Report_Financials_Month];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_RetainLockHistory')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_RetainLockHistory];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Security_FailedValidations')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Security_FailedValidations];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_SecurityItems')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_SecurityItems];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Sessions')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Sessions];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_SessionTransfers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_SessionTransfers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_SMSMessage')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_SMSMessage];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_SMSMessageType')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_SMSMessageType];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_SMSStatus')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_SMSStatus];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_StoredProcedures')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_StoredProcedures];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Topics')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Topics];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_User_CourseTypes')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_User_CourseTypes];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_User_DirectoryStructure')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_User_DirectoryStructure];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_User_PasswordResetRequests')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_User_PasswordResetRequests];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Users')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Users];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Users_PreviousPasswords')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Users_PreviousPasswords];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Users_Systems')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Users_Systems];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WebServiceDownloads')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WebServiceDownloads];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WebServiceDownloads_Drivers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WebServiceDownloads_Drivers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WebServiceDownloadsArchive')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WebServiceDownloadsArchive];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WebServiceUsers')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WebServiceUsers];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WebServiceUsers_Pods')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WebServiceUsers_Pods];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_Workflow_Type')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_Workflow_Type];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WorkflowRule')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WorkflowRule];
		END
		IF EXISTS (SELECT * FROM sys.tables WHERE name = 'tbl_WorkflowTimeRule')
		BEGIN
			   DROP EXTERNAL TABLE [migration].[tbl_WorkflowTimeRule];
		END
		
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP015_08.01_Create_uspDropMigrationExternalTables.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

