/*
	SCRIPT: Create Client Change Log Table
	Author: Robert Newnham
	Created: 17/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_31.02_CreateClientChangeLogTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Client Change Log Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientChangeLog'

		/*
			Create Table ClientLog
		*/
		IF OBJECT_ID('dbo.ClientChangeLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientChangeLog;
		END
		
		CREATE TABLE ClientChangeLog(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL 
			, ChangeType VARCHAR(20) NOT NULL
			, ColumnName VARCHAR(40) NULL
			, PreviousValue VARCHAR(400) NULL
			, NewValue VARCHAR(400) NULL
			, Comment VARCHAR(1000) NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, AssociatedUserId INT NULL
			, CONSTRAINT FK_ClientChangeLog_User FOREIGN KEY (AssociatedUserId) REFERENCES [User](Id)
			, INDEX IX_ClientChangeLogClientId NONCLUSTERED (ClientId)
			, INDEX IX_ClientChangeLogClientIdChangeType NONCLUSTERED (ClientId, ChangeType)
			, INDEX IX_ClientChangeLogClientIdColumnName NONCLUSTERED (ClientId, ColumnName)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

