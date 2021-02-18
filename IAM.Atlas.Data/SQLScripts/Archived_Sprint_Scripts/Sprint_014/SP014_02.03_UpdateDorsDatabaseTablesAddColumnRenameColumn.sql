/*
	SCRIPT:  Update DORS Database Table
	Author:  Miles Stewart
	Created: 05/01/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP014_02.03_UpdateDorsDatabaseTablesAddColumnRenameColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename the column UserName to Login Name and add updated by user Id';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


	    /**
		 * Rename column
		 * 
		 */
		IF OBJECT_ID('dbo.DORSConnection', 'U') IS NOT NULL
        BEGIN

			ALTER TABLE dbo.[DORSConnection] 
				ADD UpdatedByUserId int
				, CONSTRAINT FK_DORSConnection_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			EXEC sp_rename 'DORSConnection.UserName', 'LoginName', 'COLUMN';
        END	
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;