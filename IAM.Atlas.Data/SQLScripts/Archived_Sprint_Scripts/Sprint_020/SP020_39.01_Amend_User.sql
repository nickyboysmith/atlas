/*
 * SCRIPT: Alter Table User 
 * Author: Dan Hough
 * Created: 19/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_39.01_Amend_User.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to User table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.[User]
			ADD CreatedByUserId INT
		    , UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;