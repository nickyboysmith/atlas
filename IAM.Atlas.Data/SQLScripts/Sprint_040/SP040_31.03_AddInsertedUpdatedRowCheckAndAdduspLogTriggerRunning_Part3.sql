/*
	SCRIPT: Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 3
	Author: Daniel Hough
	Created: 13/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_31.03_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part3.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 3';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT;
		END
	GO

	CREATE TRIGGER TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT ON dbo.Document FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Document', 'TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @OriginalFileName VARCHAR(100); 
			DECLARE @Extension VARCHAR(10);
		
			SET @OriginalFileName = (SELECT TOP 1 i.OriginalFileName FROM inserted i);
		
			-- need to check for existence of a period else the extension extraction will fail.
			IF CHARINDEX('.', @OriginalFileName) > 0
			BEGIN
			
				SET @Extension = REVERSE(LEFT(REVERSE(@OriginalFileName),CHARINDEX('.',REVERSE(@OriginalFileName))-1));
			
				UPDATE Document
					SET [Type] = @Extension
					FROM inserted i
						WHERE i.Id = Document.Id AND
						(i.[Type] IS NULL OR i.[Type] = '') 

				INSERT INTO [dbo].[DocumentType]
					([Type]
					,[Description])
				SELECT
					@Extension
					,@Extension + ' Documents'
				WHERE 
					NOT EXISTS 
					(SELECT *
						FROM DocumentType dt
						WHERE (dt.[Type] = @Extension))
			END	

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_DocumentMarkedForDelete_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DocumentMarkedForDelete_Insert;
		END
	GO

	CREATE TRIGGER TRG_DocumentMarkedForDelete_Insert ON dbo.DocumentMarkedForDelete AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DocumentMarkedForDelete', 'TRG_DocumentMarkedForDelete_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#tempNotificationUsers') IS NOT NULL
			BEGIN
				DROP TABLE #tempNotificationUsers
			END
			
			IF EXISTS (SELECT id FROM inserted)
			BEGIN
		
				IF NOT EXISTS (SELECT id FROM deleted)

					DECLARE @notificationUserId INT
					DECLARE @lastNotificationSent DATETIME
					DECLARE @notificationUserEmail varchar(400)
					DECLARE @lastInsertedMessage table(lastInsertedMessageId INT)
					DECLARE @lastInsertedMessageId INT
					DECLARE @messageTitle varchar(400) = 'Documents marked for deletion.'
					DECLARE @messageBody varchar(400) = 'Documents marked for deletion.' 
														+ CHAR(13) + CHAR(10) 
														+ 'Please confirm this document should be deleted as soon as possible avoiding any possible disruption in service.'
					DECLARE @fromAddress varchar(400) = ''
					DECLARE @fromName varchar(400) = ''
					DECLARE @RequestedByUserId INT;
					DECLARE @OrganisationId INT;
					DECLARE @DocumentId INT;
					DECLARE @sendEmail BIT = 0;
					DECLARE @sendInternalMessage BIT = 0;

					SELECT @RequestedByUserId = RequestedByUserId FROM inserted
					SELECT @DocumentId = DocumentId FROM inserted
					SELECT @OrganisationId = OrganisationId FROM DocumentOwner where DocumentId = @DocumentId
			
					IF @OrganisationId IS NULL
						BEGIN
							RETURN;
						END

					SELECT	@sendEmail = SendMessagesViaEmail, 
							@sendInternalMessage = sendmessagesviainternalmessaging 
					FROM [OrganisationSystemTaskMessaging]
					INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
					WHERE organisationId = @organisationId AND st.Name = 'DOCS_NotifyDocumentMarkedForDelete'


					SELECT * INTO #tempNotificationUsers
						FROM
							(
								SELECT 
									[User].Id UserId, 
									[user].Email, 
									OAU.OrganisationId,
									OSC.FromName,
									OSC.FromEmail

								FROM organisationAdminUser OAU

								inner join [user] on userid = [user].id
								inner join organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId

								WHERE OAU.organisationId = @organisationId
							) NotificationUsersQuery
		
					SELECT @notificationUserId = min(userId) from #tempNotificationUsers

					WHILE @notificationUserId is not null
					BEGIN

							SELECT  @notificationUserEmail = Email,
									@organisationId = OrganisationId,
									@fromName = FromName,
									@fromAddress = FromEmail
									FROM #tempNotificationUsers
									WHERE UserId = @notificationUserId

							IF @sendInternalMessage = 1
								BEGIN
									INSERT INTO [Message](Title, Content, CreatedByUserId, DateCreated, MessageCategoryId, [Disabled], AllUsers)
										OUTPUT INSERTED.Id INTO @lastInsertedMessage
									VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), dbo.udfGetMessageCategoryId('WARNING') , 0, 0)
							
									SELECT @lastInsertedMessageId = lastInsertedMessageId FROM @lastInsertedMessage
										INSERT INTO MessageRecipient (MessageId, UserId) VALUES (@lastInsertedMessageId, @notificationUserId)

								END
					
							IF @sendEmail = 1
								BEGIN
									-- send an email to the organisation administrators
									EXEC	[dbo].[uspSendEmail]
												@requestedByUserId = @notificationUserId /* TODO: This bit needs to change to a General System User Id */
												, @fromName = @fromName
												, @fromEmailAddresses  = @fromAddress
												, @toEmailAddresses = @notificationUserEmail
												, @ccEmailAddresses = null
												, @bccEmailAddresses = null
												, @emailSubject = @MessageTitle
												, @emailContent = @MessageBody
												, @asapFlag = NULL
												, @sendAfterDateTime = NULL
												, @emailServiceId = NULL
												, @organisationId = @organisationId
								END

						-- get the next notification user's Id
						SELECT @notificationUserId = min(UserId) FROM #tempNotificationUsers WHERE UserId > @notificationUserId
					END

					IF OBJECT_ID('tempdb..#tempNotificationUsers') IS NOT NULL
					BEGIN
						DROP TABLE #tempNotificationUsers
					END

			END
		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_DocumentMarkedForDelete_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DocumentMarkedForDelete_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_DocumentMarkedForDelete_UPDATE ON dbo.DocumentMarkedForDelete AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DocumentMarkedForDelete', 'TRG_DocumentMarkedForDelete_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF UPDATE(CancelledByUserId)
			BEGIN
				INSERT INTO  dbo.DocumentMarkedForDeleteCancelled
									(DocumentId
								, RequestedByUserId
								, DateRequested
								, DeleteAfterDate
								, Note
								, CancelledByUserId
								, DateDeleteCancelled)
				
				SELECT		 i.DocumentId
							, i.RequestedByUserId
							, i.DateRequested
							, i.DeleteAfterDate
							, i.Note
							, i.CancelledByUserId
							, DateDeleteCancelled = GETDATE()
				FROM		Inserted i 
				INNER JOIN Deleted d
				ON i.id = d.id 
				WHERE (i.CancelledByUserId IS NOT NULL AND
						d.CancelledByUserId IS NULL)
				
				/*Delete row from DocumentMarkedForDelete*/
				DELETE dmd
				FROM dbo.DocumentMarkedForDelete dmd
				INNER JOIN Inserted i on dmd.Id = i.Id
				INNER JOIN Deleted d ON i.id = d.id 
				WHERE (i.CancelledByUserId IS NOT NULL AND
						d.CancelledByUserId IS NULL)
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



		IF OBJECT_ID('dbo.TRG_DORSClientCourseAttendance_INSERTUPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSClientCourseAttendance_INSERTUPDATE;
		END
	GO

	CREATE TRIGGER TRG_DORSClientCourseAttendance_INSERTUPDATE ON dbo.DORSClientCourseAttendance FOR INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DORSClientCourseAttendance', 'TRG_DORSClientCourseAttendance_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @dorsAttendanceStateIdentifier INT
					, @insertedClientId INT
					, @insertedCourseId INT;

			SELECT	@dorsAttendanceStateIdentifier = DORSAttendanceStateIdentifier
					, @insertedClientId = clientId
					, @insertedCourseId = courseId 
			FROM inserted;

			IF @dorsAttendanceStateIdentifier IS NOT NULL
			BEGIN
				IF NOT EXISTS(SELECT * FROM DORSAttendanceState	WHERE DORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier)
				BEGIN
					EXEC uspNewDORSAttendanceState 
						@NewDORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier
						, @TableName = 'DORSClientCourseAttendance'
						, @ClientId = @insertedClientId
						, @CourseId = @insertedCourseId;
				END
			END



		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_DORSConnection_UPDATE_AND_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSConnection_UPDATE_AND_INSERT;
		END
	GO

	CREATE TRIGGER TRG_DORSConnection_UPDATE_AND_INSERT ON dbo.DORSConnection AFTER UPDATE, INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DORSConnection', 'TRG_DORSConnection_UPDATE_AND_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @DorsCode Varchar(4) = 'DORS'
					, @DorsEnabled Varchar(4) = 'DORS Enabled'
					, @DorsDisabled Varchar(4) = 'DORS Disabled';
		
			--Update DORS Status if Exists
			UPDATE SSS
			SET   Code = @DorsCode
				, [Message] = (CASE WHEN i.[enabled] = 'true' 
									THEN @DorsEnabled
									ELSE @DorsDisabled 
									END)
				, SystemStateId = (CASE WHEN i.[enabled] = 'true' 
									THEN 1 -- Green
									ELSE 4 -- Red
									END)
				, DateUpdated = GETDATE()
				, AddedByUserId = (CASE WHEN i.UpdatedByUserId IS NULL
										THEN dbo.udfGetSystemUserId()
										ELSE i.UpdatedByUserId
										END) 
			FROM SystemStateSummary SSS 
			INNER JOIN Inserted i ON SSS.OrganisationId = i.OrganisationId
			INNER JOIN Deleted d ON i.id = d.id 
								AND i.[enabled] <> d.[enabled] 
			WHERE SSS.Code = @DorsCode;
		
			--Create DORS Status if Not Exists
			INSERT INTO  SystemStateSummary (
						OrganisationId
						, Code
						, [Message]
						, SystemStateId
						, DateUpdated
						, AddedByUserId
						)	
			SELECT		i.OrganisationId
						, @DorsCode as Code
						, (CASE WHEN i.[enabled] = 'true' 
								THEN @DorsEnabled
								ELSE @DorsDisabled 
								END) AS [Message]
						, (CASE WHEN i.[enabled] = 'true' 
								THEN 1 -- Green
								ELSE 4 -- Red
								END) AS SystemStateId
						, DateUpdated = GETDATE()
						, (CASE WHEN i.UpdatedByUserId IS NULL
								THEN dbo.udfGetSystemUserId()
								ELSE i.UpdatedByUserId
								END) AS AddedByUserId
			FROM Inserted i 
			WHERE NOT EXISTS (SELECT * 
								FROM SystemStateSummary SSS 
								WHERE SSS.OrganisationId = i.OrganisationId 
								AND SSS.Code = @DorsCode)


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_DORSLicenceCheckCompleted_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSLicenceCheckCompleted_INSERT;
		END
	GO

	CREATE TRIGGER TRG_DORSLicenceCheckCompleted_INSERT ON dbo.DORSLicenceCheckCompleted FOR INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DORSLicenceCheckCompleted', 'TRG_DORSLicenceCheckCompleted_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @dorsAttendanceStateIdentifier INT;
			DECLARE @existingAttendanceStateIdentifier INT;
			DECLARE @insertedClientId INT;

			SELECT	@dorsAttendanceStateIdentifier = DORSAttendanceStateIdentifier, 
					@insertedClientId = clientId
				FROM inserted;

			IF @dorsAttendanceStateIdentifier IS NOT NULL
				BEGIN
		
					SELECT @existingAttendanceStateIdentifier = Id 
						FROM DORSAttendanceState
						WHERE Id = @dorsAttendanceStateIdentifier;

					IF @existingAttendanceStateIdentifier IS NULL
						BEGIN
							EXEC uspNewDORSAttendanceState 
									@NewDORSAttendanceStateIdentifier = @dorsAttendanceStateIdentifier, 
									@TableName = 'DORSLicenceCheckCompleted', 
									@ClientId = @insertedClientId, 
									@CourseId = NULL;
						END
				END


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_DORSOffersWithdrawnLog_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSOffersWithdrawnLog_Insert;
		END
	GO

	CREATE TRIGGER TRG_DORSOffersWithdrawnLog_Insert ON dbo.DORSOffersWithdrawnLog AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DORSOffersWithdrawnLog', 'TRG_DORSOffersWithdrawnLog_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			INSERT INTO dbo.CourseClientRemoved
						(CourseId
						,ClientId
						,Reason
						,DORSOfferWithdrawn)

			SELECT cdc.CourseId
				,  cdc.ClientId
				, 'DORS Offer has been withdrawn'
				, 'True'
			FROM dbo.CourseDORSClient cdc
			INNER JOIN Inserted i ON i.DORSAttendanceRef = cdc.DORSAttendanceRef

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_DORSSchemeCourseType_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DORSSchemeCourseType_Insert;
		END
	GO

	CREATE TRIGGER TRG_DORSSchemeCourseType_Insert ON dbo.DORSSchemeCourseType AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DORSSchemeCourseType', 'TRG_DORSSchemeCourseType_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @courseTypeId INT;

			SELECT @courseTypeId = i.CourseTypeId
			FROM inserted i;

			EXEC dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes @courseTypeId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_EmailServiceCredential_INSERTUPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_EmailServiceCredential_INSERTUPDATE;
		END
	GO

	CREATE TRIGGER TRG_EmailServiceCredential_INSERTUPDATE ON dbo.EmailServiceCredential FOR INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'EmailServiceCredential', 'TRG_EmailServiceCredential_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @AtlasSystemUserId INT = [dbo].[udfGetSystemUserId]();

			INSERT INTO [dbo].[EmailServiceCredentialLog] (
									EmailServiceCredentialId
									, EmailServiceId
									, [Key]
									, Value
									, DateUpdated
									, UpdatedByUserId
									, Notes
									)
			SELECT 
					Id AS EmailServiceCredentialId
					, EmailServiceId
					, [Key]
					, Value
					, ISNULL(DateUpdated, GetDate()) AS DateUpdated
					, UpdatedByUserId
					, 'Details Changed From These Values' AS Notes
			FROM DELETED
			UNION
			SELECT 
					Id AS EmailServiceCredentialId
					, EmailServiceId
					, [Key]
					, Value
					, ISNULL(DateUpdated, GetDate()) AS DateUpdated
					, UpdatedByUserId
					, 'New Details Inserted' AS Notes
			FROM INSERTED;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_EmailServiceEmailsSent_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_EmailServiceEmailsSent_INSERT;
		END
	GO

	CREATE TRIGGER TRG_EmailServiceEmailsSent_INSERT ON dbo.EmailServiceEmailsSent FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'EmailServiceEmailsSent', 'TRG_EmailServiceEmailsSent_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			/* First Record Emails Sent Against a Service */
		
			INSERT INTO [dbo].[EmailServiceEmailCount] (
													EmailServiceId
													, YearSent
													, MonthSent
													, WeekNumberSent
													, NumberSent
													, NumberSentMonday
													, NumberSentTuesday
													, NumberSentWednesday
													, NumberSentThursday
													, NumberSentFriday
													, NumberSentSaturday
													, NumberSentSunday
													)
			SELECT 
				i.[EmailServiceId]
				, DATEPART(yyyy, i.[DateSent]) as YearSent
				, DATEPART(mm, i.[DateSent]) as MonthSent
				, DATEPART(ww, i.[DateSent]) as WeekNumberSent
				, Count(*) AS NumberSent
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
			FROM INSERTED i
			LEFT JOIN [dbo].[EmailServiceEmailCount] C ON ISNULL(C.EmailServiceId, -1) = ISNULL(i.[EmailServiceId], -1)
														AND C.YearSent = DATEPART(yyyy, i.[DateSent])
														AND C.MonthSent = DATEPART(mm, i.[DateSent])
														AND C.WeekNumberSent =  DATEPART(ww, i.[DateSent])
			WHERE C.Id IS NULL
			GROUP BY i.[EmailServiceId]
				, DATEPART(yyyy, i.[DateSent])
				, DATEPART(mm, i.[DateSent])
				, DATEPART(ww, i.[DateSent]);

			IF (@@ROWCOUNT <= 0)
			BEGIN
				/* No Rows Inserted Therefore need to Update*/
				UPDATE C
				SET C.NumberSent = C.NumberSent + S.NumberSent
				, C.NumberSentMonday = C.NumberSentMonday + S.NumberSentMonday
				, C.NumberSentTuesday = C.NumberSentTuesday + S.NumberSentTuesday
				, C.NumberSentWednesday = C.NumberSentWednesday + S.NumberSentWednesday
				, C.NumberSentThursday = C.NumberSentThursday + S.NumberSentThursday
				, C.NumberSentFriday = C.NumberSentFriday + S.NumberSentFriday
				, C.NumberSentSaturday = C.NumberSentSaturday + S.NumberSentSaturday
				, C.NumberSentSunday = C.NumberSentSunday + S.NumberSentSunday
				FROM [dbo].[EmailServiceEmailCount] C
				INNER JOIN (
							SELECT 
								i.[EmailServiceId]
								, DATEPART(yyyy, i.[DateSent]) as YearSent
								, DATEPART(mm, i.[DateSent]) as MonthSent
								, DATEPART(ww, i.[DateSent]) as WeekNumberSent
								, Count(*) AS NumberSent
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
							FROM INSERTED i
							GROUP BY i.[EmailServiceId]
								, DATEPART(yyyy, i.[DateSent])
								, DATEPART(mm, i.[DateSent])
								, DATEPART(ww, i.[DateSent])
							) S ON S.[EmailServiceId] = C.[EmailServiceId]
								AND S.YearSent = C.YearSent
								AND S.MonthSent = C.MonthSent
								AND S.WeekNumberSent = C.WeekNumberSent

			END
		
			/* First Record Emails Sent Against a Organisation */
		
			INSERT INTO [dbo].[OrganisationEmailCount] (
													OrganisationId
													, YearSent
													, MonthSent
													, WeekNumberSent
													, NumberSent
													, NumberSentMonday
													, NumberSentTuesday
													, NumberSentWednesday
													, NumberSentThursday
													, NumberSentFriday
													, NumberSentSaturday
													, NumberSentSunday
													)
			SELECT 
				i.[OrganisationId]
				, DATEPART(yyyy, i.[DateSent]) as YearSent
				, DATEPART(mm, i.[DateSent]) as MonthSent
				, DATEPART(ww, i.[DateSent]) as WeekNumberSent
				, Count(*) AS NumberSent
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
				, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
			FROM INSERTED i
			LEFT JOIN [dbo].[OrganisationEmailCount] C ON ISNULL(C.OrganisationId, -1) = ISNULL(i.[OrganisationId], -1)
														AND C.YearSent = DATEPART(yyyy, i.[DateSent])
														AND C.MonthSent = DATEPART(mm, i.[DateSent])
														AND C.WeekNumberSent =  DATEPART(ww, i.[DateSent])
			WHERE C.Id IS NULL
			GROUP BY i.[OrganisationId]
				, DATEPART(yyyy, i.[DateSent])
				, DATEPART(mm, i.[DateSent])
				, DATEPART(ww, i.[DateSent]);

			IF (@@ROWCOUNT <= 0)
			BEGIN
				/* No Rows Inserted Therefore need to Update*/
				UPDATE C
				SET C.NumberSent = C.NumberSent + S.NumberSent
				, C.NumberSentMonday = C.NumberSentMonday + S.NumberSentMonday
				, C.NumberSentTuesday = C.NumberSentTuesday + S.NumberSentTuesday
				, C.NumberSentWednesday = C.NumberSentWednesday + S.NumberSentWednesday
				, C.NumberSentThursday = C.NumberSentThursday + S.NumberSentThursday
				, C.NumberSentFriday = C.NumberSentFriday + S.NumberSentFriday
				, C.NumberSentSaturday = C.NumberSentSaturday + S.NumberSentSaturday
				, C.NumberSentSunday = C.NumberSentSunday + S.NumberSentSunday
				FROM [dbo].[OrganisationEmailCount] C
				INNER JOIN (
							SELECT 
								i.[OrganisationId]
								, DATEPART(yyyy, i.[DateSent]) as YearSent
								, DATEPART(mm, i.[DateSent]) as MonthSent
								, DATEPART(ww, i.[DateSent]) as WeekNumberSent
								, Count(*) AS NumberSent
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 2 THEN 1 ELSE 0 END) AS NumberSentMonday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 3 THEN 1 ELSE 0 END) AS NumberSentTuesday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 4 THEN 1 ELSE 0 END) AS NumberSentWednesday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 5 THEN 1 ELSE 0 END) AS NumberSentThursday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 6 THEN 1 ELSE 0 END) AS NumberSentFriday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 7 THEN 1 ELSE 0 END) AS NumberSentSaturday
								, SUM(CASE WHEN DATEPART(dw, i.[DateSent]) = 1 THEN 1 ELSE 0 END) AS NumberSentSunday
							FROM INSERTED i
							GROUP BY i.[OrganisationId]
								, DATEPART(yyyy, i.[DateSent])
								, DATEPART(mm, i.[DateSent])
								, DATEPART(ww, i.[DateSent])
							) S ON S.[OrganisationId] = C.[OrganisationId]
								AND S.YearSent = C.YearSent
								AND S.MonthSent = C.MonthSent
								AND S.WeekNumberSent = C.WeekNumberSent

			END

			/* Check if the Maximum Emails for the day has been sent */
			DECLARE @EmailsTodaySoFar INT = 0;
			SELECT @EmailsTodaySoFar = Count(*)
			FROM [dbo].[EmailServiceEmailsSent]
			WHERE [DateSent] >= DATEADD(dd, 0, DATEDIFF(dd, 0, GETDATE())) 
			AND [DateSent] < DATEADD(dd, 0, 1 + DATEDIFF(dd, 0, GETDATE()));
		
			IF (@EmailsTodaySoFar >= [dbo].[udfGetMaxNumberEmailsToProcessPerDay]())
			BEGIN			
				UPDATE SchedulerControl 
				SET [EmailScheduleDisabled] = 'True'
				, [DateUpdated] = GetDate()
				, [UpdatedByUserId] = [dbo].[udfGetSystemUserId]() 
				WHERE Id = 1;

				INSERT INTO [dbo].[Note] (Note, DateCreated, CreatedByUserId, NoteTypeId)
				VALUES (
					'Email Scheduler Disabled by Atlas as the Maximum Emails for the Day has been Reached.'
					, GetDate()
					, [dbo].[udfGetSystemUserId]()
					, (SELECT Id FROM [dbo].[NoteType] WHERE [Name] = 'General')
					);
			
				INSERT INTO [dbo].[SchedulerControlNote] (NoteId)
				VALUES(@@IDENTITY);

			END


		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_EmailServiceSendingFailure_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_EmailServiceSendingFailure_INSERT;
		END
	GO

	CREATE TRIGGER TRG_EmailServiceSendingFailure_INSERT ON dbo.EmailServiceSendingFailure FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'EmailServiceSendingFailure', 'TRG_EmailServiceSendingFailure_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @EmailId int;
			DECLARE @EmailServiceId int;
			DECLARE @InvalidEmail bit;
			DECLARE @NoCredits bit;
			SET @InvalidEmail = 'False';
			SET @NoCredits = 'False';
			SELECT @EmailId = CAST(
									SUBSTRING([FailureInfo]
											, CHARINDEX('Email Id: ', [FailureInfo]) + 10
											, (CHARINDEX(CHAR(13), [FailureInfo], CHARINDEX('Email Id: ', [FailureInfo]) + 10))
												- (CHARINDEX('Email Id: ', [FailureInfo]) + 10)
											) 
									AS INT)
				, @InvalidEmail = (CASE WHEN [FailureInfo] LIKE '%Invalid email address%' THEN 'True' ELSE 'False' END)
				, @NoCredits = (CASE WHEN [FailureInfo] LIKE '%Insufficient credits remaining%' THEN 'True' ELSE 'False' END)
				, @EmailServiceId = EmailServiceId
			FROM inserted
			WHERE [FailureInfo] LIKE '%Email Id: %';
		
			UPDATE [dbo].[ScheduledEmail]
			SET [ScheduledEmailStateId] = 4
			, [DateScheduledEmailStateUpdated] = Getdate()
			WHERE [Id] = @EmailId AND [ScheduledEmailStateId] <> 4;

			INSERT INTO EmailsBlockedOutgoing (Email)
			SELECT DISTINCT Email
			FROM [dbo].[ScheduledEmailTo] SETO
			WHERE SETO.[ScheduledEmailId] = @EmailId
			AND @InvalidEmail = 'True'
			AND Email NOT IN (SELECT Email FROM EmailsBlockedOutgoing WHERE OrganisationId IS NULL);

			UPDATE [dbo].[EmailService]
			SET [Disabled] = 'True'
			WHERE Id = @EmailServiceId AND @NoCredits = 'True';

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_LoginNumber_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_LoginNumber_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_LoginNumber_UPDATE ON dbo.LoginNumber AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'LoginNumber', 'TRG_LoginNumber_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
				UPDATE LN
				SET   DateAdded = GETDATE()
				FROM	LoginNumber LN INNER JOIN
				inserted i ON LN.id = i.id
				WHERE LN.DateAdded IS NULL AND i.id = LN.id

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/

	IF OBJECT_ID('dbo.TRG_Organisation_EnsureData_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_Organisation_EnsureData_INSERT;
		END
	GO

	CREATE TRIGGER TRG_Organisation_EnsureData_INSERT ON dbo.Organisation AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Organisation', 'TRG_Organisation_EnsureData_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			EXEC dbo.uspEnsureOrganisationalData;
			EXEC dbo.uspEnsureTaskActionForOrganisation;	

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_31.03_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part3.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO