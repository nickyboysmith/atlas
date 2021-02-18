/****** Script to add 'Disabled' column to 'User' table - Paul Tuck  ******/
DECLARE @ScriptName VARCHAR(100) = 'SP002_02.01_UpdateAtlasUserTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Disabled column to User table.';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
    BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF OBJECT_ID('dbo.User', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE dbo.[User]
				ADD [Disabled] BIT 
				DEFAULT 0 NOT NULL;
			END
		ELSE
			BEGIN
				PRINT 'Error running SP002_02.01_UpdateAtlasUserTables.sql: dbo.[User] table does not exist';
			END


		/***END OF SCRIPT***/
        EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
    END
ELSE
    BEGIN
        PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
