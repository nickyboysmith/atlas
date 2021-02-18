/*
	SCRIPT: Create Stored procedure uspArchiveClientEmail
	Author: Dan Hough
	Created: 14/11/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_19.01_CreateSP_uspArchiveClientEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored Procedure uspArchiveClientEmail';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspArchiveClientEmail', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspArchiveClientEmail;
END		
GO
	/*
		Create uspArchiveClientEmail
	*/
	
	CREATE PROCEDURE dbo.uspArchiveClientEmail
	AS
	BEGIN
		DECLARE @ProcedureName VARCHAR(200) = 'uspArchiveClientEmail'
				, @ErrorMessage VARCHAR(4000) = ''
				, @ErrorNumber INT = NULL
				, @ErrorSeverity INT = NULL
				, @ErrorState INT = NULL
				, @ErrorProcedure VARCHAR(140) = NULL
				, @ErrorLine INT = NULL;

		BEGIN TRY
			DECLARE @EmailsToArchive TABLE (ScheduledEmailId INT, ScheduledEmailToId INT, ScheduledEmailNoteId INT, ScheduledEmailAttachmentId INT, OrganisationId INT);

			INSERT INTO @EmailsToArchive (ScheduledEmailId, ScheduledEmailToId, ScheduledEmailNoteId, ScheduledEmailAttachmentId, OrganisationId)
			SELECT DISTINCT SE.Id, SCET.Id, SCEN.Id, SCEA.Id, CO.OrganisationId
			FROM ScheduledEmail SE
			INNER JOIN dbo.ScheduledEmailTo SCET ON SE.Id = SCET.ScheduledEmailId
			INNER JOIN dbo.Email E ON SCET.Email = E.[Address]
			INNER JOIN dbo.ClientScheduledEmail CSE ON SE.Id = CSE.ScheduledEmailId
			INNER JOIN dbo.ClientOrganisation CO ON CSE.ClientId = CO.ClientId
			INNER JOIN dbo.OrganisationSystemConfiguration OSC ON CO.OrganisationId = OSC.OrganisationId
			LEFT JOIN dbo.ScheduledEmailNote SCEN ON SE.Id = SCEN.ScheduledEmailId
			LEFT JOIN dbo.ScheduledEmailAttachment SCEA ON SE.Id = SCEA.ScheduledEmailId
			WHERE CONVERT(DATE, DATEADD(DAY, OSC.ArchiveClientEmailsAfterDays, DateScheduledEmailStateUpdated)) <= GETDATE();

			/********************************************************************************************************************/

			--Insert summary

			INSERT INTO dbo.ClientArchivedEmail (DateTimeArchived, EmailCreationDate, EmailSentDate, EmailSubject, SendToAddress)
			SELECT GETDATE(), SE.DateCreated, SE.DateScheduledEmailStateUpdated, SE.[Subject], SCET.Email
			FROM dbo.ScheduledEmail SE
			INNER JOIN dbo.ScheduledEmailTo SCET ON SE.Id = SCET.ScheduledEmailId
			INNER JOIN @EmailsToArchive ETA ON SE.Id = ETA.ScheduledEmailId
												AND SCET.Id = ETA.ScheduledEmailToId;

			--------------------------------------------------------------------------------------------------

			INSERT INTO 
				ArchivedEmail (ScheduledEmailId
								, FromName
								, FromEmail
								, Content
								, DateCreated
								, ScheduledEmailStateId
								, [Disabled]
								, ASAP
								, SendAfter
								, OrganisationId
								, DateArchived
								, [Subject]
								, DateScheduledEmailStateUpdated)

			SELECT 
				SE.Id 
				, SE.FromName
				, SE.FromEmail
				, SE.Content
				, SE.DateCreated
				, SE.ScheduledEmailStateId
				, SE.[Disabled]
				, SE.ASAP
				, SE.SendAfter
				, ETA.OrganisationId
				, GETDATE()
				, SE.[Subject]
				, SE.DateScheduledEmailStateUpdated
			FROM ScheduledEmail SE
			INNER JOIN @EmailsToArchive ETA ON SE.Id = ETA.ScheduledEmailId;

			INSERT INTO ArchivedEmailAttachment (ScheduledEmailId, FilePath)
			SELECT ScheduledEmailId, FilePath
			FROM ScheduledEmailAttachment
			WHERE Id IN (SELECT ScheduledEmailAttachmentId FROM @EmailsToArchive)

			INSERT INTO ArchivedEmailNote (ScheduledEmailId, Note)
			SELECT ScheduledEmailId, Note
			FROM ScheduledEmailNote
			WHERE Id IN (SELECT ScheduledEmailNoteId FROM @EmailsToArchive)

			INSERT INTO  ArchivedEmailTo (ScheduledEmailId, [Name], Email, CC, BCC)
			SELECT ScheduledEmailId, [Name], Email, CC, BCC
			FROM ScheduledEmailTo
			WHERE Id IN (SELECT ScheduledEmailToId FROM @EmailsToArchive)

			/********************************************************************************************************************/

			--Delete scheduled emails from tables

			DELETE FROM ScheduledEmailTo
			WHERE ScheduledEmailId IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			DELETE FROM ScheduledEmailAttachment 
			WHERE ScheduledEmailId IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			DELETE FROM ScheduledEmailNote
			WHERE ScheduledEmailId IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			DELETE FROM ClientScheduledEmail
			WHERE ScheduledEmailId IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			DELETE FROM CourseClientEmailReminder
			WHERE ScheduledEmailId IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			DELETE FROM ScheduledEmail 
			WHERE Id IN (SELECT ScheduledEmailId FROM @EmailsToArchive);

			/********************************************************************************************************************/
			END TRY  
			BEGIN CATCH  
				SELECT 
					@ErrorNumber = ERROR_NUMBER()
					, @ErrorSeverity = ERROR_SEVERITY()
					, @ErrorState = ERROR_STATE()
					, @ErrorProcedure = ERROR_PROCEDURE()
					, @ErrorLine = ERROR_LINE()
					, @ErrorMessage = ERROR_MESSAGE()
					;

				EXECUTE uspSaveDatabaseError @ProcedureName
											, @ErrorMessage
											, @ErrorNumber
											, @ErrorSeverity
											, @ErrorState
											, @ErrorProcedure
											, @ErrorLine
											;
			END CATCH
	END --End SP
	GO 

	
DECLARE @ScriptName VARCHAR(100) = 'SP045_19.01_CreateSP_uspArchiveClientEmail.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO