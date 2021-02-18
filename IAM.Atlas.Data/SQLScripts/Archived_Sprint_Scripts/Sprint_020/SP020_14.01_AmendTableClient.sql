/*
 * SCRIPT: Alter Table Client
 * Author: Robert Newnham
 * Created: 08/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.01_AmendTableClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to Client table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF NOT EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'SelfRegistration' 
					AND Object_ID = Object_ID(N'Client'))
		BEGIN
			ALTER TABLE dbo.Client
				ADD SelfRegistration bit DEFAULT 0
		END
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;