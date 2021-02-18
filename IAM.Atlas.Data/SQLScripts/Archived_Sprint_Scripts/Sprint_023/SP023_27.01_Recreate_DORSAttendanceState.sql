/*
	SCRIPT: Recreate DORSAttendanceState Table
	Author: Dan Hough
	Created: 22/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_27.01_Recreate_DORSAttendanceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Recreate DORSAttendanceState Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*Drop Foreign Key on DORSLicenceCheckCompleted Table*/

			IF EXISTS (SELECT * 
					   FROM sys.foreign_keys
					   WHERE object_id = OBJECT_ID(N'FK_DORSLicenceCheckCompleted_DORSAttendanceState')
							AND parent_object_id = OBJECT_ID(N'[dbo].[DORSLicenceCheckCompleted]')
					  )
			BEGIN
			ALTER TABLE dbo.DORSLicenceCheckCompleted 
			DROP CONSTRAINT FK_DORSLicenceCheckCompleted_DORSAttendanceState
		    END
		

		/*Drop and Recreate DORSAttendanceState*/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSAttendanceState'
		
		/*
		 *	Create DORSAttendanceState Table
		 */
		IF OBJECT_ID('dbo.DORSAttendanceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSAttendanceState;
		END

		CREATE TABLE DORSAttendanceState(
			  Id INT NOT NULL
			, Name VARCHAR(100)
			, [Description] VARCHAR(400)
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_DORSAttendanceState_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;