/*
	SCRIPT: ReCreate DORSAttendanceState Table
	Author: Robert Newnham
	Created: 07/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.01_ReCreate_DORSAttendanceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'ReCreate DORSAttendanceState Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSAttendanceState'
		
		IF EXISTS (SELECT * 
					FROM sys.foreign_keys
					WHERE object_id = OBJECT_ID(N'FK_DORSAttendanceState_User')
						AND parent_object_id = OBJECT_ID(N'[dbo].[DORSAttendanceState]')
					)
		BEGIN
			ALTER TABLE dbo.DORSAttendanceState 
			DROP CONSTRAINT FK_DORSAttendanceState_User;
		END
		
		/*
		 *	Create CourseDORSClient Table
		 */
		IF OBJECT_ID('dbo.DORSAttendanceState', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSAttendanceState;
		END

		CREATE TABLE DORSAttendanceState(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSAttendanceStateIdentifier INT NOT NULL
			, [Name] VARCHAR(100)
			, [Description] VARCHAR(400)
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT UC_DORSAttendanceState_DORSAttendanceStateIdentifier UNIQUE(DORSAttendanceStateIdentifier)
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