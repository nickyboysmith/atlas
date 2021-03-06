


/*
	SCRIPT: Create BlockIP
	Author: NickSmith
	Created: 13/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_13.01_CreateBlockIPTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create BlockIP Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'BlockIP'

		/*
			Create Table BlockIP
		*/
		IF OBJECT_ID('dbo.BlockIP', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.BlockIP;
		END

		CREATE TABLE BlockIP(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, BlockedIp Varchar(40) NOT NULL
			, DateBlocked DateTime NOT NULL
			, BlockDisabled bit
			, CreatedBy Varchar(320) NOT NULL
			, CreatedByUserId int NOT NULL
			, BlockDisabledByUserId int
			, Comments Varchar(400) NULL
			, CONSTRAINT FK_BlockIP_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

