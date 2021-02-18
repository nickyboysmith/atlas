/****** Script to add 'Disabled' column to 'User' table - Paul Tuck  ******/
DECLARE @ScriptName VARCHAR(100) = 'SP0011_15.01_UpdateUserandUserLoginTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add LastLoginAttempt to User table and DateCreated to UserLogin and Removed to DataViewColumn';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
    BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		IF OBJECT_ID('dbo.User', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE dbo.[User]
				ADD LastLoginAttempt DateTime;
			END
		ELSE
			BEGIN
				PRINT 'Error running SP0011_15.01_UpdateAtlasUserTables.sql - User Table';
			END


		IF OBJECT_ID('dbo.UserLogin', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE dbo.[UserLogin]
				ADD DateCreated DateTime DEFAULT GETDATE();
			END
		ELSE
			BEGIN
				PRINT 'Error running SP0011_15.01_UpdateAtlasUserTables.sql - UserLogin Table';
			END
			
			
		IF OBJECT_ID('dbo.DataViewColumn', 'U') IS NOT NULL
			BEGIN
				ALTER TABLE dbo.[DataViewColumn]
				ADD Removed bit;
			END
		ELSE
			BEGIN
				PRINT 'Error running SP0011_15.01_UpdateAtlasDataViewColumn.sql - DataViewColumn Table';
			END

		/***END OF SCRIPT***/
        EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
    END
ELSE
    BEGIN
        PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
