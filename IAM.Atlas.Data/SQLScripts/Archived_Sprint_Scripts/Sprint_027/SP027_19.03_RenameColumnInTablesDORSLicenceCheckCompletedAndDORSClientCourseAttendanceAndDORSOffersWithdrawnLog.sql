/*
 * SCRIPT: Rename Columns in tables DORSLicenceCheckCompleted and DORSClientCourseAttendance and DORSOffersWithdrawnLog
 * Author: Robert Newnham
 * Created: 07/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.03_RenameColumnInTablesDORSLicenceCheckCompletedAndDORSClientCourseAttendanceAndDORSOffersWithdrawnLog.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Columns in tables DORSLicenceCheckCompleted and DORSClientCourseAttendance and DORSOffersWithdrawnLog';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		--Correct Table DORSLicenceCheckCompleted
		IF EXISTS(SELECT *
				FROM sys.columns 
				WHERE Name      = N'DORSAttendanceStateId'
				AND Object_ID = Object_ID(N'DORSLicenceCheckCompleted'))
		BEGIN
			-- Column Exists, Rename it
			EXEC sp_RENAME 'DORSLicenceCheckCompleted.DORSAttendanceStateId' , 'DORSAttendanceStateIdentifier', 'COLUMN';
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		--Correct Table DORSClientCourseAttendance
		IF EXISTS(SELECT *
				FROM sys.columns 
				WHERE Name      = N'DORSAttendanceStateId'
				AND Object_ID = Object_ID(N'DORSClientCourseAttendance'))
		BEGIN
			-- Column Exists, Rename it
			EXEC sp_RENAME 'DORSClientCourseAttendance.DORSAttendanceStateId' , 'DORSAttendanceStateIdentifier', 'COLUMN';
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		--Correct Table DORSOffersWithdrawnLog
		IF EXISTS(SELECT *
				FROM sys.columns 
				WHERE Name      = N'DORSSchemeId'
				AND Object_ID = Object_ID(N'DORSOffersWithdrawnLog'))
		BEGIN
			-- Column Exists, Rename it
			EXEC sp_RENAME 'DORSOffersWithdrawnLog.DORSSchemeId' , 'DORSSchemeIdentifier', 'COLUMN';
		END
		---------------------------------------------------------------------------------------------------------------------------------
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

