/*
	SCRIPT: Create DORSClientCourseAttendanceLog Table
	Author: Paul Tuck
	Created: 03/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_27.01_CreateTable_DORSClientCourseAttendanceLog';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSClientCourseAttendanceLog Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */
		EXEC dbo.uspDropTableContraints 'DORSClientCourseAttendanceLog'
		
		/*
		 *	Create ReconciliationConfiguration Table
		 */
		IF OBJECT_ID('dbo.DORSClientCourseAttendanceLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSClientCourseAttendanceLog;
		END

		CREATE TABLE DORSClientCourseAttendanceLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSNotified BIT NOT NULL DEFAULT 'False'
			, DORSClientIdentifier INT NOT NULL
			, DORSCourseIdentifier INT NOT NULL
			, NumberOfAttempts INT NOT NULL DEFAULT 0
			, DateLastAttempted DATETIME NULL
			, DateCreated DATETIME NOT NULL
			, ErrorMessage VARCHAR(1000) NULL
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END