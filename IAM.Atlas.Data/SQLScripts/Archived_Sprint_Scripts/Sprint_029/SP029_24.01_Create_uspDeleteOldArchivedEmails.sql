/*
	SCRIPT: Create a stored procedure to delete old archived emails
	Author: Dan Hough 
	Created: 22/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_24.01_Create_uspDeleteOldArchivedEmails.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to delete old archived emails';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspDeleteOldArchivedEmails', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspDeleteOldArchivedEmails;
END		
GO

/*
	Create uspArchiveEmails
*/
CREATE PROCEDURE dbo.uspDeleteOldArchivedEmails
AS
BEGIN
	
	BEGIN TRAN

	--Drop the temporary table if it exists
	IF OBJECT_ID('tempdb..#EmailsToBeDeleted') IS NOT NULL
	BEGIN
		DROP TABLE #EmailsToBeDeleted
	END
	
	DECLARE @defaultDeleteDays INT
		  , @uspDeleteOldArchivedEmailsLastRunLog VARCHAR(20)
		  , @uspDeleteOldArchivedEmails VARCHAR(20) = 'uspDeleteOldArchivedEmails';
	
	SELECT @uspDeleteOldArchivedEmailsLastRunLog = ItemName FROM dbo.LastRunLog WHERE ItemName = @uspDeleteOldArchivedEmails; --checks to see if uspDeleteOldArchivedEmails is already on LastRunLog table
	SELECT @defaultDeleteDays = DeleteEmailsAfterDaysDefault FROM dbo.SystemControl WHERE Id = 1; --Fetches the default days before deleting on SystemControl table.

	--If there's not an entry on dbo.LastRunLog for uspDeleteOldArchivedEmails, then it creates one
	--If there is one, it updates the DateLastRun to now.
	IF (@uspDeleteOldArchivedEmailsLastRunLog IS NULL)
	  BEGIN
		  INSERT INTO dbo.LastRunLog(ItemName, ItemDescription, DateLastRun, DateCreated)
		  VALUES(@uspDeleteOldArchivedEmails, 'This stored procedure looks for old archived emails that are ready to be deleted', GETDATE(), GETDATE());
	  END
	  ELSE
	  BEGIN
		UPDATE dbo.LastRunLog
		SET DateLastRun = GETDATE()
		WHERE ItemName = @uspDeleteOldArchivedEmails;
	  END

		--Create the temporary table to hold emails that need to be handled
	  SELECT AE.ScheduledEmailId
	  INTO #EmailsToBeDeleted
	  FROM dbo.ArchivedEmail AE
	  LEFT JOIN dbo.OrganisationArchiveControl OAC ON AE.OrganisationId = OAC.OrganisationId
	  WHERE (GETDATE() > DATEADD(day, OAC.DeleteEmailsAfterDays, AE.DateArchived))
		OR  ((AE.OrganisationId IS NULL) AND (GETDATE() > DATEADD(day, @defaultDeleteDays, AE.DateArchived)))


	DELETE FROM dbo.ArchivedEmailTo
    WHERE ScheduledEmailId IN (SELECT ScheduledEmailId
							   FROM   #EmailsToBeDeleted)

	DELETE FROM dbo.ArchivedEmailNote
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId
							   FROM   #EmailsToBeDeleted)

	DELETE FROM dbo.ArchivedEmailAttachment
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId 
							   FROM #EmailsToBeDeleted)

	DELETE FROM dbo.ArchivedEmailAttachment
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId 
							   FROM #EmailsToBeDeleted)

	DROP TABLE #EmailsToBeDeleted

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

DECLARE @ScriptName VARCHAR(100) = 'SP029_24.01_Create_uspDeleteOldArchivedEmails.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO