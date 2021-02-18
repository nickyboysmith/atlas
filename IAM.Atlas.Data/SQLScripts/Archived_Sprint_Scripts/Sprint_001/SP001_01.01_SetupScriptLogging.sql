
/*
	SCRIPT: SP001_01.01_SetupScriptLogging
	Author: Robert Newnham
	Created: 07/04/2015
*/



/*
	Create Table ScriptLog
*/
IF OBJECT_ID('dbo.ScriptLog', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.ScriptLog;
END

CREATE TABLE ScriptLog(
	Id int IDENTITY (1,1) PRIMARY KEY NOT NULL
	, Name varchar(400) NOT NULL 
	, Comments varchar(800)
	, DateTimeStarted datetime NOT NULL
	, DateTimeCompleted datetime
	, UserDetails varchar(200)
);

IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'ixScriptLog_Name') 
    DROP INDEX ixScriptLog_Name ON dbo.ScriptLog; 
GO

CREATE NONCLUSTERED INDEX ixScriptLog_Name  
ON ScriptLog (Name);
GO


IF OBJECT_ID('dbo.uspScriptStarted', 'P') IS NOT NULL
    DROP PROCEDURE dbo.uspScriptStarted;
GO

CREATE PROCEDURE uspScriptStarted
	@ScriptName Varchar(400)
	, @Comments  Varchar(800) = NULL
AS
	BEGIN
		INSERT INTO ScriptLog (Name, Comments, DateTimeStarted, UserDetails)
		VALUES (@ScriptName, @Comments, GETDATE(), SYSTEM_USER);
	END;
GO

IF OBJECT_ID('dbo.uspScriptCompleted', 'P') IS NOT NULL
    DROP PROCEDURE dbo.uspScriptCompleted;
GO

CREATE PROCEDURE uspScriptCompleted
	@ScriptName Varchar(400)
AS
	BEGIN
		UPDATE ScriptLog 
		SET DateTimeCompleted = GETDATE()
		WHERE Name = @ScriptName
		AND DateTimeCompleted IS NULL;
	END;
GO


IF OBJECT_ID('dbo.udfAllScriptsCompleted', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udfAllScriptsCompleted;
GO


CREATE FUNCTION udfAllScriptsCompleted()
	RETURNS BIT
AS
	BEGIN
		DEClARE @Result BIT;
		DECLARE @TotalIncomplete INT;
		
		SELECT @TotalIncomplete = COUNT(*) FROM ScriptLog WHERE DateTimeCompleted IS NULL;
		
		SET @Result = (CASE WHEN @TotalIncomplete > 0 THEN 'FALSE' ELSE 'TRUE' END);
		
		RETURN @Result;
	END;
GO


IF OBJECT_ID('dbo.udfAllScriptsCompletedExcept', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udfAllScriptsCompletedExcept;
GO


CREATE FUNCTION udfAllScriptsCompletedExcept(@ScriptName Varchar(400))
	RETURNS BIT
AS
	BEGIN
		DEClARE @Result BIT;
		DECLARE @TotalIncomplete INT;
		
		SELECT @TotalIncomplete = COUNT(*) FROM ScriptLog WHERE DateTimeCompleted IS NULL AND Name <> @ScriptName;
		
		SET @Result = (CASE WHEN @TotalIncomplete > 0 THEN 'FALSE' ELSE 'TRUE' END);
		
		RETURN @Result;
	END;
GO
