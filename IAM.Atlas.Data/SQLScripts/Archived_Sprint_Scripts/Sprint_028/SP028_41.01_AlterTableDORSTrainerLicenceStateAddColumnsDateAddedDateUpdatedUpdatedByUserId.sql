/*
 * SCRIPT: Alter Table DORSTrainerLicenceState Add Columns DateAdded , DateUpdated, UpdatedByUserId
	Author: Nick Smith
	Created: 09/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_41.01_AlterTableDORSTrainerLicenceStateAddColumnsDateAddedDateUpdatedUpdatedByUserId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table DORSTrainerLicenceState Add Columns DateAdded , DateUpdated, UpdatedByUserId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.DORSTrainerLicenceState
			ADD 
				DateAdded DATETIME NOT NULL DEFAULT GETDATE()
				, DateUpdated DATETIME
				, UpdatedByUserId INT
				, CONSTRAINT FK_DORSTrainerLicenceState_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			;

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
