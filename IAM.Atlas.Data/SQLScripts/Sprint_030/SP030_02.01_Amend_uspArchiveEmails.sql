/*
	SCRIPT: Create a stored procedure to archive emails
	Author: Dan Murray 
	Created: 12/02/2016

	Updated and fixed by Hough on 21/11/2016
	Updated again on 22/11/2016

	Updated  by Hough to include dbo.CourseVenueEmail on 01/12/2016


*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_02.01_Amend_uspArchiveEmails.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend a stored procedure to archive emails';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspArchiveEmails', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspArchiveEmails;
END		
GO

/*
	Create uspArchiveEmails
*/
CREATE PROCEDURE dbo.uspArchiveEmails
AS
BEGIN
	
	BEGIN TRAN

	--Drop the temporary table in the unlikely event that it IN
	IF OBJECT_ID('tempdb..#EmailsToBeArchived') IS NOT NULL
	BEGIN
		DROP TABLE #EmailsToBeArchived
	END
	
	DECLARE @defaultArchiveDays INT
		  , @uspArchiveEmailLastRunLog VARCHAR(20)
		  , @uspArchiveEmails VARCHAR(20) = 'uspArchiveEmails';
	
	SELECT @uspArchiveEmailLastRunLog = ItemName FROM dbo.LastRunLog WHERE ItemName = @uspArchiveEmails; --checks to see if uspArchiveEmails is already on LastRunLog table
	SELECT @defaultArchiveDays = ArchiveEmailsAfterDaysDefault FROM dbo.SystemControl WHERE Id = 1; --Fetches the default days before archiving on SystemControl table.

	--If there's not an entry on dbo.LastRunLog for uspArchiveMail, then it creates one
	--If there is one, it updates the DateLastRun to now.
	IF (@uspArchiveEmailLastRunLog IS NULL)
	  BEGIN
		  INSERT INTO dbo.LastRunLog(ItemName, ItemDescription, DateLastRun, DateCreated)
		  VALUES(@uspArchiveEmails, 'This stored procedure looks for emails that are ready to be archived', GETDATE(), GETDATE())
	  END
	  ELSE
	  BEGIN
		UPDATE dbo.LastRunLog
		SET DateLastRun = GETDATE()
		WHERE ItemName = @uspArchiveEmails
	  END

		--Create the temporary table to hold emails that need to be handled
		--And write emails ids eligible for archiving to the temporary table (Scheduled Email)
	  SELECT SE.Id
	  INTO #EmailsToBeArchived
	  FROM dbo.ScheduledEmail SE
	  LEFT JOIN dbo.ClientScheduledEmail CSE ON SE.Id = CSE.ScheduledEmailId
	  LEFT JOIN dbo.ClientOrganisation CO ON CSE.ClientId = CO.ClientId
	  LEFT JOIN dbo.Organisation O ON CO.OrganisationId = O.Id
	  LEFT JOIN dbo.OrganisationArchiveControl OAC ON O.Id = OAC.OrganisationId
	  WHERE ((SE.ScheduledEmailStateId = 2) AND (GETDATE() > DATEADD(day, OAC.ArchiveEmailsAfterDays, DateScheduledEmailStateUpdated)))
		OR  ((SE.ScheduledEmailStateId = 2) AND (O.Id IS NULL) AND (GETDATE() > DATEADD(day, @defaultArchiveDays, DateScheduledEmailStateUpdated)))

		--Write temporary table emails to the archive emails table

	 INSERT INTO dbo.ArchivedEmail(ScheduledEmailId
								 , FromName
								 , FromEmail
								 , Content
								 , DateCreated
								 , ScheduledEmailStateId
								 , [Disabled]
								 , ASAP
								 , SendAfter
								 , OrganisationId
								 , DateArchived)
	
		  SELECT  SE.Id
				 , SE.FromName
				 , SE.FromEmail
				 , SE.Content
				 , SE.DateCreated
				 , SE.ScheduledEmailStateId
				 , SE.[Disabled]
				 , SE.ASAP
				 , SE.SendAfter
				 , OSE.OrganisationId
				 , GETDATE()
          
		  FROM   dbo.ScheduledEmail SE
		  LEFT JOIN dbo.OrganisationScheduledEmail OSE ON SE.Id = OSE.ScheduledEmailId
		  WHERE  SE.Id IN (SELECT Id
						   FROM   #EmailsToBeArchived)

	-- ScheduledEmailAttachment -> ArchivedEmailAttachment

	INSERT INTO ArchivedEmailAttachment (ScheduledEmailId
										,FilePath)

		 SELECT	SEA.ScheduledEmailId
			   , SEA.FilePath

		   FROM  dbo.ScheduledEmailAttachment SEA
		   WHERE SEA.ScheduledEmailId IN (SELECT Id
						                   FROM   #EmailsToBeArchived)

	-- ScheduledEmailNote -> ArchivedEmailNote

	INSERT INTO dbo.ArchivedEmailNote(ScheduledEmailId
									, Note)

		 SELECT	SEN.ScheduledEmailId
			   ,SEN.Note

		   FROM dbo.ScheduledEmailNote SEN
		   WHERE SEN.ScheduledEmailId IN (SELECT Id
						                  FROM #EmailsToBeArchived)
    -- ScheduledEmailTo -> ArchivedEmailTo

	INSERT INTO dbo.ArchivedEmailTo(ScheduledEmailId
									,[Name]	
									,Email
									,CC
									,BCC)
		 SELECT	 SETO.ScheduledEmailId
				,SETO.[Name]
				,SETO.Email
				,SETO.CC
				,SETO.BCC

		   FROM  dbo.ScheduledEmailTo SETO
		   WHERE SETO.ScheduledEmailId IN (SELECT Id
						                   FROM #EmailsToBeArchived)

	--Delete email email table entries that have been archived

	DELETE FROM dbo.ClientScheduledEmail 
    WHERE ScheduledEmailId IN (SELECT Id
				  FROM   #EmailsToBeArchived)

	DELETE FROM dbo.OrganisationScheduledEmail
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId
							   FROM #EmailsToBeArchived)

	DELETE FROM dbo.ScheduledEmailTo 
	WHERE ScheduledEmailId IN (SELECT Id 
							   FROM #EmailsToBeArchived)

	DELETE FROM dbo.ScheduledEmailAttachment 
	WHERE ScheduledEmailId IN (SELECT Id
				               FROM #EmailsToBeArchived)

	DELETE FROM dbo.ScheduledEmailNote 
	WHERE ScheduledEmailId IN (SELECT Id
				               FROM #EmailsToBeArchived)

	DELETE FROM dbo.SystemScheduledEmail
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId
							   FROM #EmailsToBeArchived)

	DELETE FROM dbo.CourseVenueEmail
	WHERE ScheduledEmailId IN (SELECT ScheduledEmailId
							   FROM #EmailsToBeArchived)

	DELETE FROM dbo.ScheduledEmail 
    WHERE Id IN (SELECT Id
				  FROM  #EmailsToBeArchived)

	--Delete the temporary table in case something odd happens and it isn't deleted when the SQL instance is closed

	  DROP TABLE #EmailsToBeArchived

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

DECLARE @ScriptName VARCHAR(100) = 'SP030_02.01_Amend_uspArchiveEmails.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO