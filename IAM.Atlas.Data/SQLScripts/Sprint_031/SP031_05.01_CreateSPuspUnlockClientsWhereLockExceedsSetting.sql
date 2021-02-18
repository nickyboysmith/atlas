/*
	SCRIPT: Create stored procedure uspUnlockClientsWhereLockExceedsSetting
	Author: Robert Newnham
	Created: 28/12/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_05.01_CreateSPuspUnlockClientsWhereLockExceedsSetting.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspUnlockClientsWhereLockExceedsSetting';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspUnlockClientsWhereLockExceedsSetting', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspUnlockClientsWhereLockExceedsSetting;
	END		
	GO

	/*
		Create uspUnlockClientsWhereLockExceedsSetting
	*/
	CREATE PROCEDURE [dbo].[uspUnlockClientsWhereLockExceedsSetting] 
	AS
	BEGIN
		UPDATE C
		SET C.LockedByUserId = NULL
		, C.DateTimeLocked = NULL
		FROM Client C
		LEFT JOIN ClientOrganisation CO ON CO.ClientId = C.Id
		LEFT JOIN OrganisationSelfConfiguration OSC ON OSC.OrganisationId = CO.OrganisationId
		WHERE C.LockedByUserId IS NOT NULL
		AND DATEADD(MINUTE
					, (CASE WHEN ISNULL(OSC.MaximumMinutesToLockClientsFor, -1) <= 0
						THEN 120 ELSE OSC.MaximumMinutesToLockClientsFor END)
					, ISNULL(C.DateTimeLocked, DATEADD(DAY, -2, GETDATE()))
					) <= GETDATE()
		;

		UPDATE LastRunLog
		SET DateLastRun = GETDATE()
		WHERE ItemName = 'CheckforLockedClientRecords';

	END

	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP031_05.01_CreateSPuspUnlockClientsWhereLockExceedsSetting.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO