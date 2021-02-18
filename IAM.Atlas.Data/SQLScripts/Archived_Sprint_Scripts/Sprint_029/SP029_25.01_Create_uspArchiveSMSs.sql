/*
	SCRIPT: Create a stored procedure to archive SMSs
	Author: Dan Hough 
	Created: 23/11/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP029_25.01_Create_uspArchiveSMSs.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to archive SMSs';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspArchiveSMSs', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspArchiveSMSs;
END		
GO

/*
	Create uspArchiveSMSs
*/
CREATE PROCEDURE dbo.uspArchiveSMSs
AS
BEGIN
	
	BEGIN TRAN

	--Drop the temporary table in the unlikely event that it IN
	IF OBJECT_ID('tempdb..#SMSsToBeArchived') IS NOT NULL
	BEGIN
		DROP TABLE #SMSsToBeArchived
	END
	
	DECLARE @defaultArchiveDays INT
		  , @uspArchiveSMSsLastRunLog VARCHAR(20)
		  , @uspArchiveSMSs VARCHAR(20) = 'uspArchiveSMSs';
	
	SELECT @uspArchiveSMSsLastRunLog = ItemName FROM dbo.LastRunLog WHERE ItemName = @uspArchiveSMSs; --checks to see if uspArchiveSMSs is already on LastRunLog table
	SELECT @defaultArchiveDays = ArchiveSMSsAfterDaysDefault FROM dbo.SystemControl WHERE Id = 1; --Fetches the default days before archiving on SystemControl table.

	--If there's not an entry on dbo.LastRunLog for uspArchiveSMSs, then it creates one
	--If there is one, it updates the DateLastRun to now.
	IF (@uspArchiveSMSsLastRunLog IS NULL)
	  BEGIN
		  INSERT INTO dbo.LastRunLog(ItemName, ItemDescription, DateLastRun, DateCreated)
		  VALUES(@uspArchiveSMSs, 'This stored procedure looks for SMSs that are ready to be archived', GETDATE(), GETDATE())
	  END
	  ELSE
	  BEGIN
		UPDATE dbo.LastRunLog
		SET DateLastRun = GETDATE()
		WHERE ItemName = @uspArchiveSMSs;
	  END

		--Create the temporary table to hold SMSs that need to be handled

	  SELECT SS.Id
	  INTO #SMSsToBeArchived
	  FROM dbo.ScheduledSMS SS
	  LEFT JOIN dbo.ClientScheduledSMS CSS ON SS.Id = CSS.ScheduledSMSId
	  LEFT JOIN dbo.ClientOrganisation CO ON CSS.ClientId = CO.ClientId
	  LEFT JOIN dbo.Organisation O ON CO.OrganisationId = O.Id
	  LEFT JOIN dbo.OrganisationArchiveControl OAC ON O.Id = OAC.OrganisationId
	  WHERE ((SS.ScheduledSMSStateId = 2) AND (GETDATE() > DATEADD(day, OAC.ArchiveSMSsAfterDays, SS.DateSent)))
		OR  ((SS.ScheduledSMSStateId = 2) AND (O.Id IS NULL) AND (GETDATE() > DATEADD(day, @defaultArchiveDays, SS.DateSent)))

		--Write temporary table SMS to the archive SMS table

	 INSERT INTO dbo.ArchivedSMS(ScheduledSMSId
								 , Content
								 , DateCreated
								 , ScheduledSMSStateId
								 , DateSent
								 , [Disabled]
								 , ASAP
								 , SendAfterDate
								 , OrganisationId
								 , DateArchived)
	
		  SELECT  SS.Id
				 , SS.Content
				 , SS.DateCreated
				 , SS.ScheduledSMSStateId
				 , SS.DateSent
				 , SS.[Disabled]
				 , SS.ASAP
				 , SS.SendAfterDate
				 , SS.OrganisationId
				 , GETDATE()
          
		  FROM   dbo.ScheduledSMS SS
		  WHERE  SS.Id IN (SELECT Id
						   FROM   #SMSsToBeArchived)


	-- ScheduledSMSNote -> ArchivedSMSNote

	INSERT INTO dbo.ArchivedSMSNote(ScheduledSMSId
								  , Note)

		 SELECT	SSN.ScheduledSMSId
			  , SSN.Note

		   FROM dbo.ScheduledSMSNote SSN
		   WHERE SSN.ScheduledSMSId IN (SELECT Id
						                  FROM #SMSsToBeArchived)

    -- ScheduledSMSTo -> ArchivedSMSToList

	INSERT INTO dbo.ArchivedSMSToList(ScheduledSMSId
									, PhoneNumber)

		 SELECT	SSTO.ScheduledSMSId
			  , SSTO.PhoneNumber

		   FROM  dbo.ScheduledSMSTo SSTO
		   WHERE SSTO.ScheduledSMSId IN (SELECT Id
						                   FROM #SMSsToBeArchived)

	--Delete SMS table entries that have been archived

	DELETE FROM dbo.ClientScheduledSMS
    WHERE ScheduledSMSId IN (SELECT Id
							 FROM #SMSsToBeArchived)

	DELETE FROM dbo.OrganisationScheduledSMS
	WHERE ScheduledSMSId IN (SELECT Id
							 FROM #SMSsToBeArchived)

	DELETE FROM dbo.ScheduledSMSTo
	WHERE ScheduledSMSId IN (SELECT Id 
							   FROM #SMSsToBeArchived)

	DELETE FROM dbo.ScheduledSMSNote 
	WHERE ScheduledSMSId IN (SELECT Id
				               FROM #SMSsToBeArchived)

	DELETE FROM dbo.SystemScheduledSMS
	WHERE ScheduledSMSId IN (SELECT Id
							   FROM #SMSsToBeArchived)

	DELETE FROM dbo.ScheduledSMS
    WHERE Id IN (SELECT Id
				  FROM  #SMSsToBeArchived)

	--Delete the temporary table

	  DROP TABLE #SMSsToBeArchived

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

DECLARE @ScriptName VARCHAR(100) = 'SP029_25.01_Create_uspArchiveSMSs.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO