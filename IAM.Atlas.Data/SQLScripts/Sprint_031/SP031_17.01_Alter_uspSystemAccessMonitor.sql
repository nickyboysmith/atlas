/*
	SCRIPT: Alter stored procedure uspSystemAccessMonitor to monitor the UserLogin table
	Author: Nick Smith
	Created: 30/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_17.01_Alter_uspSystemAccessMonitor.sql';
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
	DECLARE @Comments varchar(400) = 'Disabled due to over 30 failed login attempts in 10 minutes';

	INSERT INTO BlockIP (
		   BlockedIp
		   , DateBlocked
		   , BlockDisabled
		   , CreatedBy
		   , CreatedByUserId
		   , Comments
		   )
	SELECT 
		   Ip                           AS BlockedIp
		   , GETDATE()                  AS DateBlocked
		   , 'False'                    AS BlockDisabled
		   , dbo.udfGetSystemUserName()	AS CreatedBy
		   , dbo.udfGetSystemUserId()   AS CreatedByUserId
		   , @Comments					AS Comments
	FROM (
		   SELECT UL.Ip, COUNT(*) CNT
		   FROM UserLogin UL
		   WHERE UL.Success = 'False'
		   AND UL.DateCreated BETWEEN DATEADD(MINUTE, -10, GETDATE()) AND GETDATE()
		   GROUP BY UL.Ip
		   HAVING COUNT(*) >= @TryCount
	) T
	LEFT JOIN BlockIP BI ON BI.BlockedIp = T.Ip
	WHERE BI.Id IS NULL


END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP031_17.01_Alter_uspSystemAccessMonitor.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO