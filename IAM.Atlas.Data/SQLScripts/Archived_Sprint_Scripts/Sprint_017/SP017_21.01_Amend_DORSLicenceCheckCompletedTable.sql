/*
 * SCRIPT: Alter Table DORSLicenceCheckCompleted Add new column DORSLicenceCheckRequestId
 * Author: Paul Tuck
 * Created: 22/03/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP017_21.01_Amend_DORSLicenceCheckCompletedTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table DORSLicenceCheckCompleted Add new column DORSLicenceCheckRequestId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.DORSLicenceCheckCompleted
		ADD DORSLicenceCheckRequestId INT NULL
		, CONSTRAINT FK_DORSLicenceCheckCompleted_DORSLicenceCheckRequest FOREIGN KEY (DORSLicenceCheckRequestId) REFERENCES DORSLicenceCheckRequest(Id);
		

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

