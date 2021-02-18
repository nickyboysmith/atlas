/*
	SCRIPT: Alter stored procedure uspSystemAccessMonitor to monitor the UserLogin table
	Author: Nick Smith
	Created: 28/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_09.01_Alter_uspSystemAccessMonitor.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter uspSystemAccessMonitor to use and log the AtlasSystemId and Name';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspSystemAccessMonitor', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspSystemAccessMonitor;
END		
GO

/*
	Create uspSystemAccessMonitor
*/
CREATE PROCEDURE uspSystemAccessMonitor
AS
BEGIN

	DECLARE @TryCount int = 30;
	DECLARE @Comments varchar(50) = 'Disabled due to over 30 failed login attempts in 10 minutes';

	IF OBJECT_ID('tempdb..#UserLoginAttempts') IS NOT NULL
		BEGIN
		DROP TABLE #UserLoginAttempts
	END
	
	SELECT COUNT (*) AS Attempts
		  ,[Ip]
		  ,[UserLogin].[LoginId]
		  ,[Name]
		  ,[Success]
	INTO #UserLoginAttempts
	FROM [dbo].[UserLogin]
	INNER JOIN  [dbo].[User] ON [User].[LoginId] = [UserLogin].[LoginId]
	WHERE Success = 'False'
	AND DateCreated BETWEEN DATEADD(mi, -10, GETDATE()) AND GETDATE() 
	GROUP BY [UserLogin].[LoginId], Ip, Name, Success
	HAVING COUNT(*) > @TryCount
	
	INSERT INTO [dbo].[BlockIP] 
           ([BlockedIp]
           ,[DateBlocked]
           ,[BlockDisabled]
           ,[CreatedBy]
           ,[CreatedByUserId]
           ,[BlockDisabledByUserId]
           ,[Comments]) 
            SELECT
           [Ip]
           ,GETDATE()
           ,'False'
           , dbo.udfGetSystemUserName()
           , dbo.udfGetSystemUserId()
           , NULL
           , @Comments
    FROM
           #UserLoginAttempts
    WHERE NOT EXISTS 
			(SELECT Id FROM [dbo].[BlockIP] 
			WHERE (BlockedIp = #UserLoginAttempts.[Ip] 
			AND DateBlocked BETWEEN DATEADD(day, -1, GETDATE()) AND GETDATE()))

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_09.01_Alter_uspSystemAccessMonitor.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO