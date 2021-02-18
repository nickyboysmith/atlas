/*
 * SCRIPT: Alter Table Organisation Add Columns
	Author: Robert Newnham
	Created: 30/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_25.01_AmendOrganisationTableAddColumns.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Organisation Add Columns';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Organisation
			ADD 
				PreviousSystemName VARCHAR(320)
				, DateUpdated DATETIME
				, UpdatedByUserId INT
				, CONSTRAINT FK_Organisation_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
