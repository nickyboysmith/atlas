/*
 * SCRIPT: Make two columns on User not null
 * Author: Dan Hough
 * Created: 13/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_14.01_Amend_User.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Make two columns on User not null';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.[User]
		SET LoginNotified = 'False'
		WHERE LoginNotified IS NULL;

		ALTER TABLE dbo.[User]
		ALTER COLUMN LoginNotified BIT NOT NULL;

		UPDATE dbo.[User]
		SET DateUpdated = GETDATE()
		WHERE DateUpdated IS NULL;

		IF OBJECT_ID('DF_User_DateUpdated', 'D') IS NULL
		BEGIN
			ALTER TABLE dbo.[User]
			ADD CONSTRAINT DF_User_DateUpdated DEFAULT GETDATE() FOR DateUpdated;
		END

		ALTER TABLE dbo.[User]
		ALTER COLUMN DateUpdated DATETIME NOT NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;