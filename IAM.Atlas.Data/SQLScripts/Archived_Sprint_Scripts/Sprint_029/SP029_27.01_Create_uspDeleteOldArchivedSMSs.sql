/*
	SCRIPT: Create a stored procedure to delete old archived SMSs
	Author: Dan Hough 
	Created: 23/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_27.01_Create_uspDeleteOldArchivedSMSs.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to delete old archived SMSs';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDeleteOldArchivedSMSs', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDeleteOldArchivedSMSs;
END		
GO

/*
	Create uspDeleteOldArchivedSMSs
*/
CREATE PROCEDURE dbo.uspDeleteOldArchivedSMSs
AS
BEGIN
	
	BEGIN TRAN

	--Drop the temporary table if it exists
	IF OBJECT_ID('tempdb..#SMSToBeDeleted') IS NOT NULL
	BEGIN
		DROP TABLE #SMSToBeDeleted
	END
	
	DECLARE @defaultDeleteDays INT
		  , @uspDeleteOldArchivedSMSLastRunLog VARCHAR(20)
		  , @uspDeleteOldArchivedSMSs VARCHAR(20) = 'uspDeleteOldArchivedSMSs';
	
	SELECT @uspDeleteOldArchivedSMSLastRunLog = ItemName FROM dbo.LastRunLog WHERE ItemName = @uspDeleteOldArchivedSMSs; --checks to see if uspDeleteOldArchivedEmails is already on LastRunLog table
	SELECT @defaultDeleteDays = DeleteSMSsAfterDaysDefault FROM dbo.SystemControl WHERE Id = 1; --Fetches the default days before deleting on SystemControl table.

	--If there's not an entry on dbo.LastRunLog for uspDeleteOldArchivedEmails, then it creates one
	--If there is one, it updates the DateLastRun to now.
	IF (@uspDeleteOldArchivedSMSLastRunLog IS NULL)
	  BEGIN
		  INSERT INTO dbo.LastRunLog(ItemName, ItemDescription, DateLastRun, DateCreated)
		  VALUES(@uspDeleteOldArchivedSMSs, 'This stored procedure looks for old archived SMSs that are ready to be deleted', GETDATE(), GETDATE());
	  END
	  ELSE
	  BEGIN
		UPDATE dbo.LastRunLog
		SET DateLastRun = GETDATE()
		WHERE ItemName = @uspDeleteOldArchivedSMSs;
	  END

		--Create the temporary table to hold emails that need to be handled
	  SELECT ASMS.ScheduledSMSId
	  INTO #SMSToBeDeleted
	  FROM dbo.ArchivedSMS ASMS
	  LEFT JOIN dbo.OrganisationArchiveControl OAC ON ASMS.OrganisationId = OAC.OrganisationId
	  WHERE (GETDATE() > DATEADD(day, OAC.DeleteSMSsAfterDays, ASMS.DateArchived))
		OR  ((ASMS.OrganisationId IS NULL) AND (GETDATE() > DATEADD(day, @defaultDeleteDays, ASMS.DateArchived)))


	DELETE FROM dbo.ArchivedSMSToList
    WHERE ScheduledSMSId IN (SELECT ScheduledSMSId
							   FROM #SMSToBeDeleted)

	DELETE FROM dbo.ArchivedSMSNote
	WHERE ScheduledSMSId IN (SELECT ScheduledSMSId
							   FROM   #SMSToBeDeleted)

	DELETE FROM dbo.ArchivedSMS
	WHERE ScheduledSMSId IN (SELECT ScheduledSMSId 
							 FROM #SMSToBeDeleted)

	DROP TABLE #SMSToBeDeleted

	IF @@ERROR <> 0 
	BEGIN 
		ROLLBACK TRAN 
	END	
	ELSE
	BEGIN
		COMMIT TRAN
	END
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP029_27.01_Create_uspDeleteOldArchivedSMSs.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO