/*
	SCRIPT: Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 1
	Author: Daniel Hough
	Created: 13/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_31.01_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part1.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 1';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_AllCourseDocumentToDeleteCourseDocument_DELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllCourseDocumentToDeleteCourseDocument_DELETE;
		END
	GO

	CREATE TRIGGER TRG_AllCourseDocumentToDeleteCourseDocument_DELETE ON dbo.AllCourseDocument AFTER DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllCourseDocument', 'TRG_AllCourseDocumentToDeleteCourseDocument_DELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseDocument CD		ON CD.DocumentId = D.DocumentId
			INNER JOIN Course C					ON C.OrganisationId = D.OrganisationId
												AND C.id = CD.CourseId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_AllCourseDocumentToInsertCourseDocument_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllCourseDocumentToInsertCourseDocument_INSERT;
		END
	GO

	CREATE TRIGGER TRG_AllCourseDocumentToInsertCourseDocument_INSERT ON dbo.AllCourseDocument AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllCourseDocument', 'TRG_AllCourseDocumentToInsertCourseDocument_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO [dbo].[CourseDocument]
				([CourseId]
				,[DocumentId])
			SELECT
				C.Id			AS CourseId
				, I.DocumentId	As DocumentId
			FROM INSERTED I
			INNER JOIN Course C						ON C.OrganisationId = I.OrganisationId
			INNER JOIN vwCourseDates_SubView CD		ON  CD.CourseId = C.Id
			LEFT JOIN CourseDocument CDoc			ON CDoc.CourseId = C.Id
													AND CDoc.DocumentId = I.DocumentId
			WHERE CDoc.Id IS NULL -- Not Already There
			AND CD.StartDate > DATEADD(DAY, -7, GETDATE())

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE;
		END
	GO

	CREATE TRIGGER TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE ON dbo.AllCourseTypeDocument AFTER DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllCourseTypeDocument', 'TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseType CT			ON CT.id = D.CourseTypeId
			INNER JOIN Course C					ON C.OrganisationId = CT.OrganisationId
												AND C.CourseTypeId = D.CourseTypeId
			INNER JOIN CourseDocument CD		ON CD.CourseId = C.Id
												AND CD.DocumentId = D.DocumentId;
		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT;
		END
	GO

	CREATE TRIGGER TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT ON dbo.AllCourseTypeDocument AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllCourseTypeDocument', 'TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO [dbo].[CourseDocument]
				([CourseId]
				,[DocumentId])
			SELECT
				C.Id			AS CourseId
				, I.DocumentId	As DocumentId
			FROM INSERTED I
			INNER JOIN CourseType CT				ON CT.id = I.CourseTypeId
			INNER JOIN Course C						ON C.CourseTypeId = I.CourseTypeId
													AND C.OrganisationId = CT.OrganisationId
			INNER JOIN vwCourseDates_SubView CD		ON CD.CourseId = C.Id
			LEFT JOIN CourseDocument CDoc			ON CDoc.CourseId = C.Id
													AND CDoc.DocumentId = I.DocumentId
			WHERE CDoc.Id IS NULL -- Not Already There
			AND CD.StartDate > DATEADD(DAY, -7, GETDATE());

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE;
		END
	GO

	CREATE TRIGGER TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE ON dbo.AllTrainerDocument AFTER DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllTrainerDocument', 'TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DELETE TD 
			FROM DELETED D
			INNER JOIN TrainerDocument TD		ON TD.DocumentId = D.DocumentId
												AND TD.OrganisationId = D.OrganisationId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT;
		END
	GO

	CREATE TRIGGER TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT ON dbo.AllTrainerDocument AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'AllTrainerDocument', 'TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO [dbo].[TrainerDocument]
				([OrganisationId]
			   , [TrainerId]
			   , [DocumentId])
			SELECT
				I.OrganisationId
			   , TOrg.TrainerId
			   , I.DocumentId 
			FROM INSERTED I
			INNER JOIN TrainerOrganisation TOrg		ON TOrg.OrganisationId = I.OrganisationId
			LEFT JOIN [dbo].[TrainerDocument] TD	ON TD.OrganisationId = I.OrganisationId
													AND TD.DocumentId = I.DocumentId
			WHERE TD.Id IS NULL -- Not Already There

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT;
		END
	GO

	CREATE TRIGGER TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT ON dbo.CancelledCourse FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CancelledCourse', 'TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DELETE cqs
			FROM INSERTED I
			INNER JOIN CourseQuickSearch CQS ON CQS.CourseId = I.CourseId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_CancelledCourseToInsertCourseQuickSearch_DELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CancelledCourseToInsertCourseQuickSearch_DELETE;
		END
	GO

	CREATE TRIGGER TRG_CancelledCourseToInsertCourseQuickSearch_DELETE ON dbo.CancelledCourse AFTER DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CancelledCourse', 'TRG_CancelledCourseToInsertCourseQuickSearch_DELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @CourseId INT;

			SELECT TOP 1 @CourseId = D.CourseId
			FROM DELETED D;

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CancelledRefund_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CancelledRefund_Insert;
		END
	GO

	CREATE TRIGGER TRG_CancelledRefund_Insert ON dbo.CancelledRefund AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CancelledRefund', 'TRG_CancelledRefund_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @refundId INT
					, @organisationPaymentId INT
					, @refundPaymentId INT;

			SELECT @refundId = i.RefundId
					, @organisationPaymentId = op.Id
					, @refundPaymentId = rp.RefundPaymentId
			FROM Inserted i
			LEFT JOIN dbo.RefundPayment rp ON i.RefundId = rp.RefundId
			LEFT JOIN dbo.OrganisationPayment op ON rp.RefundPaymentId = op.PaymentId;

			IF (@organisationPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.OrganisationPayment
				WHERE Id = @organisationPaymentId;
			END

			IF(@refundPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.RefundPayment
				WHERE RefundPaymentId = @refundPaymentId;

				DELETE FROM dbo.Payment
				WHERE Id = @refundPaymentId;
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_ClientMarkedForDelete_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientMarkedForDelete_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_ClientMarkedForDelete_UPDATE ON dbo.ClientMarkedForDelete AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientMarkedForDelete', 'TRG_ClientMarkedForDelete_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF EXISTS (SELECT id FROM inserted)
			BEGIN
				/*update*/
				IF EXISTS (SELECT * FROM Deleted)
				BEGIN
					INSERT INTO  dbo.ClientMarkedForDeleteCancelled
									 (ClientId
									, RequestedByUserId
									, DateRequested
									, DeleteAfterDate
									, Note
									, CancelledByUserId
									, DateDeleteCancelled)
				
					SELECT		 i.ClientId
							   , i.RequestedByUserId
							   , i.DateRequested
							   , i.DeleteAfterDate
							   , i.Note
							   , i.CancelledByUserId
							   , DateDeleteCancelled = GETDATE()
					FROM		Inserted i 
					INNER JOIN Deleted d
					ON i.id = d.id AND (i.CancelledByUserId IS NOT NULL AND
											d.CancelledByUserId IS NULL);
				END
			END

			/*Delete row from ClientMarkedForDelete*/

			DELETE FROM dbo.ClientMarkedForDelete
			WHERE ClientMarkedForDelete.Id = (Select id from inserted);


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_ClientOnlineEmailChangeRequest_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_Update;
		END
	GO

	CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_Update ON dbo.ClientOnlineEmailChangeRequest AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOnlineEmailChangeRequest', 'TRG_ClientOnlineEmailChangeRequest_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			UPDATE COECRH
			SET COECRH.DateConfirmed = I.DateConfirmed
			FROM dbo.ClientOnlineEmailChangeRequestHistory COECRH
			INNER JOIN Inserted I	ON I.DateRequested = COECRH.DateRequested
									AND I.ClientId = COECRH.ClientId
									AND I.ClientOrganisationId = COECRH.ClientOrganisationId
									AND I.ConfirmationCode = COECRH.ConfirmationCode
			INNER JOIN Deleted D	ON D.DateRequested = I.DateRequested
									AND D.ClientId = I.ClientId
									AND D.ClientOrganisationId = I.ClientOrganisationId
									AND D.ConfirmationCode = I.ConfirmationCode
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;

			UPDATE E
			SET E.[Address] = I.NewEmailAddress
			FROM Inserted I
			INNER JOIN Deleted D			ON D.DateRequested = I.DateRequested
											AND D.ClientId = I.ClientId
											AND D.ClientOrganisationId = I.ClientOrganisationId
											AND D.ConfirmationCode = I.ConfirmationCode
			INNER JOIN dbo.ClientEmail CE	ON CE.ClientId = I.ClientId
			INNER JOIN dbo.Email E			ON E.Id = CE.EmailId
											AND E.[Address] = I.PreviousEmailAddress
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;
			
			DELETE COECR
			FROM dbo.ClientOnlineEmailChangeRequest COECR
			INNER JOIN Inserted I	ON I.DateRequested = COECR.DateRequested
									AND I.ClientId = COECR.ClientId
									AND I.ClientOrganisationId = COECR.ClientOrganisationId
									AND I.ConfirmationCode = COECR.ConfirmationCode
			INNER JOIN Deleted D	ON D.DateRequested = I.DateRequested
									AND D.ClientId = I.ClientId
									AND D.ClientOrganisationId = I.ClientOrganisationId
									AND D.ConfirmationCode = I.ConfirmationCode
			WHERE I.DateConfirmed IS NOT NULL
			AND D.DateConfirmed IS NULL
			;


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_ClientOnlineEmailChangeRequest_BeforeInsert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_BeforeInsert;
		END
	GO

	CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_BeforeInsert ON dbo.ClientOnlineEmailChangeRequest INSTEAD OF INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOnlineEmailChangeRequest', 'TRG_ClientOnlineEmailChangeRequest_BeforeInsert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @confirmationCode VARCHAR(20) 
				  , @currentYear CHAR(4)
				  , @firstCharacterCurrentMonth CHAR(1)
				  , @monthNumber CHAR(2)
				  , @lastCharacterCurrentMonth CHAR(1)
				  , @rowCount VARCHAR(12)
				  , @dateRequested DATETIME
				  , @requestedByUserId INT
				  , @clientId INT
				  , @clientOrganisationId INT
				  , @newEmailAddress VARCHAR(320)
				  , @previousEmailAddress VARCHAR(320)
				  , @clientName VARCHAR(640)
				  , @dateConfirmed DATETIME;			

			SELECT @currentYear					= CAST(DATEPART(YEAR, GETDATE()) AS CHAR) 
				 , @firstCharacterCurrentMonth  = LOWER(CAST(LEFT(DATENAME(MONTH, GETDATE()), 1) AS CHAR)) --gets lowercase first character of the month
				 , @monthNumber					= CASE WHEN DATEPART(MONTH, GETDATE()) < 10
												  THEN '0' + CAST(DATEPART(MONTH, GETDATE()) AS CHAR)
												  ELSE DATEPART(MONTH, GETDATE())
												  END --Gets the month number, adds a 0 to the front if less than ten.
				, @lastCharacterCurrentMonth    = UPPER(CAST(RIGHT(DATENAME(MONTH, GETDATE()), 1) AS CHAR)) --gets uppercase last character of the month		
				, @rowCount						= COUNT(Id)
												  FROM dbo.ClientOnlineEmailChangeRequestHistory
												  WHERE MONTH(DateRequested) = MONTH(CURRENT_TIMESTAMP) -- gets the count of rows on dbo.ClientOnlineEmailChangeRequestHistory
																										-- where DateRequested is int he current month.
			SELECT @rowCount					= @rowCount +1; --adds one to rowCount

			-- concatenates all the previously calculated variables
			SELECT @confirmationCode = @currentYear 
									 + @firstCharacterCurrentMonth 
									 + @monthNumber 
									 + @lastCharacterCurrentMonth 
									 + @rowCount; 

			--Grabs all the data being inserted.
			SELECT @dateRequested				= i.DateRequested
				 , @requestedByUserId			= i.RequestedByUserId	
				 , @clientId					= i.ClientId
				 , @clientOrganisationId		= i.ClientOrganisationId
				 , @newEmailAddress				= i.NewEmailAddress
				 , @previousEmailAddress		= i.PreviousEmailAddress
				 , @clientName					= i.ClientName
				 , @dateConfirmed				= i.DateConfirmed

			FROM Inserted i;

			-- Inserts the values along with the calculated confirmationCode
			INSERT INTO dbo.ClientOnlineEmailChangeRequest(DateRequested
														 , RequestedByUserId
														 , ClientId
														 , ClientOrganisationId
														 , NewEmailAddress
														 , PreviousEmailAddress
														 , ClientName
														 , ConfirmationCode
														 , DateConfirmed)

												VALUES (@dateRequested
													  , @requestedByUserId
													  , @clientId
													  , @clientOrganisationId
													  , @newEmailAddress
													  , @previousEmailAddress
													  , @clientName
													  , @confirmationCode
													  , @dateConfirmed)


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_ClientOnlineEmailChangeRequest_AfterInsert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_AfterInsert;
		END
	GO

	CREATE TRIGGER TRG_ClientOnlineEmailChangeRequest_AfterInsert ON dbo.ClientOnlineEmailChangeRequest AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOnlineEmailChangeRequest', 'TRG_ClientOnlineEmailChangeRequest_BeforeInsert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			DECLARE @organisationId INT
				  , @clientName VARCHAR(640)
				  , @newEmailAddress VARCHAR(320)
				  , @previousEmailAddress VARCHAR(320)
				  , @confirmationCode VARCHAR(40)
				  , @organisationName VARCHAR(320)
				  , @emailContent VARCHAR(1000)
				  , @emailSubject VARCHAR(100)
				  , @fromName VARCHAR(320)
				  , @fromEmail VARCHAR(320)
				  , @requestedByUserId INT
				  , @emailCode CHAR(20) = 'ClientEmailChangeReq'
				  , @clientNameTag CHAR(15) = '<!Client Name!>'
				  , @previousEmailTag CHAR(18) = '<!Previous Email!>'
				  , @newEmailTag CHAR(13) = '<!New Email!>'
				  , @changeRequestCodeTag CHAR(23) = '<!Change Request Code!>'
				  , @organisationNameTag CHAR(29) = '<!Organisation Display Name!>';

			SELECT @organisationId = i.ClientOrganisationId
				 , @clientName = i.ClientName
				 , @newEmailAddress = i.NewEmailAddress
				 , @previousEmailAddress = i.PreviousEmailAddress
				 , @confirmationCode = i.ConfirmationCode
				 , @requestedByUserId = i.RequestedByUserId
				 , @organisationName = od.[Name]
				 , @fromName = osc.FromName
				 , @fromEmail = osc.FromEmail
			FROM Inserted i
			LEFT JOIN dbo.OrganisationDisplay od ON i.ClientOrganisationId = od.OrganisationId
			LEFT JOIN dbo.OrganisationSystemConfiguration osc ON i.ClientOrganisationId = osc.OrganisationId;

			SELECT @emailContent = Content
				,  @emailSubject = [Subject]
			FROM dbo.OrganisationEmailTemplateMessage
			WHERE OrganisationId = @OrganisationId AND Code = @emailCode;

			SET @emailContent = REPLACE(@emailContent, @clientNameTag, @clientName); --replace tag with client name
			SET @emailContent = REPLACE(@emailContent, @previousEmailTag, @previousEmailAddress); --replace tag with old email address
			SET @emailContent = REPLACE(@emailContent, @newEmailTag, @newEmailAddress); --replace tag with new email address
			SET @emailContent = REPLACE(@emailContent, @changeRequestCodeTag, @confirmationCode); --replace tag with confirmation code
			SET @emailContent = REPLACE(@emailContent, @organisationNameTag, @organisationName); --replace tag with organisation display name

			INSERT INTO dbo.ClientOnlineEmailChangeRequestHistory(DateRequested
																, RequestedByUserId
																, ClientId
																, ClientOrganisationId
																, NewEmailAddress
																, PreviousEmailAddress
																, ClientName
																, ConfirmationCode
																, DateConfirmed)

														  SELECT  DateRequested
																, RequestedByUserId
																, ClientId
																, ClientOrganisationId
																, NewEmailAddress
																, PreviousEmailAddress
																, ClientName
																, ConfirmationCode
																, DateConfirmed

															FROM Inserted;

				EXEC dbo.uspSendEmail @requestedByUserId --int
									, @fromName --@fromName varchar(400) = null
									, @fromEmail --@fromEmailAddresses varchar(400)
									, @newEmailAddress --@toEmailAddresses varchar(400)
									, NULL --@ccEmailAddresses varchar(400)
									, NULL --@bccEmailAddresses varchar(400) 
									, @emailSubject -- @emailSubject varchar(320)
									, @emailContent --@emailContent varchar(4000)
									, 'True' --@asapFlag
									, NULL --@sendAfterDateTime DateTime = null
									, NULL --@emailServiceId int = null
									, @organisationId; --@organisationId int = null)	


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_31.01_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part1.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO