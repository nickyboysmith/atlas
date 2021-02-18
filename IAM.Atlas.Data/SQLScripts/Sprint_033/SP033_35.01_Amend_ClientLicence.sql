/*
 * SCRIPT: Add column UKLicenceToBirthdayValidated to ClientLicence
 * Author: Dan Hough
 * Created: 20/02/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP033_35.01_Amend_ClientLicence.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column UKLicenceToBirthdayValidated to ClientLicence';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientLicence
		ADD UKLicenceToBirthdayValidated BIT NOT NULL DEFAULT 'False'
		, DateLastLicenceBirthdayCheck DATETIME NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;