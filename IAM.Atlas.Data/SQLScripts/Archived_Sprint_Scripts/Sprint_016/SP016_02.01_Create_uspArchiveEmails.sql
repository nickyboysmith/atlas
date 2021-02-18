/*
	SCRIPT: Create a stored procedure to archive emails
	Author: Dan Murray 
	Created: 12/02/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP016_02.01_Create_uspArchiveEmails.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to archive emails';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already IN
*/		
IF OBJECT_ID('dbo.uspArchiveEmails', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspArchiveEmails;
END		
GO

/*
	Create uspArchiveEmails
*/
CREATE PROCEDURE uspArchiveEmails
AS
BEGIN

	BEGIN TRAN

	--Drop the temporary table in the unlikely event that it IN
	IF OBJECT_ID('tempdb..#EmailsToBeArchived') IS NOT NULL
		BEGIN
		DROP TABLE #EmailsToBeArchived
	END
	
	--Create the temporary table to hold emails that need to be handled
	--And write emails ids eligible for archiving to the temporary table (Scheduled Email)
	SELECT Id
	INTO #EmailsToBeArchived
	FROM ScheduledEmail
	WHERE ScheduledEmailStateId = 2
	  AND DateScheduledEmailStateUpdated < DATEADD(day,-14,GETDATE())

	--Write temporary table emails to the archive emails table
	--Cater for:
	-- Scheduled Email -> ArchivedEmail	 	
	
	 INSERT INTO ArchivedEmail
				(
				 ScheduledEmailId
				 ,FromName
				 ,FromEmail
				 ,Content
				 ,DateCreated
				 ,ScheduledEmailStateId
				 ,Disabled
				 ,ASAP
				 ,SendAfter
				 ,OrganisationId
				 ,DateArchived
				)
	
		  SELECT  SE.Id
				 ,SE.FromName
				 ,SE.FromEmail
				 ,SE.Content
				 ,SE.DateCreated
				 ,SE.ScheduledEmailStateId
				 ,SE.Disabled
				 ,SE.ASAP
				 ,SE.SendAfter
				 ,OSE.OrganisationId
				 ,GETDATE()
          
		  FROM   ScheduledEmail SE
		  JOIN   OrganisationScheduledEmail OSE
		  ON     SE.Id = OSE.ScheduledEmailId
		  WHERE  SE.Id IN (
							   SELECT Id
							   FROM   #EmailsToBeArchived
							  )

	-- ScheduledEmailAttachment -> ArchivedEmailAttachment

	INSERT INTO ArchivedEmailAttachment
				(
				 ScheduledEmailId,
				 FilePath	
				)

		 SELECT	 SEA.ScheduledEmailId
				,SEA.FilePath

		   FROM  ScheduledEmailAttachment SEA
		   WHERE SEA.ScheduledEmailId IN (
						                      SELECT Id
						                      FROM   #EmailsToBeArchived
						                     )

	-- ScheduledEmailNote -> ArchivedEmailNote

	INSERT INTO ArchivedEmailNote
				(
				 ScheduledEmailId
				,Note	
				)

		 SELECT	 SEN.ScheduledEmailId
				,SEN.Note

		   FROM  ScheduledEmailNote SEN
		   WHERE SEN.ScheduledEmailId IN (
						                      SELECT Id
						                      FROM   #EmailsToBeArchived
						                     )
    -- ScheduledEmailTo -> ArchivedEmailTo

	INSERT INTO ArchivedEmailTo
				(
				  ScheduledEmailId
				 ,Name	
				 ,Email
				 ,CC
				 ,BCC
			    )
		 SELECT	 SETO.ScheduledEmailId
				,SETO.Name
				,SETO.Email
				,SETO.CC
				,SETO.BCC

		   FROM  ScheduledEmailTo SETO
		   WHERE SETO.ScheduledEmailId IN (
						                       SELECT Id
						                       FROM   #EmailsToBeArchived
						                      )

	--Delete email email table entries that have been archived

	DELETE 
	FROM   ScheduledEmail 
    WHERE  Id IN (
				          SELECT Id
				          FROM   #EmailsToBeArchived
				         )

	DELETE	
	FROM  ScheduledEmailAttachment 
	WHERE ScheduledEmailId IN (
				                       SELECT Id
				                       FROM   #EmailsToBeArchived
				                      )

	DELETE 
    FROM  ScheduledEmailNote 
	WHERE ScheduledEmailId IN (
				                       SELECT Id
				                       FROM   #EmailsToBeArchived
				                      )

	DELETE	
	FROM  ScheduledEmailTo 
	WHERE ScheduledEmailId IN (
						                 SELECT Id
						                 FROM   #EmailsToBeArchived
						                )


	--Delete the temporary table in case something odd happens and it isn't deleted when the SQL instance is closed

	  DROP TABLE #EmailsToBeArchived  
	
	IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP016_02.01_Create_uspArchiveEmails.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO