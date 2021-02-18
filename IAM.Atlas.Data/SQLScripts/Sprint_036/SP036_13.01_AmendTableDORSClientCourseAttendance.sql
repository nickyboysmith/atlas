/*
 * SCRIPT: Add New Columns to Table DORSClientCourseAttendance
 * Author: Paul Tuck
 * Created: 21/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP036_13.01_AmendTableDORSClientCourseAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table DORSClientCourseAttendance';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSClientCourseAttendance
		ADD DORSExpiryDate DATETIME NULL
			, DORSForceIdentifier INT NULL
			, DORSSchemeIdentifier INT NULL
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_DORSClientCourseAttendance_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;