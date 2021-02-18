


/*
	SCRIPT: Create Client History Tables
	Author: Robert Newnham
	Created: 18/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_06.01_CreateClientHistoryTables.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Drop Constraints if they Exist
		*/
			EXEC dbo.uspDropTableContraints 'ClientLogType'
			EXEC dbo.uspDropTableContraints 'ClientLog'

		/*
			Create Table ClientLogType
		*/
		IF OBJECT_ID('dbo.ClientLogType', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientLogType;
		END

		CREATE TABLE ClientLogType(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name Varchar(200) NOT NULL
		);

		/*
			Create Table ClientLog
		*/
		IF OBJECT_ID('dbo.ClientLog', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientLog;
		END

		CREATE TABLE ClientLog(
			Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientLogTypeId int NOT NULL
			, RelatedId int NULL
			, Comment Varchar(100) NOT NULL
			, CONSTRAINT FK_ClientLog_ClientLogType FOREIGN KEY (ClientLogTypeId) REFERENCES ClientLogType(Id)
		);

		IF OBJECT_ID('dbo.ClientLogType', 'U') IS NOT NULL
		BEGIN
			INSERT INTO dbo.ClientLogType(Name)
			SELECT DISTINCT T.Name
			FROM (
				SELECT 'Note' AS Name
				UNION SELECT 'Payment' AS Name
				UNION SELECT 'Course' AS Name
				UNION SELECT 'Edited' AS Name
				UNION SELECT 'Other' AS Name
				) T
			LEFT JOIN dbo.ClientLogType CLT ON CLT.Name = T.Name
			WHERE CLT.Name IS NULL;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

