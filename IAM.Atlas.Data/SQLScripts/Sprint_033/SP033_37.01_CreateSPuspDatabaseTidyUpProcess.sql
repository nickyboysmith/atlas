/*
	SCRIPT: Create uspDatabaseTidyUpProcess
	Author: Robert Newnham
	Created: 16/02/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP033_37.01_CreateSPuspDatabaseTidyUpProcess.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspDatabaseTidyUpProcess';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspDatabaseTidyUpProcess', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspDatabaseTidyUpProcess;
	END		
	GO

	CREATE PROCEDURE [dbo].[uspDatabaseTidyUpProcess] 
	AS
	BEGIN

		--Tidy Up Seach History List. Remove any older than 1 week
		IF OBJECT_ID('tempdb..#SHistId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SHistId;
		END

		SELECT SHIN.Id AS ShinId, SHU.Id AS ShuId, SHI.Id AS ShiId
		INTO #SHistId
		FROM [dbo].[SearchHistoryItem] SHI
		INNER JOIN [dbo].[SearchHistoryUser] SHU ON SHU.Id = SHI.SearchHistoryUserId
		INNER JOIN [dbo].[SearchHistoryInterface] SHIN ON SHIN.Id = SHU.SearchHistoryInterfaceId
		WHERE SHU.CreationDate < DATEADD(WEEK, -1, GETDATE());

		DELETE SHI 
		FROM [dbo].[SearchHistoryItem] SHI
		WHERE SHI.Id IN (SELECT DISTINCT ShiId FROM #SHistId);
		
		DELETE SHU 
		FROM [dbo].[SearchHistoryUser] SHU
		WHERE SHU.Id IN (SELECT DISTINCT ShuId FROM #SHistId);
		
		DELETE SHIN 
		FROM [dbo].[SearchHistoryInterface] SHIN
		WHERE SHIN.Id IN (SELECT DISTINCT ShinId FROM #SHistId);

		IF OBJECT_ID('tempdb..#SHistId', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SHistId;
		END
		/******************************************************************************************************/

	END

	GO
	/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP033_37.01_CreateSPuspDatabaseTidyUpProcess.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	
