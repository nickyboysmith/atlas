/*
 * SCRIPT: Add New Column to Table ClientDORSData
 * Author: Paul Tuck
 * Created: 24/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP038_09.01_Amend_Table_ClientDORSData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Column to Table ClientDORSData';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientDORSData
		ADD DORSAttendanceStateId INT NULL,
		CONSTRAINT FK_ClientDORSData_DORSAttendanceState FOREIGN KEY (DORSAttendanceStateId) REFERENCES DORSAttendanceState(Id); 
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;