
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SET QUOTED_IDENTIFIER ON


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	
GO
ALTER TRIGGER TRG_Trainer_InsertUpdate ON dbo.Trainer AFTER UPDATE, INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Trainer', 'TRG_Trainer_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @firstName = FirstName
					, @surname = Surname
					, @capitalisedFirstName = LEFT(UPPER(@firstName), 1)+RIGHT(@firstName, LEN(@firstName)-1)
					, @capitalisedSurname = LEFT(UPPER(@surname), 1)+RIGHT(@surname, LEN(@surname)-1)
					, @trainerId = I.Id
			FROM Inserted i;

			--Updates Trainer Name if the cases don't match
			-- Latin1_General_CS_AS is case sensitive.
			IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
				OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
			BEGIN
				UPDATE dbo.Trainer
				SET FirstName = @capitalisedFirstName
					, Surname = @capitalisedSurname
				WHERE Id = @trainerId;
			END

			IF NOT EXISTS(SELECT * FROM dbo.TrainerSetting WHERE TrainerId = @trainerId)
			BEGIN
				INSERT INTO TrainerSetting (TrainerId, ProfileEditing, CourseTypeEditing)
				VALUES (@trainerId, 'True', 'False')
			END

			EXEC dbo.uspEnsureTrainerLimitationAndSummaryDataSetup;

		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_LoginNumber_UPDATE ON LoginNumber AFTER INSERT
AS
	
BEGIN

	UPDATE LN

	SET   DateAdded = GETDATE()
	FROM	LoginNumber LN INNER JOIN
	inserted i ON LN.id = i.id
	WHERE LN.DateAdded IS NULL AND i.id = LN.id

END

		
GO
ALTER TRIGGER TRG_DORSOffersWithdrawnLog_Insert ON dbo.DORSOffersWithdrawnLog AFTER INSERT
AS

BEGIN

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

END

		
GO
ALTER TRIGGER TRG_DORSSchemeCourseType_Insert ON dbo.DORSSchemeCourseType AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT;

	SELECT @courseTypeId = i.CourseTypeId
	FROM inserted i;

	EXEC dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes @courseTypeId;
END
		
GO
ALTER TRIGGER TRG_SystemFeatureItem_InsertUpdateDelete ON SystemFeatureItem AFTER INSERT, UPDATE, DELETE
		AS

		BEGIN

			DECLARE @deletedId INT
			DECLARE @insertedId INT

			SELECT @insertedId = i.id, @deletedId = d.id
			FROM inserted i 
			FULL OUTER JOIN deleted d ON i.Id = d.Id

			IF
				(@insertedId IS NULL)
					EXEC dbo.uspUpdateSystemInformation @deletedId

			ELSE
					EXEC dbo.uspUpdateSystemInformation @insertedId

		END

		
GO
ALTER TRIGGER TRG_NetcallAgent_Insert ON dbo.NetcallAgent AFTER INSERT
AS

BEGIN

	UPDATE dbo.NetcallAgent
	SET [Disabled] = 'True'
	FROM Inserted i
	WHERE (i.DefaultCallingNumber IS NULL OR i.DefaultCallingNumber = '') AND (i.Id = NetCallAgent.Id)

END

		
GO
ALTER TRIGGER TRG_VenueToInsertVenueRegion_INSERT ON Venue FOR INSERT
AS

		IF OBJECT_ID('tempdb..#OrganisationRegionCount') IS NOT NULL
			BEGIN
			DROP TABLE #OrganisationRegionCount
		END

		SELECT i.OrganisationId AS OrganisationId 
		       ,COUNT(*) AS OrgRegCount
		INTO #OrganisationRegionCount
		FROM inserted i 
		INNER JOIN OrganisationRegion orgr ON orgr.OrganisationId = i.OrganisationId
		GROUP BY i.OrganisationId

		INSERT INTO [dbo].[VenueRegion]
           ([VenueId]
           ,[RegionId])
		SELECT
			i.Id
           ,orgr.RegionId 
		FROM
           Venue i
		   INNER JOIN OrganisationRegion orgr on i.OrganisationId = orgr.OrganisationId
		   INNER JOIN #OrganisationRegionCount orc on i.OrganisationId = orc.OrganisationId
		WHERE 
			 (orc.OrgRegCount = 1) AND 
			 NOT EXISTS 
				(SELECT *
					FROM VenueRegion vr
					WHERE (i.Id = vr.VenueId ) AND 
						(orgr.RegionId = vr.RegionId))

	
GO
ALTER TRIGGER TRG_CourseClientDocumentRequest_InsertUpdate ON dbo.CourseClient AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClient', 'TRG_CourseClientDocumentRequest_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = CourseId FROM inserted i;
			SELECT @courseSignInReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseSignInDescription;
			SELECT @courseRegisterReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseRegisterDescription;

			IF(@courseId IS NOT NULL AND @courseSignInReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseSignInReqTypeId;
			END
			IF(@courseId IS NOT NULL AND @courseRegisterReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseRegisterReqTypeId;
			END

		END --END PROCESS
	END

		
GO
ALTER TRIGGER TRG_NetcallAgent_Update ON dbo.NetcallAgent AFTER UPDATE
AS

BEGIN
	IF UPDATE (DefaultCallingNumber)
	BEGIN
		INSERT INTO dbo.NetcallAgentNumberHistory
				   (NetcallAgentId
				   ,PreviousCallingNumber
				   ,NewCallingNumber
				   ,DateChanged
				   ,ChangedByUserId)

		SELECT d.Id
			, d.DefaultCallingNumber
			, i.DefaultCallingNumber
			, GETDATE()
			, i.UpdateByUserId
		FROM Deleted d
		INNER JOIN Inserted i ON d.id = i.id

		UPDATE dbo.NetcallAgent
		SET [Disabled] = 'True'
		FROM Inserted i
		WHERE (i.DefaultCallingNumber IS NULL OR i.DefaultCallingNumber = '') AND (NetCallAgent.Id = i.Id)

	END

END

	
GO
ALTER TRIGGER TRG_CourseTrainerDocumentRequest_InsertUpdate ON dbo.CourseTrainer AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainerDocumentRequest_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = CourseId FROM inserted i;
			SELECT @courseSignInReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseSignInDescription;
			SELECT @courseRegisterReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseRegisterDescription;

			IF(@courseId IS NOT NULL AND @courseSignInReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseSignInReqTypeId;
			END
			IF(@courseId IS NOT NULL AND @courseRegisterReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseRegisterReqTypeId;
			END

		END --END PROCESS
	END

		
GO
ALTER TRIGGER dbo.TRG_CourseType_Insert ON dbo.CourseType AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT
		  , @title VARCHAR(200)
		  , @code VARCHAR(20)
		  , @description VARCHAR(1000)
		  , @organisationId INT
		  , @disabled BIT
		  , @dorsOnly BIT
		  , @userId INT;

	SELECT @courseTypeId = Id
		 , @title = Title
		 , @code = Code
		 , @description = [Description]
		 , @organisationId = OrganisationId
		 , @disabled = [Disabled]
		 , @dorsOnly = DORSOnly
	FROM Inserted i;

	INSERT INTO dbo.CourseTypeFee(OrganisationId
								, CourseTypeId
								, EffectiveDate 
								, CourseFee
								, BookingSupplement
								, PaymentDays
								, AddedByUserId
								, DateAdded
								, [Disabled])

					VALUES(@organisationId
						 , @courseTypeId
						 , GETDATE()
						 , 0
						 , 0
						 , 0
						 , dbo.udfGetSystemUserId()
						 , GETDATE()
						 , 0)
	
	
END
	
GO
ALTER TRIGGER TRG_CourseClientRemovedDocumentRequest_Insert ON dbo.CourseClientRemoved AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClientRemoved', 'TRG_CourseClientRemovedDocumentRequest_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = Courseid FROM inserted i;
			SELECT @courseSignInReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseSignInDescription;
			SELECT @courseRegisterReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseRegisterDescription;

			IF(@courseId IS NOT NULL AND @courseSignInReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseSignInReqTypeId;
			END
			IF(@courseId IS NOT NULL AND @courseRegisterReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseRegisterReqTypeId;
			END

		END --END PROCESS
	END

	
GO
ALTER TRIGGER TRG_CourseClientTransferredDocumentRequest_Insert ON dbo.CourseClientTransferred AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClientTransferred', 'dbo.TRG_CourseClientTransferredDocumentRequest_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = TransferToCourseId FROM inserted i;
			SELECT @courseSignInReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseSignInDescription;
			SELECT @courseRegisterReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseRegisterDescription;

			IF(@courseId IS NOT NULL AND @courseSignInReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseSignInReqTypeId;
			END
			IF(@courseId IS NOT NULL AND @courseRegisterReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseRegisterReqTypeId;
			END

		END --END PROCESS
	END

	
GO
ALTER TRIGGER TRG_AllCourseDocumentToInsertCourseDocument_INSERT ON AllCourseDocument AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
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

	END

	
GO
ALTER TRIGGER TRG_AllCourseDocumentToDeleteCourseDocument_DELETE ON AllCourseDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseDocument CD		ON CD.DocumentId = D.DocumentId
			INNER JOIN Course C					ON C.OrganisationId = D.OrganisationId
												AND C.id = CD.CourseId;
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_AllCourseTypeDocumentToInsertCourseDocument_INSERT ON AllCourseTypeDocument AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
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

	END

	
GO
ALTER TRIGGER TRG_AllCourseTypeDocumentToDeleteCourseDocument_DELETE ON AllCourseTypeDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE CD 
			FROM DELETED D
			INNER JOIN CourseType CT			ON CT.id = D.CourseTypeId
			INNER JOIN Course C					ON C.OrganisationId = CT.OrganisationId
												AND C.CourseTypeId = D.CourseTypeId
			INNER JOIN CourseDocument CD		ON CD.CourseId = C.Id
												AND CD.DocumentId = D.DocumentId;
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_AllTrainerDocumentToInsertTrainerDocument_INSERT ON AllTrainerDocument AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
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
	END

	
GO
ALTER TRIGGER TRG_CourseNote_Insert ON dbo.CourseNote AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseNote', 'TRG_CourseNote_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE CN
				SET CN.[DateCreated] = GETDATE()
				, CN.Removed = ISNULL(CN.Removed, 'False')
			FROM CourseNote CN
			INNER JOIN INSERTED I ON I.Id = CN.Id;
			
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_AllTrainerDocumentToDeleteTrainerDocument_DELETE ON AllTrainerDocument AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN     
			DELETE TD 
			FROM DELETED D
			INNER JOIN TrainerDocument TD		ON TD.DocumentId = D.DocumentId
												AND TD.OrganisationId = D.OrganisationId;
		END --END PROCESS
	END



	
GO
ALTER TRIGGER TRG_User_UPDATE ON [User] FOR UPDATE
	AS
	BEGIN
		/* NOTE The New User record send email is done in table OrganisationUser */
		DECLARE @UserId INT;

		SELECT @UserId = I.Id FROM inserted I;
		
		EXEC dbo.[uspCheckUser] @userId = @UserId;

	END

	
GO
ALTER TRIGGER TRG_ClientOrganisation_ClientQuickSearchINSERTUPDATEDELETE ON ClientOrganisation FOR INSERT, UPDATE, DELETE
	AS
		DECLARE @ClientId int;
		DECLARE @InsertId int;
		DECLARE @DeleteId int;
	
		SELECT @InsertId = i.ClientId FROM inserted i;
		SELECT @DeleteId = d.ClientId FROM deleted d;
	
		SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

		EXEC dbo.uspRefreshClientQuickSearchData @ClientId;

	
GO
ALTER TRIGGER TRG_SchedulerControl_UPDATE ON SchedulerControl FOR UPDATE
	AS	
		DECLARE @EmailCode CHAR(4) = 'EM01'
				, @ReportCode CHAR(4) = 'RP01'
				, @ArchiveCode CHAR(4) = 'AR01'
				, @SMSCode CHAR(4) = 'SM01'
				, @ArchiveCode2 CHAR(4) = 'AR02' --Email
				, @ArchiveCode3 CHAR(4) = 'AR03' --SMS
				;
		DELETE [dbo].[SystemStateSummary]
		WHERE CODE IN (@EmailCode, @ReportCode, @ArchiveCode, @SMSCode);
		
		IF OBJECT_ID('tempdb..#SchedControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #SchedControl;
		END

		SELECT *
		INTO #SchedControl
		FROM (
			SELECT @EmailCode AS Code
				, (CASE WHEN [EmailScheduleDisabled] = 'True' 
						THEN 'Email Scheduler Disabled'
						ELSE 'Email Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [EmailScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1 
			AND UPDATE(EmailScheduleDisabled)
			UNION 
			SELECT @ReportCode AS Code
				, (CASE WHEN [ReportScheduleDisabled] = 'True' 
						THEN 'Report Scheduler Disabled'
						ELSE 'Report Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [ReportScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			AND UPDATE(ReportScheduleDisabled) 
			UNION 
			SELECT @ArchiveCode AS Code
				, (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
						THEN 'Archive Scheduler Disabled'
						ELSE 'Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [ArchiveScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			AND UPDATE(ArchiveScheduleDisabled) 
			UNION 
			SELECT @SMSCode AS Code
				, (CASE WHEN [SMSScheduleDisabled] = 'True' 
						THEN 'SMS Scheduler Disabled'
						ELSE 'SMS Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [SMSScheduleDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			AND UPDATE(SMSScheduleDisabled) 
			UNION 
			SELECT @ArchiveCode2 AS Code
				, (CASE WHEN [EmailArchiveDisabled] = 'True' 
						THEN 'Email Archive Scheduler Disabled'
						ELSE 'Email Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [EmailArchiveDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			AND UPDATE(EmailArchiveDisabled) 
			UNION 
			SELECT @ArchiveCode3 AS Code
				, (CASE WHEN [SMSArchiveDisabled] = 'True' 
						THEN 'SMS Archive Scheduler Disabled'
						ELSE 'SMS Archive Scheduler Running'
						END)					AS [Message]
				, (CASE WHEN [SMSArchiveDisabled] = 'True' 
						THEN (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Amber')
						ELSE (SELECT Id FROM [dbo].[SystemState] WHERE [Colour] = 'Green')
						END)					AS [SystemStateId]
				, GetDate()						AS [DateUpdated]
				, [dbo].[udfGetSystemUserId]()	AS [UpdatedByUserId]
				, NULL							AS OrganisationId
			FROM [dbo].[SchedulerControl] SC WHERE SC.Id = 1
			AND UPDATE(SMSArchiveDisabled) 
			) SchedControl;
			
		INSERT INTO [dbo].[SystemStateSummary] (
				[OrganisationId]
				, [Code]
				, [Message]
				, [SystemStateId]
				, [DateUpdated]
				, [AddedByUserId]
				)
		SELECT DISTINCT O.Id AS [OrganisationId]
				, SC.[Code]
				, SC.[Message]
				, SC.[SystemStateId]
				, SC.[DateUpdated]
				, [dbo].[udfGetSystemUserId]() AS [AddedByUserId]
		FROM Organisation O
		INNER JOIN #SchedControl SC ON SC.OrganisationId = O.Id
									OR  SC.OrganisationId IS NULL


		
GO
ALTER TRIGGER TRG_UserFeedbackToSendEmailToUserAndAtlasAdministration_INSERT ON UserFeedback FOR INSERT
AS		
		
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);

		DECLARE @userId INT;
		DECLARE @OrganisationId INT;
		DECLARE @fromName VARCHAR(320);
		DECLARE @fromEmailAddresses VARCHAR(320);
		DECLARE @emailContent VARCHAR(4000);
		DECLARE @responseRequired VARCHAR(3);
		DECLARE @ccEmailAddresses VARCHAR(320);
		DECLARE @bccEmailAddresses VARCHAR(320);
		DECLARE @toEmailAddresses VARCHAR(320);
		DECLARE @toEmailName VARCHAR(320);
		DECLARE @feedbackEmail VARCHAR(320);
		DECLARE @usersEmail VARCHAR(320);
		DECLARE @usersName VARCHAR(320);
		DECLARE @usersURL VARCHAR(200);
		DECLARE @creationDate DATETIME;
		DECLARE @feedbackSubject VARCHAR(500);
		DECLARE @feedbackTitle VARCHAR(500) = 'Feedback Acknowledgement';
		DECLARE @feedbackBody VARCHAR(1000);

		/* ATLAS ADMIN SYSTEM CONTROL */
		DECLARE @atlasSystemFromName VARCHAR(320);
		DECLARE @atlasSystemFromEmail VARCHAR(320);
		DECLARE @atlasToEmailName VARCHAR(320);
		DECLARE @atlasToEmailAddress VARCHAR(320);

		/* NOT USED */
		DECLARE @asapFlag BIT = 'false'
		DECLARE	@sendAfterDateTime DATETIME = null
		DECLARE	@emailServiceId INT = null

		SELECT TOP 1 @userId = i.UserId
				, @fromName = osc.FromName
				, @fromEmailAddresses = osc.FromEmail
				, @usersName = u.Name
				, @feedbackEmail = i.Email
				, @usersEmail = u.Email
				, @feedbackTitle = i.Title
				, @feedbackBody = i.Body
				, @OrganisationId = ou.OrganisationId
				, @responseRequired = CASE WHEN i.ResponseRequired = 1 THEN 'Yes' ELSE 'No' END
				, @usersURL = i.CurrentURL
				, @creationDate = i.CreationDate
		FROM
				inserted i
				INNER JOIN [User] u ON i.UserId = u.Id
				INNER JOIN OrganisationUser ou ON i.UserId = ou.UserId
				LEFT JOIN OrganisationSystemConfiguration osc ON ou.OrganisationId = osc.OrganisationId
		
		IF (@feedbackEmail IS NULL OR @feedbackEmail = '')
			SET @toEmailAddresses = @usersEmail;	/* check usersEmail is valid ? */
		ELSE
			SET @toEmailAddresses = @feedbackEmail;

		SET @emailContent = 'This is an Automated reply.' + @NewLineChar + 'We have received your Feedback. Thank you.';

		IF (@responseRequired = 'Yes') 
			BEGIN

				SET @emailContent = @emailContent + @NewLineChar + 'We note that you have requested a follow up call or message. We will endeavour to get back to you as soon as possible.';
				SET @emailContent = @emailContent + @NewLineChar + 'Your Feedback was as follow:';
				SET @emailContent = @emailContent + @NewLineChar + 'Title: ' + @feedbackTitle + @NewLineChar + @NewLineChar + @feedbackBody;
			END

		EXEC dbo.uspSendEmail @UserId
							, @fromName
							, @fromEmailAddresses
							, @toEmailAddresses
							, @ccEmailAddresses
							, @bccEmailAddresses
							, @feedbackTitle
							, @emailContent
							, @asapFlag
							, @sendAfterDateTime
							, @emailServiceId
							, @organisationId 

		SELECT TOP 1      @atlasSystemFromName = sc.AtlasSystemFromName
						, @atlasSystemFromEmail = sc.AtlasSystemFromEmail
						, @atlasToEmailName = sc.FeedbackName
						, @atlasToEmailAddress = sc.FeedbackEmail
		FROM  systemControl sc;

		SET @feedbackSubject = 'Feedback from Atlas User - ' + @feedbackTitle
		
		SET @emailContent = 'Feedback from User: ' + @usersName;
		SET @emailContent = @emailContent + @NewLineChar + 'User''s URL: ' + @usersURL;
		SET @emailContent = @emailContent + @NewLineChar + 'User''s Email: ' + @usersEmail; 
		SET @emailContent = @emailContent + @NewLineChar + 'Respond To Email: ' + @atlasToEmailAddress; 
		SET @emailContent = @emailContent + @NewLineChar + 'Respond Required ' + @responseRequired;
		SET @emailContent = @emailContent + @NewLineChar + 'Feedback Created ' + CONVERT(VARCHAR(10), @creationDate, 103); 
		SET @emailContent = @emailContent + @NewLineChar + 'Title: ' + @feedbackTitle; 
		SET @emailContent = @emailContent + @NewLineChar + @NewLineChar + @feedbackBody; 



		EXEC dbo.uspSendEmail @UserId
							, @atlasSystemFromName
							, @atlasSystemFromEmail
							, @atlasToEmailAddress
							, @ccEmailAddresses
							, @bccEmailAddresses
							, @feedbackSubject
							, @emailContent
							, @asapFlag
							, @sendAfterDateTime
							, @emailServiceId
							, @organisationId

		
GO
ALTER TRIGGER TRG_CourseSchedule_DELETE ON CourseSchedule FOR DELETE
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = d.CourseId FROM deleted d;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = d.CreatedByUserId FROM deleted d;
	SELECT @Item 			= 'Course Times Deleted';
	SELECT @OldValue		= 'Course Start Time:' + CONVERT(VARCHAR(19), d.StartTime) + '; Course End Time:' + CONVERT(VARCHAR(19), d.EndTime) FROM deleted d;
	SELECT @NewValue     = NULL;

	INSERT INTO CourseLog
				(CourseId,
				DateCreated,
				CreatedByUserId,
				Item,
				NewValue,
				OldValue
				)
	VALUES		
				(
				@CourseId ,
				@DateCreated ,
				@CreatedByUserId ,
				@Item ,
				@NewValue ,
				@OldValue 
				)

		
GO
ALTER TRIGGER dbo.TRG_ClientOnlineEmailChangeRequest_AfterInsert ON dbo.ClientOnlineEmailChangeRequest AFTER INSERT
AS

BEGIN

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
	
END
	/*******************************************************************************************************************/
	
GO
ALTER TRIGGER TRG_Organisation_EnsureData_INSERT ON Organisation FOR INSERT
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			EXEC dbo.uspEnsureOrganisationalData;	
		END --END PROCESS

	END


GO
ALTER TRIGGER TRG_ClientSpecialRequirement_INSERT ON ClientSpecialRequirement
AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT id FROM inserted)
	BEGIN
		
		IF NOT EXISTS (SELECT id FROM deleted)
			
			DECLARE @clientId INT;
			DECLARE @clientDisplayName varchar(640);
			DECLARE @specialRequirementName varchar(100);
			DECLARE @today varchar(40);
			DECLARE @notificationUserId INT;
			DECLARE @lastNotificationSent DATETIME;
			DECLARE @notificationUserEmail varchar(400);
			DECLARE @lastInsertedMessage table(lastInsertedMessageId INT);
			DECLARE @lastInsertedMessageId INT;
			DECLARE @messageTitle varchar(400) = 'Client Booked on Course with Special Requirement';
			DECLARE @messageBody varchar(1000);
			DECLARE @fromAddress varchar(400) = '';
			DECLARE @fromName varchar(400) = '';
			DECLARE @RequestedByUserId INT;
			DECLARE @OrganisationId INT;
			DECLARE @sendEmail BIT = 0;
			DECLARE @sendInternalMessage BIT = 0;
			
			SELECT TOP 1 @RequestedByUserId = AddByUserId FROM inserted i;  --Correct Id?
			SELECT @today = replace(convert(char(11),getdate(),113),' ',' '); --returns, for example, 01 Aug 2016
			SELECT TOP 1 @clientId = ClientId from inserted;
			SELECT @specialRequirementName = sr.Name FROM SpecialRequirement sr INNER JOIN inserted i ON i.SpecialRequirementId = sr.Id WHERE sr.id = i.SpecialRequirementId;
			SELECT @OrganisationId = co.OrganisationId  FROM clientspecialrequirement csc INNER JOIN clientorganisation co ON csc.ClientId = co.ClientId WHERE csc.ClientId = @clientId;
			SELECT @clientDisplayName = c.DisplayName FROM Client c INNER JOIN clientspecialrequirement csc ON csc.ClientId = c.Id WHERE csc.ClientId = @clientId;

			--Concatenates First Name and Surname from Client table if @displayName is null
			IF @clientDisplayName IS NULL 
				BEGIN 
					SELECT @clientDisplayName = c.FirstName + ' ' + c.Surname 
					FROM Client c 
					INNER JOIN inserted i on i.ClientId = c.Id
					WHERE c.Id = @clientId;
				END
										
			SELECT @messageBody =  'Hello,' 
									+ CHAR(13) + CHAR(10) 
									+ 'A Client, ' + @clientDisplayName + ',  has booked onto a Course and has a Special Requirement of ' + @specialRequirementName + ' This happened on ' + @today
									+ CHAR(13) + CHAR(10) 
									+ CHAR(13) + CHAR(10) 
									+ 'Atlas Administration';
			
			IF @OrganisationId IS NULL
				BEGIN
					RETURN;
				END

			SELECT	@sendEmail = SendMessagesViaEmail, 
					@sendInternalMessage = sendmessagesviainternalmessaging 
			FROM [OrganisationSystemTaskMessaging]
			INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
			WHERE organisationId = @organisationId AND st.Name = 'CLIENT_MonitorClientsWithSpecialRequirements';


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

						INNER JOIN [user] on userid = [user].id
						INNER JOIN organisationSystemConfiguration OSC on OSC.organisationId = OAU.organisationId

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
							VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), 3, 0, 0)	-- MessageCategoryId of 3 is a Warning Message
							
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

			DROP TABLE #tempNotificationUsers
		END
	END
		
GO
ALTER TRIGGER TRG_TrainerCourseType_Insert ON dbo.TrainerCourseType AFTER INSERT
AS

BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
    DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;

	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN --START PROCESS
		EXEC uspLogTriggerRunning 'TrainerCourseType', 'TRG_TrainerCourseType_Insert', @insertedRows, @deletedRows;

		DECLARE @courseTypeId INT
			, @trainerId INT;

		SELECT @courseTypeId = i.CourseTypeId
			, @trainerId = i.TrainerId
		FROM inserted i;

		EXEC dbo.uspLinkTrainersToSameDORSSchemeAcrossCourseTypes @courseTypeId, @trainerId;
	END--END PROCESS

END
	
GO
ALTER TRIGGER TRG_ClientDORSData_InsertUpdate ON dbo.ClientDORSData AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientDORSData', 'TRG_ClientDORSData_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE COBS
			SET COBS.DORSSchemeId = I.DORSSchemeId
			FROM INSERTED I
			INNER JOIN ClientOnlineBookingState COBS ON COBS.ClientId = I.ClientId
			WHERE I.DataValidatedAgainstDORS = 'True'
			AND COBS.DORSSchemeId IS NULL;

		END --END PROCESS
	END
		
GO
ALTER TRIGGER TRG_TrainerToUpdateDistance_Update ON dbo.Trainer AFTER UPDATE
		AS
		BEGIN	
			DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
			DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
			IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
			BEGIN                 
				EXEC uspLogTriggerRunning 'Trainer', 'TRG_TrainerToUpdateDistance_Update', @insertedRows, @deletedRows;
				-------------------------------------------------------------------------------------------

				DECLARE @TrainerId INT;

				DECLARE cur_Trainers1301 CURSOR
				FOR 
				SELECT DISTINCT Id
				FROM INSERTED I;
			
				OPEN cur_Trainers1301   
				FETCH NEXT FROM cur_Trainers1301 INTO @TrainerId;

				WHILE @@FETCH_STATUS = 0   
				BEGIN 
					IF (ISNULL(@TrainerId,-1) > 0)
					BEGIN
						EXEC uspUpdateTrainerDistancesForAttachedVenues @TrainerId
					END
					FETCH NEXT FROM cur_Trainers1301 INTO @TrainerId;
				END

				CLOSE cur_Trainers1301;
				DEALLOCATE cur_Trainers1301;
			END --END PROCESS

		END


	
GO
ALTER TRIGGER TRG_EmailServiceSendingFailure_INSERT ON EmailServiceSendingFailure FOR INSERT
	AS	
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

	
GO
ALTER TRIGGER TRG_TrainerLocationToUpdateDistance_Update ON dbo.TrainerLocation AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'TrainerLocation', 'TRG_TrainerLocationToUpdateDistance_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
				
			DECLARE @TrainerId INT;

			DECLARE cur_TrainerLocation1301 CURSOR
			FOR 
			SELECT DISTINCT Id
			FROM INSERTED I;
			
			OPEN cur_TrainerLocation1301   
			FETCH NEXT FROM cur_TrainerLocation1301 INTO @TrainerId;

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF (ISNULL(@TrainerId,-1) > 0)
				BEGIN
					EXEC uspUpdateTrainerDistancesForAttachedVenues @TrainerId
				END
				FETCH NEXT FROM cur_TrainerLocation1301 INTO @TrainerId;
			END

			CLOSE cur_TrainerLocation1301;
			DEALLOCATE cur_TrainerLocation1301;
		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_CourseDateDORSNotified_Update ON dbo.Course AFTER UPDATE
AS

BEGIN
	DECLARE @insertedDate DATETIME
          , @deletedDate DATETIME
		  , @id INT
		  , @notificationReason VARCHAR(20);

	SELECT @insertedDate = i.DateDORSNotified
		 , @id = id
		 , @notificationReason = DORSNotificationReason 
	FROM Inserted i;

	SELECT @deletedDate = d.DateDORSNotified FROM Deleted d;

	/*
	--Wouldn't insert in to coursenotification if @notificationReason was null
	IF(@notificationReason IS NULL)
	BEGIN
		SET @notificationReason = '';
	END
	*/

	--Inserts an entry in to CourseDORSNotification
	IF (@insertedDate <> @deletedDate)
	BEGIN
		INSERT INTO dbo.CourseDORSNotification(courseId, DateTimeNotified, NotificationReason)
		VALUES(@id, GETDATE(), ISNULL(@notificationReason, ''));
	END

END
		
GO
ALTER TRIGGER TRG_CourseSchedule_INSERT ON CourseSchedule FOR INSERT
AS
	DECLARE @CourseId int;
	DECLARE @DateCreated DATETIME;
	DECLARE @CreatedByUserId INT;
	DECLARE @Item VARCHAR(40);
	DECLARE @NewValue VARCHAR(100);
	DECLARE @OldValue VARCHAR(100);

	SELECT @CourseId        = i.CourseId FROM inserted i;
	SELECT @DateCreated 	= GETDATE();
	SELECT @CreatedByUserId = i.CreatedByUserId FROM inserted i;
	SELECT @Item 			= 'New Course Schedule';
	SELECT @NewValue 		= 'Course Start Time:' + CONVERT(VARCHAR(19),i.StartTime)  + '; Course End Time:' + CONVERT(VARCHAR(19),i.EndTime) FROM inserted i ;
	SELECT @OldValue        = NULL;

	INSERT INTO CourseLog
				(CourseId,
				DateCreated,
				CreatedByUserId,
				Item,
				NewValue,
				OldValue
				)
	VALUES		
				(
				@CourseId ,
				@DateCreated ,
				@CreatedByUserId ,
				@Item ,
				@NewValue ,
				@OldValue 
				);

	
GO
ALTER TRIGGER TRG_VenueAddressToUpdateTrainerVenueDistance_Update ON dbo.VenueAddress AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'VenueAddress', 'TRG_VenueAddressToUpdateTrainerVenueDistance_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
				
			DECLARE @VenueId INT;

			DECLARE cur_Venues1301 CURSOR
			FOR 
			SELECT DISTINCT I.VenueId
			FROM INSERTED I;
			
			OPEN cur_Venues1301   
			FETCH NEXT FROM cur_Venues1301 INTO @VenueId;

			WHILE @@FETCH_STATUS = 0   
			BEGIN 
				IF (ISNULL(@VenueId,-1) > 0)
				BEGIN
					EXEC uspUpdateVenueTrainerDistancesForAttachedTrainers @VenueId
				END
				FETCH NEXT FROM cur_Venues1301 INTO @VenueId;
			END

			CLOSE cur_Venues1301;
			DEALLOCATE cur_Venues1301;
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_ClientOnlineBookingState_InsertUpdate ON dbo.ClientOnlineBookingState AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'ClientOnlineBookingState', 'TRG_ClientOnlineBookingState_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			UPDATE COBS
			SET COBS.DORSSchemeId = CDD.DORSSchemeId
			FROM INSERTED I
			INNER JOIN ClientOnlineBookingState COBS ON COBS.ClientId = I.ClientId
			INNER JOIN ClientDORSData CDD ON CDD.ClientId = I.ClientId
			WHERE CDD.DataValidatedAgainstDORS = 'True'
			AND I.DORSSchemeId IS NULL
			AND COBS.DORSSchemeId IS NULL;

		END --END PROCESS
	END
	
GO
ALTER TRIGGER dbo.TRG_CourseTypeCategoryFee_InsertUpdate ON dbo.CourseTypeCategoryFee AFTER INSERT, UPDATE
	AS

	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;

		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'CourseTypeCategoryFee', 'TRG_CourseTypeCategoryFee_InsertUpdate', @insertedRows, @deletedRows;

			DECLARE @id INT
					, @organisationId INT
					, @courseTypeId INT
					, @courseTypeCategoryId INT
					, @effectiveDate DATETIME;

				SELECT @id = Id FROM Inserted i;

				SELECT ctcf.Id
				INTO #TempCourseTypeCategoryFeeIds
				FROM Inserted i
				INNER JOIN dbo.CourseTypeCategoryFee ctcf ON i.OrganisationId = ctcf.OrganisationId
															AND i.CourseTypeId = ctcf.CourseTypeId
															AND i.CourseTypeCategoryId = ctcf.CourseTypeCategoryId
															AND CAST(i.EffectiveDate AS DATE) = CAST(ctcf.EffectiveDate AS Date);

				--Checks to see if #TempCourseTypeCategoryFeeIds holds anything before proceeding
				IF((SELECT COUNT(Id) FROM #TempCourseTypeCategoryFeeIds) > 0)
				BEGIN
					UPDATE dbo.CourseTypeCategoryFee 
					SET [Disabled] = 'True'
						, DisabledByUserId = dbo.udfGetSystemUserId()
						, DateDisabled = GETDATE()
					WHERE (Id IN (SELECT Id FROM #TempCourseTypeCategoryFeeIds)) AND (Id != @id);
				END

				DROP TABLE #TempCourseTypeCategoryFeeIds;
		END --End Process

	END

	
GO
ALTER TRIGGER TRG_Client_ClientQuickSearchINSERTUPDATEDELETE ON Client AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
		
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_ClientQuickSearchINSERTUPDATEDELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			DECLARE @ClientId int;
			DECLARE @InsertId int;
			DECLARE @DeleteId int;
	
			SELECT @InsertId = i.Id FROM inserted i;
			SELECT @DeleteId = d.Id FROM deleted d;
	
			SELECT @ClientId = COALESCE(@InsertId, @DeleteId);	

			EXEC dbo.uspRefreshClientQuickSearchData @ClientId;
		END --END PROCESS
	END
	
GO
ALTER TRIGGER TRG_SystemTaskToAddOrganisationSystemTaskMessaging_INSERT ON SystemTask FOR INSERT
	AS
	
		DECLARE @SysUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';

		INSERT INTO dbo.OrganisationSystemTaskMessaging
		(OrganisationId, SystemTaskId, SendMessagesViaEmail, SendMessagesViaInternalMessaging, UpdatedByUserId, DateUpdated)
		SELECT 
			O.Id AS OrganisationId
			, I.Id AS SystemTaskId
			, 'True' AS SendMessagesViaEmail
			, 'True' AS SendMessagesViaInternalMessaging
			, @SysUserId AS UpdatedByUserId
			, GetDate() AS DateUpdated
		FROM INSERTED I, dbo.Organisation O
		
GO
ALTER TRIGGER dbo.TRG_CourseTypeFee_InsertUpdate ON dbo.CourseTypeFee AFTER INSERT, UPDATE
AS

BEGIN

	DECLARE @id INT
			, @organisationId INT
			, @courseTypeId INT
			, @effectiveDate DATETIME
			, @courseFee MONEY
			, @bookingSupplement MONEY
			, @paymentDays INT
			, @addedByUserId INT
			, @dateAdded DATETIME
			, @disabled BIT
			, @disabledByUserId INT
			, @dateDisabled DATETIME
			, @existingRowCheck INT;

		SELECT @id = Id FROM Inserted i;

		SELECT ctf.Id
		INTO #TempFeeIds
		FROM Inserted i
		INNER JOIN dbo.CourseTypeFee ctf ON i.OrganisationId = ctf.OrganisationId
											AND i.CourseTypeId = ctf.CourseTypeId
											AND CAST(i.EffectiveDate AS DATE) = CAST(ctf.EffectiveDate AS Date);

		IF((SELECT COUNT(Id) FROM #TempFeeIds) > 0)
		BEGIN
			UPDATE dbo.CourseTypeFee 
			SET [Disabled] = 'True'
				, DisabledByUserId = dbo.udfGetSystemUserId()
				, DateDisabled = GETDATE()
			WHERE (Id IN (SELECT Id FROM #TempFeeIds)) AND (Id != @id);
		END

		DROP TABLE #TempFeeIds;

END


GO
ALTER TRIGGER [dbo].[TRG_CourseTrainer_InsertUpdateDelete] ON [dbo].[CourseTrainer]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
    DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN
		--Trigger Logging
		EXEC dbo.uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainer_InsertUpdateDelete', @insertedRows, @deletedRows;
		-----------------------------------------------------------------------------------------------------------------------

		INSERT INTO dbo.CourseLog(CourseId, DateCreated, CreatedByUserId, Item, NewValue, OldValue)
		SELECT 
			ISNULL(i.CourseId, d.CourseId)					AS CourseId
			, GETDATE()										AS DateCreated
			, ISNULL(i.CreatedByUserId, d.CreatedByUserId)	AS CreatedByUserId
			, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NULL --Inserted
						THEN 'Trainer Added'  
					WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
						THEN 'AttendanceCheck'
					WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceLastUpdated != d.AttendanceLastUpdated --Updated
						THEN 'AttendanceLastUpdated'
					WHEN i.Id IS NULL AND D.Id IS NOT NULL --Deleted
						THEN 'TrainerId'
					WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL AND i.TrainerId != d.TrainerId
						THEN 'Trainer Updated'
				END)										AS Item
			, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NULL --Inserted
						THEN 'Trainer Added, TrainerId: ' + CAST(i.TrainerId AS VARCHAR)  
					WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
					THEN 'Attendance check changed to ' + (CASE WHEN i.AttendanceCheckRequired = 0 THEN 'False' 
																WHEN i.AttendanceCheckRequired = 1 THEN 'True' 
															END)
					WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
					THEN 'AttendanceLastUpdated to ' + CAST(i.AttendanceLastUpdated AS VARCHAR)
					WHEN i.Id IS NULL AND D.Id IS NOT NULL --Deleted
					THEN 'Trainer Removed, Trainer Id: ' + CAST(d.TrainerId AS VARCHAR)
					WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL
						AND i.TrainerId != d.TrainerId
					THEN 'Trainer Updated, new TrainerId: ' + CAST(i.TrainerId AS VARCHAR)
				END)										AS NewValue
			, (CASE	WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceCheckRequired != d.AttendanceCheckRequired --Updated
						THEN 'Attendance check changed from ' + CASE WHEN 
															d.AttendanceCheckRequired = 0 THEN 'False' 
															WHEN d.AttendanceCheckRequired = 1 THEN 'True' 
															END 
					WHEN i.Id IS NOT NULL AND D.Id IS NOT NULL 
						AND i.AttendanceLastUpdated != d.AttendanceLastUpdated--Updated
						THEN 'AttendanceLastUpdated From ' + CAST(d.AttendanceLastUpdated AS VARCHAR)
					WHEN i.TrainerId IS NOT NULL AND d.TrainerId IS NOT NULL
						AND i.TrainerId != d.TrainerId
						THEN 'Trainer Updated, old TrainerId: ' + CAST(d.TrainerId AS VARCHAR)
				END)									AS OldValue
		FROM inserted i
		FULL JOIN deleted d ON i.Id = d.Id;
	END --(inserted deleted > 0 check)
END



GO
ALTER TRIGGER TRG_DocumentMarkedForDelete_Insert ON DocumentMarkedForDelete
AFTER INSERT
AS
BEGIN
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
							VALUES (@MessageTitle, @MessageBody, NULL, GETDATE(), 3, 0, 0)	-- MessageCategoryId of 3 is a Warning Message
							
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

			DROP TABLE #tempNotificationUsers
		END
	END
		
GO
ALTER TRIGGER TRG_CourseClientRemoved_Insert ON CourseClientRemoved AFTER INSERT
		AS

		BEGIN

			DECLARE @IsDORSCourse BIT;
			DECLARE @CourseId INT;
			DECLARE @ClientId INT;
			DECLARE @DateRemoved DATETIME;

			SELECT @IsDORSCourse = crs.DORSCourse, @CourseId = i.CourseId, @ClientId = i.ClientId, @DateRemoved = i.DateRemoved
			FROM inserted i 
			JOIN Course crs
			ON crs.Id = i.CourseId

			IF
				(@IsDORSCourse  = 'True')
					BEGIN
						INSERT INTO [dbo].[CourseDORSClientRemoved]
							(
								CourseId,
								ClientId,
								DORSNotified,
								DateRemoved
							)
						VALUES
							(
								@CourseId,
								@ClientId,
								'False',
								@DateRemoved
							)
					END
		END

		
GO
ALTER TRIGGER dbo.TRG_CourseVenueEmail_InsertUpdate ON dbo.Course AFTER INSERT, UPDATE
AS

BEGIN
	DECLARE @organisationId INT
			, @AllowAutoEmailCourseVenuesOnCreationToBeSent BIT
			, @available BIT
			, @courseId INT
			, @venueId INT
			, @courseVenueEmailCheck INT
			, @courseVenueEmailCheckName CHAR(26) = 'Venue Availability Request' --also used to look up the reason id
			, @emailContent VARCHAR(1000)
			, @emailSubject VARCHAR(100)
			, @templateMessageCode CHAR(16) = 'CourseVenueAvail'
			, @venueName VARCHAR(250)
			, @courseTypeName VARCHAR(200)
			, @courseStartDate DATETIME
			, @courseEndDate DATETIME
			, @organisationDisplayName VARCHAR(320)
			, @toEmailAddress VARCHAR(320)
			, @replyEmailAddress VARCHAR(320)
			, @backupFromEmailName VARCHAR(320)
			, @backupFromEmailAddress VARCHAR(320)
			, @requestedByUserId INT
			, @isEmailValid	BIT
			, @emailSendAfterDate DATETIME
			, @scheduledEmailId INT --??
			, @reasonId INT
			, @venueNameTag CHAR(14) = '<!Venue Name!>'
			, @courseTypeNameTag CHAR(20) = '<!Course Type Name!>'
			, @courseStartDateTag CHAR(21) = '<!Course Start Date!>'
			, @courseEndDateTag CHAR(19) = '<!Course End Date!>'
			, @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
			, @replyEmailAddressTag CHAR(23) = '<!Reply Email Address!>';

	SELECT @organisationId = i.OrganisationId
			, @available = i.Available
			, @courseId = i.Id
			, @venueId = cv.VenueId
			, @venueName = v.Title --also should be used as @fromName in uspSendMail if the email is valid. If not, use backup.
			, @courseTypeName = ct.Title
			, @organisationDisplayName = od.[Name]
			, @replyEmailAddress = osc.VenueReplyEmailAddress --also should be used as @fromEmailAddress in uspSendMail if the email is valid. If not, use backup.
			, @toEmailAddress = e.[Address] --Venue email address
			, @backupFromEmailAddress = osystemc.FromEmail --this will only be used if @replyEmailAddress is invalid.
			, @backupFromEmailName = osystemc.[FromName] --this will only be used if @replyEmailAddress is invalid.
			, @allowAutoEmailCourseVenuesOnCreationToBeSent = osc.AllowAutoEmailCourseVenuesOnCreationToBeSent
			, @requestedByUserId = dbo.udfGetSystemUserId()
	FROM Inserted I
	INNER JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id
	INNER JOIN dbo.OrganisationDisplay od ON i.OrganisationId = od.OrganisationId
	INNER JOIN dbo.CourseVenue cv ON i.id = cv.CourseId
	INNER JOIN dbo.Venue v ON cv.VenueId = v.Id
	INNER JOIN dbo.VenueEmail ve ON v.id = ve.VenueId
	INNER JOIN dbo.Email e ON ve.EmailId = e.Id
	INNER JOIN dbo.OrganisationSelfConfiguration osc ON i.OrganisationId = osc.OrganisationId 
	INNER JOIN dbo.OrganisationSystemConfiguration osystemc ON i.OrganisationId = osystemc.OrganisationId;

	IF(@allowAutoEmailCourseVenuesOnCreationToBeSent = 'True')
	BEGIN
		IF(@available = 'True')
		BEGIN
			--checks to see if an email already exists
			SELECT @courseVenueEmailCheck = COUNT(cve.Id)
			FROM dbo.CourseVenueEmail cve
			INNER JOIN dbo.CourseVenueEmailReason cver ON cve.CourseVenueEmailReasonId = cve.Id
			WHERE (cve.CourseId = @courseId) 
					AND (cve.VenueId = @venueId) 
					AND (cver.[Name] = @courseVenueEmailCheckName);
			
			--If email doesn't exist it proceeds
			IF(@courseVenueEmailCheck IS NULL OR @courseVenueEmailCheck = 0)
			BEGIN
				SELECT @emailContent = Content, @emailSubject = [Subject]
				FROM dbo.OrganisationEmailTemplateMessage
				WHERE OrganisationId = @organisationId AND Code = @templateMessageCode;

				SELECT @courseStartDate = MIN(DateStart) --course might run on multiple days
				FROM dbo.CourseDate
				WHERE CourseId = @courseId;

				SELECT @courseEndDate = MAX(DateEnd) --course might run on multiple days
				FROM dbo.CourseDate
				WHERE CourseId = @courseId;

				--Checks to see if the email formatting is valid.
				SELECT @isEmailValid = CASE WHEN
											ISNULL(@replyEmailAddress, '') <> '' 
												AND @replyEmailAddress LIKE '%_@%_.__%' 
											THEN 
												'True' 
											ELSE 
												'False' 
											END;
				
				--If the email isn't valid, updates @replyEmailAddress and @venueName
				--with the backup options						
				IF(@isEmailValid = 'False')
				BEGIN
					SET @replyEmailAddress = @backupFromEmailAddress;
					SET @venueName = @backupFromEmailName;
				END 

				--Replaces the tags in the email content with data grabbed above.
				SET @emailContent = REPLACE(@emailContent, @venueNameTag, @venueName);
				SET @emailContent = REPLACE(@emailContent, @courseTypeNameTag, @courseTypeName);
				SET @emailContent = REPLACE(@emailContent, @courseStartDateTag, CAST(@courseStartDate AS VARCHAR));
				SET @emailContent = REPLACE(@emailContent, @courseEndDateTag, CAST(@courseEndDate AS VARCHAR));
				SET @emailcontent = REPLACE(@emailContent, @organisationDisplayNameTag, @organisationDisplayName);
				SET @emailContent = REPLACE(@emailContent, @replyEmailAddressTag, @replyEmailAddress);

				--doesn't allow getdate to be sent directly as a param to uspSendEmail
				SET @emailSendAfterDate = GETDATE();

				--getting email reason id
				SELECT @reasonId = Id
				FROM dbo.CourseVenueEmailReason
				WHERE [Name] = @courseVenueEmailCheckName;

				EXEC @scheduledEmailId = uspSendEmail @requestedByUserId
													, @venueName --FromName
													, @replyEmailAddress --FromEmailAddress
													, @toEmailAddress
													, NULL --ccEmailAddresses
													, NULL --bccEmailAddresses
													, @emailSubject
													, @emailContent 
													, 'True' --@asapFlag
													, @emailSendAfterDate --@sendAfterDateTime
													, NULL
													, @organisationId;
				
				--adds row in to CourseVenueEmail
				INSERT INTO dbo.CourseVenueEmail(CourseId
												, VenueId
												, DateCreated
												, ScheduledEmailId
												, CourseVenueEmailReasonId)
										VALUES  (@courseId
												, @venueId
												, GETDATE()
												, @scheduledEmailId
												, @reasonId)

			END --@courseVenueEmailCheck IS NULL
		END --@available = 'True'
	END --@allowAutoEmailCourseVenuesOnCreationToBeSent = 'True'			
END --
GO
--ALTER TRIGGER
		
--GO
ALTER TRIGGER TRG_CourseClient_Insert ON CourseClient AFTER INSERT
		AS

		BEGIN
			DECLARE @courseId INT = NULL
				, @clientId INT = NULL;
			SELECT @courseId = I.CourseId, @clientId = I.ClientId
			FROM INSERTED I;

			EXEC dbo.uspInsertCourseDORSClientDataIfMissing @courseId, @clientId;

		END

		
GO
ALTER TRIGGER TRG_CourseClientPayment_Insert ON CourseClientPayment AFTER INSERT
		AS

		BEGIN
			--The Following Should already be there. This is a Just in case.......
			DECLARE @courseId INT = NULL
				, @clientId INT = NULL;
			SELECT @courseId = I.CourseId, @clientId = I.ClientId
			FROM INSERTED I;

			EXEC dbo.uspInsertCourseDORSClientDataIfMissing @courseId, @clientId;

			--Now Check the Total Amount Paid by the Client for the Course
			DECLARE @TotalAmountPaid MONEY;
			DECLARE @rowsUpdated INT = 0;

			SELECT @TotalAmountPaid = SUM(P.Amount)
			FROM INSERTED I
			INNER JOIN [dbo].[CourseClientPayment] CCP ON CCP.CourseId = I.CourseId
														AND CCP.ClientId = I.ClientId
			INNER JOIN [dbo].[Payment] P ON P.Id = CCP.PaymentId
			;

			UPDATE CDC
			SET CDC.[PaidInFull] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
										THEN 'True' ELSE 'False' END)
			, CDC.[DatePaidInFull] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
										THEN GETDATE() ELSE CDC.[DatePaidInFull] END)
			, CDC.[OnlyPartPaymentMade] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
												THEN 'False' 
												ELSE (CASE WHEN @TotalAmountPaid > 0 THEN 'True' ELSE 'False' END)
												END)
			FROM [dbo].[CourseDORSClient] CDC
			INNER JOIN [dbo].[CourseClient] CC ON CC.[CourseId] = CDC.[CourseId]
												AND CC.[ClientId] = CDC.[ClientId]
			WHERE CDC.[CourseId] = @courseId
			AND CDC.[ClientId] = @clientId
			AND CDC.[PaidInFull] = 'False'
			;
			SET @rowsUpdated = @@rowcount;

			IF (@rowsUpdated > 0)
			BEGIN
				--This will trigger a new DORS Notification. But only if Fully Paid
				UPDATE CDC
				SET CDC.[DORSNotified] = 'False'
				, CDC.[DateDORSNotified] = NULL
				, CDC.[NumberOfDORSNotificationAttempts] = 0
				, CDC.[DateDORSNotificationAttempted] = NULL
				FROM [dbo].[CourseDORSClient] CDC
				INNER JOIN [dbo].[CourseClient] CC ON CC.[CourseId] = CDC.[CourseId]
													AND CC.[ClientId] = CDC.[ClientId]
				WHERE CDC.[CourseId] = @courseId
				AND CDC.[ClientId] = @clientId
				AND CDC.[PaidInFull] = 'True'
				;
				
			END

		END

		
GO
ALTER TRIGGER TRG_ClientOnlineEmailChangeRequest_BeforeInsert ON dbo.ClientOnlineEmailChangeRequest INSTEAD OF INSERT
		AS
		BEGIN	
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
	
		END
	
GO
ALTER TRIGGER dbo.TRG_CourseTrainer_InsertDelete ON dbo.CourseTrainer AFTER INSERT, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainer_InsertDelete', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @trainerId INT
					, @count INT = 0
					, @rowCount INT
					, @year INT
					, @month INT;

			DECLARE cur_TrainerCourseDate CURSOR
			FOR
			SELECT ISNULL(i.TrainerId, d.TrainerId) AS TrainerId
					, YEAR(cd.DateStart) AS [Year]
					, MONTH(cd.DateStart) AS [Month]
			FROM inserted i
			FULL JOIN deleted d ON i.Id = d.id
			INNER JOIN dbo.CourseDate cd ON ISNULL(i.CourseId, d.CourseId) = cd.CourseId;

			OPEN cur_TrainerCourseDate
			FETCH NEXT FROM cur_TrainerCourseDate INTO @trainerId, @year, @month;

			WHILE @@FETCH_STATUS = 0 
			BEGIN
				IF(ISNULL(@trainerId, -1) > 0 AND ISNULL(@year, -1) > 0 AND ISNULL(@month, -1) > 0)
					BEGIN
						EXEC dbo.uspUpdateTrainerSummaryForMonth @trainerId, @year, @month;
					END
					FETCH NEXT FROM cur_TrainerCourseDate INTO @trainerId, @year, @month;
			END

			CLOSE cur_TrainerCourseDate;
			DEALLOCATE cur_TrainerCourseDate;
		END --END PROCESS
	END
	
GO
ALTER TRIGGER TRG_DashboardMeterExposure_INSERT ON DashboardMeterExposure FOR INSERT
	AS
	BEGIN
		/*
		Create an Insert Trigger on the table "DashboardMeterExposure".
		For every row inserted create a new message using SP "uspSendInternalMessage" to 
		every Organisational Administrator (table OrganisationAdminUser) User.
		The Message Title should be "New Dashboard Meter Available" and the Content should
		be "The Dashboard Meter "<Meter Title> is now available. Please use the Dashboard
		Meter Administration to set who has access.<newline><newline>Atlas Administration."
		*/
   
		DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
		DECLARE @MessageTitle VARCHAR(250) = 'New Dashboard Meter Available';
		DECLARE @CreatedByUserId INT = [dbo].[udfGetSystemUserId]();
		DECLARE @MessageContent VARCHAR(1000) = '';
		DECLARE @DashboardMeterTitle VARCHAR(100) = '';
		DECLARE @OrganisationId INT;
		DECLARE @UserId INT;
		DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('GENERAL');

		DECLARE newMeterCursor CURSOR FOR 
		SELECT 
			i.[OrganisationId]
			, OAU.[UserId]
			, ('The Dashboard Meter "' + DM.[Title]
				+ '" is now avaliable. Please use the Dashboard Meter Administration to set who has access.'
				+ @NewLineChar + @NewLineChar + 'Atlas Administration.')
				AS MessageContent
		FROM inserted i
		INNER JOIN [dbo].[DashboardMeter] DM ON DM.[Id] = i.[DashboardMeterId]
		INNER JOIN [dbo].[OrganisationAdminUser] OAU ON OAU.[OrganisationId] = i.[OrganisationId]
		INNER JOIN [dbo].[User] U ON U.[Id] = OAU.[UserId];		
		
		OPEN newMeterCursor;			   
		FETCH NEXT FROM newMeterCursor INTO @OrganisationId, 
											@UserId, 
											@MessageContent;

		WHILE @@FETCH_STATUS = 0   
		BEGIN		
			EXEC dbo.uspSendInternalMessage 
									@MessageCategoryId = @MessageCategoryId
									, @MessageTitle = @MessageTitle
									, @MessageContent = @MessageContent
									, @SendToUserId = @UserId
									, @CreatedByUserId = @CreatedByUserId
									;
				   
			FETCH NEXT FROM newMeterCursor INTO @OrganisationId, 
												@UserId, 
												@MessageContent;
		END   
		CLOSE newMeterCursor;  
		DEALLOCATE newMeterCursor;
		
	END

	
GO
ALTER TRIGGER TRG_DORSClientCourseAttendance_INSERTUPDATE ON DORSClientCourseAttendance FOR INSERT, UPDATE
	AS	
		DECLARE @dorsAttendanceStateIdentifier INT;
		DECLARE @insertedClientId INT;
		DECLARE @insertedCourseId INT;

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


	
GO
ALTER TRIGGER TRG_ScheduledEmail_UPDATE ON ScheduledEmail FOR UPDATE
	AS
	
		/* If an email has failed to Send 3 or more times then mark the email as a Send Failed */
		SELECT i.Id, Sum([SendAtempts]) AS TotalAttempts
		INTO #TooManyRetrys
		FROM inserted i
		WHERE i.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
											FROM [dbo].[ScheduledEmailState] SES
											WHERE SES.[Name] = 'Failed - Retrying')
		GROUP BY i.Id
		HAVING Sum([SendAtempts]) >= 3; /*Get All Emails which ahve failed 3 or more times.*/

		/*Set the emails to Failed Status. Stopping them from sending any more*/
		UPDATE SE
		SET [ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
										FROM [dbo].[ScheduledEmailState] SES
										WHERE SES.[Name] = 'Failed')
		FROM ScheduledEmail SE
		INNER JOIN #TooManyRetrys SE2 ON SE2.Id = SE.Id;
		/***************************************************************************************/
		
		/* Ensure that the DateUpdated is correct */
		UPDATE SE
		SET DateUpdated = GetDate()
		FROM ScheduledEmail SE
		INNER JOIN inserted i ON i.Id = SE.Id;
		/***************************************************************************************/

		
		/* Record Emails Sent Against a Service */
		INSERT INTO [dbo].[EmailServiceEmailsSent] (ScheduledEmailId, DateSent, EmailServiceId)
		SELECT i.[Id] AS ScheduledEmailId
			, GetDate() AS DateSent
			, i.[EmailProcessedEmailServiceId] AS EmailServiceId
		FROM INSERTED i
		INNER JOIN DELETED d ON D.Id = I.Id
		LEFT JOIN [dbo].[EmailServiceEmailsSent] ESES ON ESES.[ScheduledEmailId] = i.[Id]
		WHERE d.[ScheduledEmailStateId] != i.[ScheduledEmailStateId] /* Email State has Changed */
		AND i.[ScheduledEmailStateId] = (SELECT TOP 1 SES.[Id] 
											FROM [dbo].[ScheduledEmailState] SES
											WHERE SES.[Name] = 'Sent')
		AND ESES.Id IS NULL;
		/***************************************************************************************/

		/* Now Send message to Administrators about Failed Emails */
		DECLARE @OrgId int;
		DECLARE @ErrorMessage Varchar(100);
		DECLARE @ErrorMessageTitle Varchar(100);
		DECLARE @SupportUserId int;
		DECLARE @SupportUserEmail Varchar(320);
		DECLARE @atlasSystemUserId INT = dbo.udfGetSystemUserId();
		DECLARE @atlasSystemFromName VARCHAR(320) = dbo.udfGetSystemEmailFromName();
		DECLARE @atlasSystemFromEmail VARCHAR(320) = dbo.udfGetSystemEmailAddress();
		DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10)
		DECLARE @Tab VARCHAR(1) = CHAR(9);
		DECLARE @sendEmail BIT = 'True';
		DECLARE @sendInternalMessage BIT = 'True';		
		DECLARE @MessageCategoryId INT = [dbo].[udfGetMessageCategoryId]('ERROR');
		
		DECLARE errorCursor CURSOR FOR  
		SELECT DISTINCT 
			OSE.[OrganisationId]
			, 'Multiple Send Attempts. EmailId: "' + CAST(TMR.Id AS VARCHAR) + '";'
				+ ' To: ' + SETO.[Email] + '; '
				+ ' Org: ' + O.[Name] + ';' AS ErrorMessage
			, '*Multiple Send Email Attempts on Email*' AS ErrorMessageTitle
			, SSU.[UserId] AS SupportUserId
			, U.[Email] AS SupportUserEmail
		FROM #TooManyRetrys TMR
		INNER JOIN [dbo].[OrganisationScheduledEmail] OSE ON OSE.[ScheduledEmailId] = TMR.Id
		INNER JOIN [dbo].[Organisation] O ON O.Id = OSE.[OrganisationId]
		INNER JOIN [dbo].[ScheduledEmailTo] SETO ON SETO.[ScheduledEmailId] = TMR.Id
		INNER JOIN [dbo].[SystemSupportUser] SSU ON SSU.[OrganisationId] = OSE.[OrganisationId]
		INNER JOIN [dbo].[User] U ON U.[Id] = SSU.[UserId]
		WHERE U.[Email] IS NOT NULL
		AND dbo.udfIsEmailAddressValid(U.[Email]) = 'True'; --Only Send to the Support User if a Valid Email Address
		
		OPEN errorCursor   
		FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;

		WHILE @@FETCH_STATUS = 0   
		BEGIN
			
			SELECT	@sendEmail = SendMessagesViaEmail, 
					@sendInternalMessage = sendmessagesviainternalmessaging 
			FROM [OrganisationSystemTaskMessaging]
			INNER JOIN [SystemTask] st ON SystemTaskId = st.Id
			WHERE organisationId = @OrgId AND st.Name = 'EMAIL_MultipleEmailSendFailure';

			IF (@sendEmail = 'True')
			BEGIN
				EXEC dbo.uspSendEmail @requestedByUserId = @atlasSystemUserId
									, @fromName = @atlasSystemFromName
									, @fromEmailAddresses = @atlasSystemFromEmail
									, @toEmailAddresses = @SupportUserEmail
									, @emailSubject = @ErrorMessageTitle
									, @emailContent = @ErrorMessage
									, @organisationId = @OrgId
			END
			
			IF (@sendInternalMessage = 'True')
			BEGIN
				EXEC dbo.uspSendInternalMessage 
									@MessageCategoryId = @MessageCategoryId
									, @MessageTitle = @ErrorMessageTitle
									, @MessageContent = @ErrorMessage
									, @SendToUserId = @SupportUserId
									, @CreatedByUserId = @atlasSystemUserId
									;
			END

			FETCH NEXT FROM errorCursor INTO @OrgId, @ErrorMessage, @ErrorMessageTitle, @SupportUserId, @SupportUserEmail;
		END   

		CLOSE errorCursor   
		DEALLOCATE errorCursor

		
GO
ALTER TRIGGER TRG_TrainerToInsertTrainerDocument_INSERT ON Trainer FOR INSERT
AS

		INSERT INTO [dbo].[TrainerDocument]
           ([OrganisationId]
           ,[TrainerId]
           ,[DocumentId])
        SELECT
			atd.OrganisationId
           ,i.Id
           ,atd.DocumentId 
		FROM
           inserted i
		   INNER JOIN TrainerOrganisation ton on i.Id = ton.TrainerId
		   INNER JOIN AllTrainerDocument atd on ton.OrganisationId = atd.OrganisationId
		   

	
GO
ALTER TRIGGER TRG_ClientPayment_Insert ON dbo.ClientPayment AFTER INSERT, UPDATE
	AS
	BEGIN
		BEGIN TRY
			INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
			SELECT DISTINCT
				CO.OrganisationId		AS OrganisationId
				, I.PaymentId			AS PaymentId
			FROM INSERTED I
			INNER JOIN [dbo].[ClientOrganisation] CO ON CO.ClientId = I.ClientId
			LEFT JOIN [dbo].[OrganisationPayment] OP ON OP.PaymentId = I.PaymentId
			WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table
		END TRY
		BEGIN CATCH
			--SET @errMessage = '*Error Inserting Into OrganisationPayment Table';
			/*
				We Don't Need to do anything with This at the moment 
				If It is a Duplicate then it should not hapen anyway.
				This May already have been inserted into via Payment Trigger.
			*/
		END CATCH
	END;
		
GO
ALTER TRIGGER TRG_VenueToInsertInToTrainerVenue_Insert ON dbo.Venue AFTER INSERT
AS

BEGIN

	DECLARE  @rowCount INT
			, @counter INT = 1
			, @venueId INT
			, @trainerId INT;

		SELECT @venueId = i.Id FROM Inserted i;

		-- Inserts the appropriate Trainer and Venue Id's in to a temporary table
		-- that will be looped through later.
		SELECT v.Id as VenueId, tro.TrainerId
		INTO #Venue
		FROM dbo.Venue v
		INNER JOIN dbo.Organisation o ON v.OrganisationId = o.Id
		INNER JOIN dbo.VenueAddress va ON v.Id = va.VenueId
		INNER JOIN dbo.TrainerOrganisation tro ON v.OrganisationId = tro.OrganisationId
		WHERE v.Id = @venueId

		-- Gets the row count of the table for use in the loop later
		SELECT @rowCount = @@ROWCOUNT;

		-- Adds an Id to the temp table which will be used for the loop
		ALTER TABLE #Venue
		ADD Id INT IDENTITY(1,1) PRIMARY KEY;

		WHILE @counter <= @rowCount
		BEGIN
			SELECT @venueId = VenueId, @trainerId = TrainerId FROM #Venue WHERE Id = @counter;

			-- Checks to see if there's already an entry on TrainerVenue for the venue and trainer
			-- If there is then it skips it, if there isn't it inserts in to TrainerVenue then calls
			-- the stored procedure to calculate distance
			IF NOT EXISTS(SELECT TOP(1) TrainerId, VenueId FROM dbo.TrainerVenue WHERE TrainerId = @TrainerId AND VenueId = @VenueId)
			BEGIN
				INSERT INTO dbo.TrainerVenue(trainerId, VenueId, DateUpdated, UpdatedByUserId)
				VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId());
				EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;
			END
			SET @counter = @counter + 1;
		END

		DROP TABLE #Venue;

END
		
GO
ALTER TRIGGER TRG_CourseToInsertCourseDocument_INSERT ON Course FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
            ([CourseId]
           ,[DocumentId])
        SELECT
			i.Id
           ,acd.DocumentId 
		FROM
           inserted i
		   INNER JOIN AllCourseDocument acd on i.OrganisationId = acd.OrganisationId
		   

	
GO
ALTER TRIGGER TRG_Payment_INSERTUPDATE ON dbo.Payment AFTER INSERT, UPDATE
	AS
	BEGIN
		BEGIN TRY
			SELECT DISTINCT
				(CASE WHEN OPT.OrganisationId IS NOT NULL THEN OPT.OrganisationId
					WHEN PM.OrganisationId IS NOT NULL THEN PM.OrganisationId
					WHEN OU.OrganisationId IS NOT NULL AND SAU.Id IS NULL THEN OU.OrganisationId
					ELSE NULL END)		AS OrganisationId
				, I.Id					AS PaymentId
			INTO #OrganisationPayment
			FROM INSERTED I
			LEFT JOIN [dbo].[OrganisationPaymentType] OPT		ON OPT.PaymentTypeId = I.PaymentTypeId	--Find Organisation By Payment Type
			LEFT JOIN [dbo].[PaymentMethod] PM					ON PM.Id = I.PaymentMethodId -- In Case No Payment Type Use Payment Method to Get Organisation
			LEFT JOIN [dbo].[OrganisationUser] OU				ON OU.UserId = I.CreatedByUserId -- If No Payment Method The Use the User Id
			LEFT JOIN [dbo].[SystemAdminUser] SAU				ON SAU.UserId = I.CreatedByUserId -- DO Not Allow User Organisation if a System Administration User Id is Used
			LEFT JOIN [dbo].[OrganisationPayment] OP			ON OP.PaymentId = I.Id
			WHERE OP.Id IS NULL; --Only Insert if Not Already on the Table
			/*
				NB. There is a Chance here that a Payment Created by a System Administrator will not get assigned to an Organisation.
					There is a Trigger in the Table ClientPayment that will pick it up there.
			*/
			INSERT INTO [dbo].[OrganisationPayment] (OrganisationId, PaymentId)
			SELECT DISTINCT
				OP.OrganisationId		AS OrganisationId
				, OP.PaymentId			AS PaymentId
			FROM #OrganisationPayment OP
			INNER JOIN Organisation O							ON O.Id = OP.OrganisationId -- Only Valid Organisations. Will Exclude NULLS too
			LEFT JOIN [dbo].[OrganisationPayment] OP2			ON OP2.PaymentId = OP.PaymentId
			WHERE OP.OrganisationId IS NOT NULL
			AND OP2.Id IS NULL; --Only Insert if Not Already on the Table
			;
		END TRY
		BEGIN CATCH
			--SET @errMessage = '*Error Inserting Into OrganisationPayment Table';
			/*
				We Don't Need to do anything with This at the moment 
				If It is a Duplicate then it should not hapen anyway.
			*/
		END CATCH
	END;
		
GO
ALTER TRIGGER TRG_ClientOnlineEmailChangeRequest_Update ON dbo.ClientOnlineEmailChangeRequest AFTER UPDATE
		AS

		BEGIN
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
		END

		
GO
ALTER TRIGGER [dbo].[TRG_CourseTableCalculateLastBookingDate_INSERT] ON [dbo].[Course] FOR INSERT
		AS

		BEGIN
			
			DECLARE @Id as INT;
			
			SELECT @Id = i.Id FROM inserted i;
			
			EXEC [dbo].[uspCalculateLastBookingDate] @Id;

		END

		
GO
ALTER TRIGGER TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT ON Course FOR INSERT
AS

		INSERT INTO [dbo].[CourseDocument]
            ([CourseId]
           ,[DocumentId])
        SELECT
			i.Id
           ,actd.DocumentId 
		FROM
           inserted i
		   INNER JOIN CourseType ct on ct.id = i.CourseTypeId
		   AND ct.OrganisationId = i.OrganisationId
		   INNER JOIN AllCourseTypeDocument actd on i.CourseTypeId = actd.CourseTypeId


		
GO
ALTER TRIGGER [dbo].[TRG_CourseDateTableCalculateLastBookingDate_INSERT] ON [dbo].[CourseDate] FOR INSERT
		AS

		BEGIN
			
			DECLARE @CourseId as INT;
			
			SELECT @CourseId = i.CourseId FROM inserted i;
			
			EXEC [dbo].[uspCalculateLastBookingDate] @CourseId;

		END

	
GO
ALTER TRIGGER TRG_EmailServiceCredential_INSERTUPDATE ON EmailServiceCredential FOR INSERT, UPDATE
	AS
	BEGIN
   
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

	END
		
GO
ALTER TRIGGER TRG_VenueToUpdateTrainerVenueDistance_Update ON dbo.Venue AFTER UPDATE
AS

BEGIN
	DECLARE @trainerId INT
		  , @venueId INT
		  , @trainerVenueCount INT
		  , @counter INT = 1;

	SELECT @venueId = i.id FROM Inserted i;
	
	-- Retrieves a count of rows which matches the trainer id. This will be used for the loop.
	SELECT @trainerVenueCount = COUNT(Id)
	FROM dbo.TrainerVenue
	WHERE VenueId = @VenueId;

	--Loops through the rows executing the stored proc for each row 
	IF (@trainerVenueCount > 0)
	BEGIN
		WHILE (@counter <= @trainerVenueCount)
		BEGIN
			SELECT TOP(1) @trainerId = TrainerId
			FROM dbo.TrainerVenue
			WHERE VenueId = @venueId;

			EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;

			SET @counter = @counter + 1;
		END
	END

END

	
GO
ALTER TRIGGER TRG_Course_LogChange_InsertUpdateDelete ON dbo.Course AFTER UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_LogChange_InsertUpdateDelete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
						
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT 
				ISNULL(I.Id, D.Id)									AS CourseId
				, GETDATE()											AS DateCreated
				, (CASE WHEN I.Id IS NULL
						THEN dbo.udfGetSystemUserId()
						ELSE ISNULL(I.UpdatedByUserId, dbo.udfGetSystemUserId()) END)			AS CreatedByUserId
				, (CASE WHEN I.Id IS NULL
						THEN 'Course Deleted'
						ELSE 'Course Updated' END)					AS Item
				, (CASE WHEN I.Id IS NOT NULL
						THEN 'Ref: ' + ISNULL(D.Reference, '')
							+ ' ; Course Type: ' + ISNULL(CTD.Title, '')
						ELSE NULL END)								AS NewValue
				, (CASE WHEN I.Id IS NULL
						THEN 'Ref: ' + ISNULL(D.Reference, '')
							+ ' ; Course Type: ' + ISNULL(CTD.Title, '')
						ELSE NULL END)								AS OldValue
			FROM DELETED D
			LEFT JOIN INSERTED I ON I.Id = D.Id
			LEFT JOIN CourseType CTD ON CTD.Id = D.CourseTypeId
			WHERE D.Id IS NOT NULL;
			
			--Update Only Bit
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT 
				ISNULL(I.Id, D.Id)											AS CourseId
				, GETDATE()													AS DateCreated
				, ISNULL(I.UpdatedByUserId, dbo.udfGetSystemUserId())		AS CreatedByUserId
				, (CASE WHEN I.Reference != D.Reference THEN 'Course Reference Changed'
						WHEN I.CourseTypeId != D.CourseTypeId THEN 'Course Type Changed'
						WHEN I.PracticalCourse != D.PracticalCourse THEN 'Course Practical Setting Changed'
						WHEN I.TheoryCourse != D.TheoryCourse THEN 'Course Theory Setting Changed'
						WHEN I.OrganisationId != D.OrganisationId THEN 'Course Organisation Changed'
						ELSE 'Course Updated' END)					AS Item
				, (CASE WHEN I.Reference != D.Reference THEN I.Reference
						WHEN I.CourseTypeId != D.CourseTypeId THEN CAST(I.CourseTypeId AS VARCHAR)
						WHEN I.PracticalCourse != D.PracticalCourse THEN (CASE WHEN I.PracticalCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.TheoryCourse != D.TheoryCourse THEN (CASE WHEN I.TheoryCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.OrganisationId != D.OrganisationId THEN CAST(I.OrganisationId AS VARCHAR)
						ELSE 'Course Updated' END)					AS NewValue
				, (CASE WHEN I.Reference != D.Reference THEN D.Reference
						WHEN I.CourseTypeId != D.CourseTypeId THEN CAST(D.CourseTypeId AS VARCHAR)
						WHEN I.PracticalCourse != D.PracticalCourse THEN (CASE WHEN D.PracticalCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.TheoryCourse != D.TheoryCourse THEN (CASE WHEN D.TheoryCourse = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.OrganisationId != D.OrganisationId THEN CAST(D.OrganisationId AS VARCHAR)
						ELSE 'Course Updated' END)					AS OldValue
			FROM DELETED D
			INNER JOIN INSERTED I ON I.Id = D.Id
			WHERE I.Reference != D.Reference
			OR I.CourseTypeId != D.CourseTypeId
			OR I.PracticalCourse != D.PracticalCourse
			OR I.TheoryCourse != D.TheoryCourse
			OR I.OrganisationId != D.OrganisationId
			;


		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_TrainerOrganisation_Insert ON dbo.TrainerOrganisation AFTER INSERT
AS

BEGIN

	DECLARE @Id INT
		  , @rowCount INT
		  , @counter INT = 1
		  , @venueId INT
		  , @trainerId INT;

	-- Inserts the appropriate Trainer and Venue Id's in to a temporary table
	-- that will be looped through later.
	SELECT tro.TrainerId
	 , tro.OrganisationId
	 , v.Id as VenueId
	INTO #TrainerVenue
	FROM TrainerOrganisation tro
	INNER JOIN dbo.Venue v ON tro.OrganisationId = v.OrganisationId
	INNER JOIN dbo.VenueAddress va ON va.VenueId = v.Id
	INNER JOIN dbo.[Location] l ON l.Id = va.LocationId
	INNER JOIN dbo.TrainerLocation tl ON tro.TrainerId = tl.TrainerId
	INNER JOIN dbo.[Location] trainerloc ON trainerloc.Id = tl.LocationId
	WHERE tro.Id = @Id;

	-- Gets the row count of the table for use in the loop later
	SELECT @rowCount = @@ROWCOUNT;

	-- Adds an Id to the temp table which will be used for the loop
	ALTER TABLE #TrainerVenue
	ADD Id INT IDENTITY(1,1) PRIMARY KEY;

	WHILE @counter <= @rowCount
	BEGIN
		SELECT @venueId = VenueId, @trainerId = TrainerId FROM #TrainerVenue WHERE Id = @counter;

		-- Checks to see if there's already an entry on TrainerVenue for the venue and trainer
		-- If there is then it skips it, if there isn't it inserts in to TrainerVenue then calls
		-- The stored procedure to calculate distance
		IF NOT EXISTS(SELECT TOP(1) TrainerId, VenueId FROM dbo.TrainerVenue WHERE TrainerId = @TrainerId AND VenueId = @VenueId)
		BEGIN
			INSERT INTO dbo.TrainerVenue(trainerId, VenueId, DateUpdated, UpdatedByUserId)
			VALUES(@trainerId, @venueId, GETDATE(), dbo.udfGetSystemUserId());
			EXEC uspUpdateTrainerVenueDistance @trainerId, @VenueId;
		END

		SET @counter = @counter + 1;
	END

	DROP TABLE #TrainerVenue;

END
	
GO
ALTER TRIGGER TRG_RefundPayment_Insert ON dbo.RefundPayment AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'RefundPayment', 'dbo.TRG_RefundPayment_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @refundPaymentId INT
					, @refundId INT
					, @paymentId INT
					, @insertedPaymentId INT
					, @refundReference VARCHAR(100)
					, @clientId INT
					, @refundTransactionDate DATETIME
					, @refundAmount MONEY
					, @refundCreatedByUserId INT
					, @refundPaymentName VARCHAR(320)
					, @paymentTypeId INT
					, @paymentMethodId INT
					, @cardPayment BIT
					, @organisationId INT
					, @courseId INT
					, @atlasSystemUserId INT;


			SELECT    @refundId = i.RefundId
					, @paymentId = i.PaymentId
			 FROM Inserted i;

			SELECT @refundAmount = ISNULL(Amount * -1, 0)
					, @refundTransactionDate = TransactionDate
					, @refundReference = Reference
					, @refundCreatedByUserId = CreatedByUserId
					, @refundPaymentName = PaymentName
			FROM dbo.Refund
			WHERE Id = @refundId;

			SELECT @atlasSystemUserId = dbo.udfGetSystemUserId();

			SELECT @paymentTypeId = p.PaymentTypeId
					, @paymentMethodId = p.PaymentMethodId
					, @cardPayment = p.CardPayment
					, @organisationId = op.OrganisationId
					, @clientId = cp.ClientId
					, @courseId = ccp.CourseId
			FROM dbo.Payment p
			INNER JOIN dbo.OrganisationPayment op ON p.Id = op.PaymentId
			LEFT JOIN dbo.ClientPayment cp ON p.Id = cp.PaymentId
			LEFT JOIN dbo.CourseClientPayment ccp ON p.Id = ccp.PaymentId
			WHERE p.Id = @paymentId;

			INSERT INTO dbo.Payment (
									DateCreated
									, TransactionDate
									, Amount
									, PaymentTypeId
									, PaymentMethodId
									, CreatedByUserId
									, CardPayment
									, Refund
									, UpdatedByUserId
									, PaymentName
									, Reference
									, NetcallPayment
									)

							VALUES (
									GETDATE()
									, @refundTransactionDate 
									, @refundAmount
									, @paymentTypeId
									, @paymentMethodId
									, @refundCreatedByUserId
									, @cardPayment
									, 'True' --refund
									, NULL --UpdatedByUserId
									, @refundPaymentName
									, @refundReference--reference
									, NULL --NetcallPayment
									)

			-- Grab the new created paymentId for use in following updates and inserts.
			SELECT @insertedPaymentId = SCOPE_IDENTITY();

			PRINT @insertedPaymentId

			IF(@insertedPaymentId IS NOT NULL)
			BEGIN
				UPDATE RefundPayment
				SET RefundPaymentId = @insertedPaymentId
				WHERE PaymentId = @paymentId AND RefundPaymentId IS NULL;

				INSERT INTO dbo.OrganisationPayment (
													OrganisationId
													, PaymentId
													)

				SELECT @organisationId, @insertedPaymentId
				WHERE NOT EXISTS(SELECT * 
								FROM dbo.OrganisationPayment 
								WHERE Organisationid = @organisationId 
									AND PaymentId = @insertedPaymentId)

				IF(((SELECT COUNT(*) FROM dbo.ClientPayment WHERE PaymentId = @paymentId) > 0)
					AND (@clientId IS NOT NULL))
				BEGIN
					INSERT INTO dbo.ClientPayment (
													ClientId
													, PaymentId
													, AddedByUserId
													)

											VALUES ( 
													@clientId
													, @insertedPaymentId
													, @atlasSystemUserId
													)
				END

				IF(((SELECT COUNT(*) FROM dbo.CourseClientPayment WHERE PaymentId = @paymentId) > 0)
					AND (@clientId IS NOT NULL)
					AND (@courseId IS NOT NULL))
				BEGIN
					PRINT 'Insie of CourseClientPayment insert'
					INSERT INTO dbo.CourseClientPayment (
														CourseId
														, ClientId
														, PaymentId
														, AddedByUserId
														)

												VALUES ( 
														@courseId
														, @clientId
														, @insertedPaymentId
														, @atlasSystemUserId
														)

				END--Inserting in to CourseClientPayment
			END  --IF(@insertedPaymentId IS NOT NULL)
		END --END PROCESS
	END


	
GO
ALTER TRIGGER [dbo].[TRG_CourseDate_InsertUpdateDelete] ON [dbo].[CourseDate]
	AFTER INSERT, UPDATE, DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			--Trigger Logging
			EXEC dbo.uspLogTriggerRunning 'CourseDate', 'TRG_CourseDate_InsertUpdateDelete', @insertedRows, @deletedRows;
			-----------------------------------------------------------------------------------------------------------------------
			
			INSERT INTO CourseLog
						(CourseId,
						DateCreated,
						CreatedByUserId,
						Item,
						NewValue,
						OldValue
						)
			SELECT
				ISNULL(I.CourseId, D.CourseId)						AS CourseID
				, GETDATE()											AS DateCreated
				, ISNULL(D.CreatedByUserId, I.CreatedByUserId)		AS CreatedByUserId
				, (CASE WHEN I.DateStart != D.DateStart THEN 'Course Start Date'
						WHEN I.DateEnd != D.DateEnd THEN 'Course End Date'
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN 'Attendance Updated'
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN 'Attendance Verification Changed'
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN 'Course Session Changed'
						ELSE '' END)								AS Item
				, (CASE WHEN I.DateStart != D.DateStart THEN CONVERT(VARCHAR(MAX), I.DateStart, 106)
						WHEN I.DateEnd != D.DateEnd THEN CONVERT(VARCHAR(MAX), I.DateEnd, 106)
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN (CASE WHEN I.AttendanceUpdated = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN (CASE WHEN I.AttendanceVerified = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN ITS.SessionTitle
						ELSE '' END)								AS NewValue
				, (CASE WHEN I.DateStart != D.DateStart THEN CONVERT(VARCHAR(MAX), D.DateStart, 106)
						WHEN I.DateEnd != D.DateEnd THEN CONVERT(VARCHAR(MAX), D.DateEnd, 106)
						WHEN I.AttendanceUpdated != D.AttendanceUpdated THEN (CASE WHEN D.AttendanceUpdated = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AttendanceVerified != D.AttendanceVerified THEN (CASE WHEN D.AttendanceVerified = 'True' THEN 'True' ELSE 'False' END)
						WHEN I.AssociatedSessionNumber != D.AssociatedSessionNumber THEN DTS.SessionTitle
						ELSE '' END)								AS OldValue
			FROM INSERTED I
			INNER JOIN DELETED D ON D.Id = I.Id
			LEFT JOIN dbo.vwTrainingSession ITS ON ITS.SessionNumber = I.AssociatedSessionNumber
			LEFT JOIN dbo.vwTrainingSession DTS ON DTS.SessionNumber = D.AssociatedSessionNumber
		END
	END

	
GO
ALTER TRIGGER TRG_DORSTrainerLicenceForDORSTrainerLicenceStateAndDORSTrainerLicenceType_INSERT ON DORSTrainerLicence AFTER INSERT
	AS

	BEGIN
         DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
         DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
         IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
         BEGIN 
                
            EXEC uspLogTriggerRunning 'DORSTrainerLicence', 'TRG_DORSTrainerLicenceForDORSTrainerLicenceStateAndDORSTrainerLicenceType_INSERT', @insertedRows, @deletedRows;

			INSERT INTO [dbo].[DORSTrainerLicenceState]
						([Identifier]
						,[Name]
						,[UpdatedByUserId])
			SELECT
					(CASE WHEN NOT EXISTS(SELECT * FROM [dbo].[DORSTrainerLicenceState])
						THEN 1
						ELSE (SELECT MAX([Identifier]) + 1 FROM [dbo].[DORSTrainerLicenceState])
						END) AS Identifier
						,i.DORSTrainerLicenceStateName AS [Name]
						,[dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
			FROM Inserted i
			LEFT JOIN [dbo].[DORSTrainerLicenceState] T ON T.[Name] = i.DORSTrainerLicenceStateName
			WHERE T.Id IS NULL;

			INSERT INTO [dbo].[DORSTrainerLicenceType]
						([Identifier]
						,[Name]
						,[UpdatedByUserId])
			SELECT
					(CASE WHEN NOT EXISTS(SELECT * FROM [dbo].[DORSTrainerLicenceType])
						THEN 1
						ELSE (SELECT MAX([Identifier]) + 1 FROM [dbo].[DORSTrainerLicenceType])
						END) AS Identifier
						,i.DORSTrainerLicenceTypeName AS [Name]
						,[dbo].[udfGetSystemUserId]() AS [UpdatedByUserId]
			FROM Inserted i
			LEFT JOIN [dbo].[DORSTrainerLicenceType] T ON T.[Name] = i.DORSTrainerLicenceTypeName
			WHERE T.Id IS NULL;

		END --END PROCESS
	END


		
GO
ALTER TRIGGER TRG_OrganisationAdminUserToAddSystemSupportUser_INSERT ON OrganisationAdminUser FOR INSERT
AS

		
		DECLARE @AtlasSystemUserId INT;
		SELECT @AtlasSystemUserId = [AtlasSystemUserId] FROM [dbo].[SystemControl];


		INSERT INTO [dbo].[SystemSupportUser]
		(UserId, DateAdded, OrganisationId, AddedByUserId)
		SELECT  i.UserId, GETDATE(), i.OrganisationId, @AtlasSystemUserId
		FROM inserted i;


		
GO
ALTER TRIGGER TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT ON Document FOR INSERT
AS

	
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
			

	
GO
ALTER TRIGGER TRG_DORSLicenceCheckCompleted_INSERT ON DORSLicenceCheckCompleted FOR INSERT, UPDATE
	AS	
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

	
GO
ALTER TRIGGER TRG_RefundPayment_Delete ON dbo.RefundPayment AFTER DELETE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'RefundPayment', 'dbo.TRG_RefundPayment_Delete', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @refundPaymentId INT
					, @organisationPaymentId INT
					, @clientPaymentId INT
					, @courseClientPaymentId INT;

			SELECT @refundPaymentId = d.RefundPaymentId
					, @organisationPaymentId = op.Id
					, @clientPaymentId = cp.Id
					, @courseClientPaymentId = ccp.Id
			FROM Deleted d
			LEFT JOIN dbo.OrganisationPayment op ON d.RefundPaymentId = op.PaymentId
			LEFT JOIN dbo.ClientPayment cp ON d.RefundPaymentId = cp.PaymentId
			LEFT JOIN dbo.CourseClientPayment ccp ON d.RefundPaymentId = ccp.PaymentId;

			IF(@organisationPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.OrganisationPayment
				WHERE Id = @organisationPaymentId;
			END

			IF(@clientPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.ClientPayment
				WHERE Id = @clientPaymentId;
			END

			IF(@courseClientPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.CourseClientPayment
				WHERE Id = @courseClientPaymentId;
			END

			IF(@refundPaymentId IS NOT NULL)
			BEGIN
				DELETE FROM dbo.Payment
				WHERE Id = @refundPaymentId;
			END
		END --END PROCESS
	END

	
GO
ALTER TRIGGER TRG_CourseDate_InsertUpdate_CourseSessionAllocation ON dbo.CourseDate AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseDate', 'TRG_CourseDate_InsertUpdate_CourseSessionAllocation', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			SELECT @CourseId = ISNULL(I.CourseId, D.CourseId)
			FROM INSERTED I
			FULL JOIN DELETED D ON D.Id = I.Id;
			
			IF (@CourseId >= 0)
			BEGIN
				EXEC uspCourseSessionAllocationRefreshDefault @CourseId;
			END
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_Course_Update_CourseSessionAllocation ON dbo.Course AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_Update_CourseSessionAllocation', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			--Only Do this if the Practical Or Theory Settings have Changed
			SELECT @CourseId = ISNULL(I.Id, D.Id)
			FROM INSERTED I
			INNER JOIN DELETED D ON D.Id = I.Id
			WHERE ISNULL(I.PracticalCourse, 'False') != ISNULL(D.PracticalCourse, 'False')
			OR ISNULL(I.TheoryCourse, 'False') != ISNULL(D.TheoryCourse, 'False');

			IF (@CourseId >= 0)
			BEGIN
				EXEC uspCourseSessionAllocationRefreshDefault @CourseId;
			END

		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_CourseSchedule_UPDATE ON CourseSchedule FOR UPDATE
AS

DECLARE @bit INT ,
       @field INT ,
       @maxfield INT ,
       @char INT ,
       @fieldname VARCHAR(128) ,
       @TableName VARCHAR(128) ,
       @PKCols VARCHAR(1000) ,
       @sql VARCHAR(2000), 
       @UserName VARCHAR(128) = 'CreatedByUserId' ,
	   @CourseId VARCHAR(128) = 'CourseId',
       @Type CHAR(1) ,
       @PKSelect VARCHAR(1000)       

--You will need to change @TableName to match the table to be audited
SELECT @TableName = 'CourseSchedule'

-- Action
IF EXISTS (SELECT * FROM inserted)
       IF EXISTS (SELECT * FROM deleted)
               SELECT @Type = 'U'
       ELSE
               SELECT @Type = 'I'
ELSE
       SELECT @Type = 'D'

-- get list of columns
SELECT * INTO #ins FROM inserted
SELECT * INTO #del FROM deleted

-- Get primary key columns for full outer join
SELECT @PKCols = COALESCE(@PKCols + ' and', ' on') 
               + ' i.' + c.COLUMN_NAME + ' = d.' + c.COLUMN_NAME
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,

              INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME

-- Get primary key select for insert
SELECT @PKSelect = '+convert(varchar(100),coalesce(i.' + COLUMN_NAME +',d.' + COLUMN_NAME + '))' 
       FROM    INFORMATION_SCHEMA.TABLE_CONSTRAINTS pk ,
               INFORMATION_SCHEMA.KEY_COLUMN_USAGE c
       WHERE   pk.TABLE_NAME = @TableName
       AND     CONSTRAINT_TYPE = 'PRIMARY KEY'
       AND     c.TABLE_NAME = pk.TABLE_NAME
       AND     c.CONSTRAINT_NAME = pk.CONSTRAINT_NAME
	   
SELECT @field = 0, 
       @maxfield = MAX(ORDINAL_POSITION) 
       FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @TableName
WHILE @field < @maxfield
BEGIN		
       SELECT @field = MIN(ORDINAL_POSITION) 
               FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = @TableName 
               AND ORDINAL_POSITION > @field
       SELECT @bit = (@field - 1 )% 8 + 1
       SELECT @bit = POWER(2,@bit - 1)
       SELECT @char = ((@field - 1) / 8) + 1
       IF SUBSTRING(COLUMNS_UPDATED(),@char, 1) & @bit > 0
                                       OR @Type IN ('I','D')
       BEGIN
               SELECT @fieldname = COLUMN_NAME 
                       FROM INFORMATION_SCHEMA.COLUMNS 
                       WHERE TABLE_NAME = @TableName 
                       AND ORDINAL_POSITION = @field
               
               SELECT @sql = '
						insert CourseLog (    
										CourseId,
										DateCreated,
										CreatedByUserId,
										Item,
										OldValue,
										NewValue
									   )
						select convert(int,coalesce(i.' + @CourseId +',d.' + @CourseId + '))
							  ,convert(varchar(19),getdate())
							  ,convert(int,coalesce(i.' + @UserName +',d.' + @UserName + '))
							  ,''' + @fieldname + '''
							  ,convert(varchar(1000),d.' + @fieldname + ')' + '
							  ,convert(varchar(1000),i.' + @fieldname + ')' + ' 
							  from #ins i full outer join #del d'
							   + @PKCols
							   + ' where i.' + @fieldname + ' <> d.' + @fieldname 
							   + ' or (i.' + @fieldname + ' is null and  d.'
														+ @fieldname
														+ ' is not null)' 
							   + ' or (i.' + @fieldname + ' is not null and  d.' 
														+ @fieldname
														+ ' is null)'  
               EXEC (@sql)
       END
END

	
GO
ALTER TRIGGER TRG_Course_BeforeInsertCheck_Insert ON dbo.Course AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_BeforeInsertCheck_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE C
			SET C.Available = ISNULL(I.Available, 'False')
			, C.DateCreated = ISNULL(I.DateCreated, GETDATE())
			FROM INSERTED I
			INNER JOIN Course C ON C.Id = I.Id
			WHERE I.DateCreated IS NULL OR I.Available IS NULL
			;

		END --END PROCESS
		
	END


		
GO
ALTER TRIGGER [dbo].[TRG_CourseStencil_InsertUpdate] ON [dbo].[CourseStencil] AFTER INSERT, UPDATE
		AS
			DECLARE @MonitorThisTrigger BIT = 'True';

			IF (@MonitorThisTrigger = 'True')
			BEGIN
				INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
				VALUES (GETDATE()
						, 'TRG_CourseStencil_InsertUpdate'
						, (SELECT TOP 1 id FROM INSERTED)
						, 'INSERT/UPDATE Trigger fired'
						);
			END
			BEGIN
				DECLARE @insertedId INT
					, @createCourses BIT
					, @dateCoursesCreated DATETIME
					, @removeCourses BIT
					, @dateCoursesRemoved DATETIME;

				SELECT @insertedId = i.id
					, @createCourses = ISNULL(i.CreateCourses, 'False')
					, @dateCoursesCreated = i.DateCoursesCreated
					, @removeCourses = ISNULL(i.RemoveCourses, 'False')
					, @dateCoursesRemoved = i.DateCoursesRemoved

				FROM inserted i

				IF(@createCourses = 'True') AND (@dateCoursesCreated IS NULL)
				BEGIN
					IF (@MonitorThisTrigger = 'True')
					BEGIN
						INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
						VALUES (GETDATE()
								, 'TRG_CourseStencil_InsertUpdate'
								, @insertedId
								, 'Calling SP uspCreateCoursesFromCourseStencil'
								);
					END
					EXEC dbo.uspCreateCoursesFromCourseStencil @insertedId;


				END

				ELSE IF (@removeCourses = 'True') AND (@dateCoursesRemoved IS NULL)
				BEGIN
					IF (@MonitorThisTrigger = 'True')
					BEGIN
						INSERT INTO ProcessMonitor ([Date], [ProcessName], [Identifier], [Comments])
						VALUES (GETDATE()
								, 'TRG_CourseStencil_InsertUpdate'
								, @insertedId
								, 'Calling SP uspRemoveCoursesFromCourseStencil'
								);
					END
					EXEC dbo.uspRemoveCoursesFromCourseStencil @insertedId;
				END	

			END


	
GO
ALTER TRIGGER TRG_CancelledRefund_Insert ON dbo.CancelledRefund AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CancelledRefund', 'dbo.TRG_CancelledRefund_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
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
	END

		
GO
ALTER TRIGGER TRG_CourseCloneRequest_Insert ON dbo.CourseCloneRequest AFTER INSERT
AS

BEGIN
	SET DATEFIRST 1; -- sets first day of the week to Monday

	CREATE TABLE #PreferredDates([Date] DATETIME);

	CREATE TABLE #Courses 
				( [Date] DATETIME
				, CourseTypeId INT
				, OrganisationId INT
				, Reference VARCHAR(100)
				, CreatedByUserId INT
				, CourseTypeCategoryId INT
				, TrainersRequired INT
				, Available BIT
				, sendAttendanceDORS BIT
				, DefaultStartTime VARCHAR(5)
				, DefaultEndTime VARCHAR(5));

	CREATE TABLE #CourseDateTime
				(StartDateTime DATETIME
				, EndDateTime DATETIME
				, CourseId INT
				, createdByUserId INT
				, DateUpdated DATETIME);

	DECLARE @Id INT
		  , @organisationId INT
		  , @courseId INT
		  , @courseTypeId INT
		  , @courseTypeCategoryId INT
		  , @requestedByUserId INT
		  , @dateRequested DATETIME
		  , @startDate DATETIME
		  , @endDate DATETIME
		  , @courseReferenceGeneratorId INT
		  , @useSameReference BIT
		  , @useSameTrainers BIT
		  , @maxCourses INT
		  , @weeklyCourses BIT
		  , @monthlyCourses BIT
		  , @everyNWeeks INT
		  , @everyNMonths INT
		  , @dayOfWeek INT
		  , @dayOfMonth INT
		  , @durationBetweenCourses INT
		  , @firstEntry DATETIME
		  , @count INT
		  , @newStartDate DATETIME
		  , @newEndDate DATETIME;

	SELECT @Id = Id
		  ,@organisationId = OrganisationId
		  ,@courseId = CourseId
		  ,@courseTypeId = CourseTypeId
		  ,@courseTypeCategoryId = CourseTypeCategoryId
		  ,@requestedByUserId = RequestedByUserId
		  ,@dateRequested = DateRequested
		  ,@startDate = StartDate
		  ,@endDate = EndDate
		  ,@courseReferenceGeneratorId = CourseReferenceGeneratorId
		  ,@useSameReference = UseSameReference
		  ,@useSameTrainers = UseSameTrainers
		  ,@maxCourses = MaxCourses
		  ,@weeklyCourses = WeeklyCourses
		  ,@monthlyCourses = MonthlyCourses
		  ,@everyNWeeks = EveryNWeeks
		  ,@everyNMonths = EveryNMonths

		  FROM inserted;

	IF (@CourseId IS NOT NULL)
	BEGIN
		--Gets the day of the week the original course was on
		SELECT @dayOfWeek = DATEPART(dw, cd.DateStart) 
		FROM dbo.Course c
		INNER JOIN dbo.CourseDate cd ON c.Id = cd.CourseId
		WHERE c.Id = @CourseId;

		--Gets the day of the month the original course was on
		SELECT @dayOfMonth = DAY(cd.DateStart) 
		FROM dbo.Course c
		INNER JOIN dbo.CourseDate cd ON c.Id = cd.CourseId
		WHERE c.Id = @CourseId;

		--- Do a check here for maxcourse = 1. If nada then populate prefdates with info, then move in the below as an else.

		IF (@maxCourses = 1)
		BEGIN
			INSERT INTO #PreferredDates([Date])
			VALUES (@startDate)
		END

		ELSE IF (@maxCourses > 1)

			WITH dateRange AS
			(
			SELECT dt =  @startDate
			WHERE DATEADD(dd, 1, @startDate) <= @endDate
			UNION ALL
			SELECT DATEADD(dd, 1, dt)
			FROM dateRange
			WHERE DATEADD(dd, 1, dt) <= @endDate
			)

			INSERT INTO #PreferredDates ([Date])
			SELECT dt
			FROM dateRange
			OPTION (MAXRECURSION 0);

			IF(@weeklyCourses = 'True')
			BEGIN
				DELETE FROM #PreferredDates
				WHERE DATEPART(dw, [Date]) <> @dayOfWeek
			END
			ELSE IF (@monthlyCourses = 'True')
			BEGIN
				DELETE FROM #PreferredDates
				WHERE DAY([Date]) <> DAY(@dayOfMonth)
			END
			ELSE IF (@everyNWeeks IS NOT NULL)
			BEGIN
				--Selects first entry where the day of the week matches the original course day of the week
				SELECT @firstEntry = MIN([Date]) 
				FROM #PreferredDates 
				WHERE DATEPART(dw, [Date]) = @dayOfWeek

				--Deletes all entries before the first relevant day
				DELETE FROM #PreferredDates
				WHERE [Date] < @firstEntry

				SET @durationBetweenCourses = @everyNWeeks * 7;

				--Removes unrequired days
				WITH dailySkip AS 
				(SELECT pd.*, ROW_NUMBER() OVER (ORDER BY pd.[Date]) AS rank
				FROM #PreferredDates pd)
				DELETE dailySkip
				WHERE rank%@durationBetweenCourses -1 <> 0;
			END
			ELSE IF (@everyNMonths IS NOT NULL)
			BEGIN
				
				SELECT @firstEntry = MIN([Date]) 
				FROM #PreferredDates 
				WHERE DAY([Date]) = @dayOfMonth;

				--Deletes date range as not required
				TRUNCATE TABLE #PreferredDates;

				--Repopulates temporary table with relevant dates
				--For example, the 15th of every month between @startDate and @endDate 
				WHILE @firstEntry <= @endDate
				BEGIN
					INSERT INTO #PreferredDates([Date])
					VALUES(@firstEntry)
					SET @firstEntry = DATEADD(month, @everyNMonths, @firstEntry);
				END
			END

			--Add identity column which will be used for the below loop
			ALTER TABLE #PreferredDates
			ADD TempId INT IDENTITY(1,1)

			SET @count = 1

			WHILE @count <= @maxCourses 
			BEGIN
				SET @newStartDate = NULL
				SET @newEndDate = NULL

				SELECT @newStartDate = [Date] FROM #PreferredDates WHERE TempId = @count;
				SELECT @newEndDate = @newStartDate FROM #PreferredDates WHERE TempId = @count;

				If (@newStartDate IS NOT NULL AND @newEndDate IS NOT NULL)
				BEGIN
					EXEC dbo.uspCreateCourseClone @Id, @courseId, @newStartDate, @newEndDate, @courseReferenceGeneratorId, @useSameReference, @useSameTrainers
				END
				SET @count = @count + 1;
			END
	END
END


	
GO
ALTER TRIGGER TRG_EmailServiceEmailsSent_INSERT ON EmailServiceEmailsSent FOR INSERT
	AS	
	BEGIN
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
	END
GO
ALTER TRIGGER dbo.TRG_CourseClientTransferRequest_Insert ON dbo.CourseClientTransferRequest AFTER INSERT
AS

BEGIN

	DECLARE @OrganisationId INT --done
		  , @transferFromCourseId INT --done
		  , @transferToCourseId INT --done
		  , @clientId INT --done
		  , @emailContent VARCHAR(1000) --done
		  , @emailSubject VARCHAR(100)
		  , @clientName VARCHAR(640) --done
		  , @clientEmail VARCHAR(320) --done
		  , @fromCourseTypeName VARCHAR(200) --done
		  , @fromCourseDate DATETIME --done
		  , @toCourseTypeName VARCHAR(200) --done
		  , @toCourseDate DATETIME --done
		  , @rebookingFeeAmount MONEY --done
		  , @rebookingFeeMessage VARCHAR(100) --done
		  , @organisationDisplayName VARCHAR(320) --done
		  , @emailFromName VARCHAR(320)
		  , @emailFromAddress VARCHAR(320)
		  , @requestedByUserId INT
		  , @emailRequestedDate DATETIME
		  , @requestedByUserIdForTransferStoredProcedure INT
		  , @clientNameTag CHAR(15) = '<!Client Name!>'
		  , @organisationDisplayNameTag CHAR(29) = '<!Organisation Display Name!>'
		  , @fromCourseTypeNameTag CHAR(25) = '<!From Course Type Name!>'
		  , @fromCourseDateTag CHAR(20) = '<!From Course Date!>'
		  , @toCourseTypeNameTag CHAR(23) = '<!To Course Type Name!>'
		  , @toCourseDateTag CHAR(18) = '<!To Course Date!>'
		  , @rebookingFeeMessageTag CHAR(26) = '<!Re-Booking Fee Message!>';

	SELECT @transferFromCourseId = i.TransferFromCourseId
			, @transferToCourseId = i.TransferToCourseId
			, @clientId = ccFrom.ClientId
			, @fromCourseTypeName = ctFrom.Title
			, @toCourseTypeName = ctTo.Title
			, @organisationId = od.OrganisationId
			, @organisationDisplayName = od.[Name]
			, @clientId = ccFrom.ClientId
			, @rebookingFeeAmount = i.RebookingFeeAmount
			, @emailFromName = osc.FromName
			, @emailFromAddress = osc.FromEmail
	FROM Inserted i
	INNER JOIN dbo.CourseClient ccFrom ON i.TransferFromCourseId = ccFrom.CourseId AND ccFrom.ClientId = i.RequestedByClientId
	INNER JOIN dbo.Course courseFrom ON i.TransferFromCourseId = courseFrom.Id
	INNER JOIN dbo.CourseType ctFrom ON courseFrom.CourseTypeId = ctFrom.Id
	INNER JOIN dbo.Course courseTo ON i.TransferToCourseId = courseTo.Id
	INNER JOIN dbo.CourseType ctTo ON courseTo.CourseTypeId = ctTo.Id
	INNER JOIN dbo.OrganisationDisplay od ON ctFrom.OrganisationId = od.Id
	INNER JOIN dbo.OrganisationSystemConfiguration osc ON od.OrganisationId = osc.OrganisationId
	

	SELECT @clientEmail = EmailAddress
		 , @clientName = CASE WHEN 
							DisplayName IS NULL OR LEN(DisplayName) <= 0
							THEN 
								ISNULL(Firstname, '') + ' ' + ISNULL(Surname, '')
							ELSE
								DisplayName
							END
	FROM vwClientDetail
	WHERE ClientId = @clientId;

	SELECT @fromCourseDate = MIN(DateStart) --could have multiple course dates
	FROM dbo.CourseDate
	WHERE CourseId = @transferFromCourseId;

	SELECT @toCourseDate = MIN(DateStart) --could have multiple course dates
	FROM dbo.CourseDate
	WHERE CourseId = @transferToCourseId;

	SELECT @emailContent = Content
		 , @emailSubject = [Subject]
	FROM OrganisationEmailTemplateMessage 
	WHERE OrganisationId = @organisationId AND Code = 'CourseTransReq';

	IF(@rebookingFeeAmount > 0)
	BEGIN
		SET @rebookingFeeMessage = 'There will be a Course Transfer Fee of £' + CAST(@rebookingFeeAmount AS VARCHAR);
	END
	ELSE IF (@rebookingFeeAmount <= 0 OR @rebookingFeeAmount IS NULL)
	BEGIN
		SET @rebookingFeeMessage = 'There will be no further charge for this course transfer.';
	END

	SET @emailContent = REPLACE(@emailContent, @clientNameTag, @clientName);
	SET @emailContent = REPLACE(@emailContent, @fromCourseTypeNameTag, @fromCourseTypeName);
	SET @emailContent = REPLACE(@emailContent, @fromCourseDateTag, @fromCourseDate);
	SET @emailContent = REPLACE(@emailContent, @toCourseTypeNameTag, @toCourseTypeName);
	SET @emailContent = REPLACE(@emailContent, @toCourseDateTag, @toCourseDate);
	SET @emailContent = REPLACE(@emailContent, @rebookingFeeMessageTag, @rebookingFeeMessage);
	SET @emailContent = REPLACE(@emailContent, @organisationDisplayNameTag, @organisationDisplayName);


	SET @requestedByUserId = dbo.udfGetSystemUserId();
	SET @emailRequestedDate = GETDATE(); -- didn't like me putting GETDATE directly in to the params being passed to sp

	EXEC dbo.uspSendEmail @requestedByUserId
						, @emailFromName
						, @emailFromAddress
						, @clientEmail
						, NULL --cc
						, NULL --bcc
						, @emailsubject
						, @emailContent
						, 'True'
						, @emailRequestedDate 
						, NULL -- emailServiceId
						, @organisationId;

	EXEC dbo.uspCourseTransferClient @transferFromCourseId --@fromCourseId
									, @transferToCourseId --@toCourseId
									, @clientId --@fromClientId
									, @clientId --@toClientId
									, NULL --@transferReason
									, @requestedByUserId;
						
END

	
GO
ALTER TRIGGER TRG_NewOrganisationUser_Insert ON [OrganisationUser] FOR INSERT
	AS
		DECLARE @LoginNotified BIT;
		DECLARE @InsertedUserId INT;
		DECLARE @NewLoginId VARCHAR(320);

		SELECT @InsertedUserId = I.UserId FROM inserted I;
		SELECT @LoginNotified = LoginNotified, @NewLoginId = LoginId FROM [User] WHERE Id = @InsertedUserId;
		
		--Check Login Id is Valid
		IF (LEN(ISNULL(@NewLoginId,'')) <=0 )
		BEGIN
			EXEC uspCreateUserLoginId @UserId = @InsertedUserId;
			SELECT @LoginNotified = LoginNotified, @NewLoginId = LoginId FROM [User] WHERE Id = @InsertedUserId;
		END

		IF((ISNULL(@LoginNotified , 0)) = 0)
		BEGIN
			EXEC dbo.[uspSendNewUserEmail] @userId = @InsertedUserId, @clientId = 0;

			EXEC dbo.[uspSendNewPassword] @InsertedUserId;
		END

	
GO
ALTER TRIGGER TRG_DORSConnection_UPDATE_AND_INSERT ON DORSConnection AFTER UPDATE, INSERT
	AS

	BEGIN

		DECLARE @DorsCode Varchar(4) = 'DORS';
		DECLARE @DorsEnabled Varchar(4) = 'DORS Enabled';
		DECLARE @DorsDisabled Varchar(4) = 'DORS Disabled';
		
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
	END

		
GO
ALTER TRIGGER dbo.TRG_CourseTypeCategory_Insert ON dbo.CourseTypeCategory AFTER INSERT
AS

BEGIN
	DECLARE @courseTypeId INT
		  , @courseTypeCategoryId INT
		  , @organisationId INT;

	SELECT @courseTypeId = i.CourseTypeId
		 , @organisationId = ct.OrganisationId
	FROM Inserted i
	LEFT JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id

	INSERT INTO dbo.CourseTypeCategoryFee(OrganisationId
										, CourseTypeId
										, CourseTypeCategoryId
										, EffectiveDate
										, CourseFee
										, BookingSupplement
										, PaymentDays
										, AddedByUserId
										, DateAdded
										, [Disabled]
										, DisabledByUserId
										, DateDisabled)

								VALUES(@organisationId
									 , @courseTypeId
									 , @courseTypeCategoryId
									 , GETDATE()
									 , NULL
									 , NULL
									 , NULL
									 , dbo.udfGetSystemUserId()
									 , GETDATE()
									 , 'False'
									 , NULL
									 , NULL)
	
	
END
	
GO
ALTER TRIGGER [dbo].[TRG_Client_INSERTUPDATE] ON [dbo].[Client] AFTER UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'Client', 'TRG_Client_INSERTUPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @userId INT
					, @clientId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @userId = i.UserId
					, @clientId = i.Id 
			FROM inserted i;

			SELECT @firstName = FirstName
					, @surname = Surname
					, @capitalisedFirstName = LEFT(UPPER(@firstName), 1) + RIGHT(@firstName, LEN(@firstName)-1)
					, @capitalisedSurname = LEFT(UPPER(@surname), 1) + RIGHT(@surname, LEN(@surname)-1)
			FROM dbo.Client
			WHERE Id = @clientId;

			--Updates Client if the cases don't match
			-- Latin1_General_CS_AS is case sensitive.
			IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
				OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
			BEGIN
				UPDATE dbo.Client
				SET FirstName = @capitalisedFirstName
					, Surname = @capitalisedSurname
				WHERE Id = @clientId;
			END

			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;

		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_ScriptLog_Insert ON dbo.ScriptLog AFTER INSERT
AS

BEGIN
	DECLARE @firstBlock CHAR(3)
		  , @secondBlock CHAR(5)
		  , @scriptName VARCHAR(400)
		  , @scriptStartCharacters CHAR(2);

	SELECT @scriptName = [Name] FROM Inserted i;
	SELECT @scriptStartCharacters = LEFT(@scriptName, 2); --Grabs first 2 characters
	SELECT @firstBlock = SUBSTRING(@scriptName, 3, 3); --Starting from the third character, grabs next 3 characters
	SELECT @secondBlock = SUBSTRING(@scriptName, 7, 5); --Starting from the 7th character, grabs next 5 characters

	UPDATE dbo.SystemControl
	SET DateOfLastDatabaseUpdate = GETDATE()
	  , DatabaseVersionPart2 = DATEPART(YEAR, GETDATE())
	WHERE Id = 1; -- Should only have 1 row in this table, but just in case..

	
	IF(@scriptStartCharacters = 'SP' AND ISNUMERIC(@firstBlock) = 1 AND ISNUMERIC(@secondBlock) = 1) -- evaluating ISNUMERIC didn't like 'True' so had to use 1
	BEGIN
		UPDATE dbo.SystemControl
		SET DatabaseVersionPart3 = 	CAST(@firstBlock AS INT)
			, DatabaseVersionPart4 = CAST(@secondBlock AS FLOAT)
		WHERE Id = 1;
	END

END
	
GO
ALTER TRIGGER [dbo].[TRG_ClientOrganisation_INSERT] ON [dbo].[ClientOrganisation] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'ClientOrganisation', 'TRG_ClientOrganisation_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @userId INT
					, @clientId INT
					, @firstName VARCHAR(320)
					, @surname VARCHAR(320)
					, @capitalisedFirstName VARCHAR(320)
					, @capitalisedSurname VARCHAR(320);

			SELECT @userId = c.UserId
					, @clientId = i.ClientId 
					, @firstName = c.FirstName
					, @surname = c.Surname
					, @capitalisedFirstName = LEFT(UPPER(c.FirstName), 1)+RIGHT(c.FirstName, LEN(c.FirstName)-1)
					, @capitalisedSurname = LEFT(UPPER(c.Surname), 1)+RIGHT(c.Surname, LEN(c.Surname)-1)
			FROM inserted i
			INNER JOIN Client c ON c.Id = i.ClientId;

			--Updates Client if the cases don't match
			-- Latin1_General_CS_AS is case sensitive.
			IF(@firstName != @capitalisedFirstName COLLATE Latin1_General_CS_AS
				OR @surname != @capitalisedSurname COLLATE Latin1_General_CS_AS)
			BEGIN
				UPDATE dbo.Client
				SET FirstName = @capitalisedFirstName
					, Surname = @capitalisedSurname
				WHERE Id = @clientId;
			END

			EXEC dbo.[uspCheckUser] @userId = @UserId, @clientId = @ClientId;

		END --END PROCESS

	END


	
GO
ALTER TRIGGER TRG_Location_UpdateInsert ON dbo.Location AFTER UPDATE, INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'Location', 'TRG_Location_Update', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------

			UPDATE L
				SET L.DateUpdated = GETDATE()
				, L.PostCode = UPPER(ISNULL(L.PostCode,''))
			FROM INSERTED I
			INNER JOIN [Location] L ON I.Id = L.Id;
			
		END --END PROCESS

	END

		
GO
ALTER TRIGGER TRG_DocumentMarkedForDelete_UPDATE ON DocumentMarkedForDelete AFTER UPDATE
AS

BEGIN
		/*Insert a row in to DocumentMarkedForDeleteCancelled when CancelledByUserId is updated from empty to having a UserId*/

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
END

		
GO
ALTER TRIGGER TRG_UserLogin_INSERT ON UserLogin AFTER INSERT
AS
	DECLARE @LoginId varchar(50);
	DECLARE @Success bit;
	
	/* This will just capture single rows. 
	Won't work if multirows are inserted. */
	
	SELECT @LoginId = i.LoginId, @Success = i.Success FROM inserted i;
	/* check for null loginid do not call */
	
	IF @LoginId IS NOT NULL EXEC dbo.usp_SetUserLogin @LoginId, @Success;
	
	/*******************************************************************************************************************/
	
GO
ALTER TRIGGER [dbo].[TRG_CourseGroupEmailRequest_InsertUpdate] ON [dbo].[CourseGroupEmailRequest] AFTER INSERT, UPDATE
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN	
			-- log the trigger in the trigger log
			EXEC uspLogTriggerRunning 'CourseGroupEmailRequest', 'TRG_CourseGroupEmailRequest_InsertUpdate', @insertedRows, @deletedRows;
			
			DECLARE @id INT
				  , @courseId INT
				  , @requestedByUserId INT
				  , @sendAllClients BIT
				  , @sendAllTrainers BIT
				  , @separateEmails BIT
				  , @oneEmailWithHiddenAddresses BIT
				  , @CCEmailAddresses VARCHAR(1000)
				  , @BCCEmailAddresses VARCHAR(1000) 
				  , @subject VARCHAR(1000)
				  , @startDearNamed BIT
				  , @startDearSirMadam BIT
				  , @startToWhomItMayConcern BIT
				  , @content VARCHAR(4000)
				  , @concatenatedContent VARCHAR(4000)
				  , @sendASAP BIT
				  , @sendAfterDateTime DATETIME
				  , @emailsValidatedAndCreated BIT
				  , @dateEmailsValidatedAndCreated DATETIME
				  , @requestRejected BIT
				  , @rejectionReason VARCHAR(200)
				  , @lineBreak VARCHAR(20) = CHAR(13) + CHAR(10)
				  , @recipientCount INT
				  , @cnt INT = 1
				  , @organisationId INT
				  , @fromEmailAddress VARCHAR(320)
				  , @fromName VARCHAR(320)
				  , @toEmailAddress VARCHAR(320)
				  , @salutation VARCHAR(100)
				  , @recipientId INT
				  , @validEmailCheck BIT
				  , @concatenatedEmailsForValidation VARCHAR(8000)
				  , @BCCEmailAddressesCombined VARCHAR(8000) --if @oneEmailWithHiddenAddresses is populated this could potentially be large.
				  , @readyToSend BIT = 'False'
				  , @pendingEmailAttachmentId INT
				  , @firstAttachmentId INT
				  ;


			SELECT @id = I.Id
				, @courseId = I.CourseId
				, @requestedByUserId = I.RequestedByUserId
				, @sendAllClients = I.SendAllClients
				, @sendAllTrainers = I.SendAllTrainers
				, @separateEmails = I.SeparateEmails
				, @oneEmailWithHiddenAddresses = I.OneEmailWithHiddenAddresses
				, @CCEmailAddresses = I.CCEmailAddresses
				, @BCCEmailAddresses = I.BCCEmailAddresses
				, @subject = I.[Subject]
				, @startDearNamed = I.StartDearNamed
				, @startDearSirMadam = I.StartDearSirMadam
				, @startToWhomItMayConcern = I.StartToWhomItMayConcern
				, @content = I.Content
				, @sendASAP = I.SendAsap
				, @sendAfterDateTime = I.SendAfterDateTime
				, @emailsValidatedAndCreated = I.EmailsValidatedAndCreated 
				, @dateEmailsValidatedAndCreated = I.DateEmailsValidatedAndCreated
				, @requestRejected = I.RequestRejected
				, @rejectionReason = I.RejectionReason
				, @organisationId = C.OrganisationId
				, @fromEmailAddress = OSC.FromEmail
				, @fromName = OSC.FromName
				, @readyToSend = I.ReadyToSend
			FROM INSERTED I
			INNER JOIN dbo.Course C ON C.Id = I.CourseId
			INNER JOIN dbo.OrganisationSystemConfiguration OSC ON C.OrganisationId = OSC.OrganisationId
			WHERE I.ReadyToSend = 'True'
			AND ISNULL(EmailsValidatedAndCreated, 'False') = 'False';

			IF (@courseId IS NOT NULL AND @readyToSend = 'True')
			BEGIN
				CREATE TABLE #RecipientIds(RecipientId INT);

				IF(@sendAllClients = 'True')
				BEGIN
					INSERT INTO #RecipientIds(RecipientId)
					SELECT ClientId
					FROM dbo.CourseClient
					WHERE CourseId = @courseId;
				END --IF(@sendAllClients = 'True')
				ELSE IF(@sendAllTrainers = 'True')
				BEGIN
					INSERT INTO #RecipientIds(RecipientId)
					SELECT TrainerId
					FROM dbo.CourseTrainer
					WHERE CourseId = @courseId;
				END --ELSE IF(@sendAllTrainers = 'True')

				--Provide an id row for use in below loop
				ALTER TABLE #RecipientIds
				ADD TempId INT IDENTITY(1,1);

				-- grab count of recipients for use in below loop
				SELECT @recipientCount = COUNT(TempId) FROM #RecipientIds;

				--Update Salutation
				IF (@startDearSirMadam = 'True')
				BEGIN
					SET @salutation = 'Dear Sir or Madam, ';
				END
				ELSE IF (@startToWhomItMayConcern = 'True')
				BEGIN
					SET @salutation = 'To whom it may concern, ';
				END

				--Loop through the table and either send emails or add
				--the email address to BCCEmailAddresses if @oneEmailWithHiddenAddresses
				--is true, then send email on last loop.
				WHILE @cnt <= @recipientCount
				BEGIN
					SELECT @recipientId = RecipientId 
					FROM #RecipientIds 
					WHERE TempId = @cnt;

					IF(@startDearNamed = 'True' AND @sendAllTrainers = 'True')
					BEGIN
						SELECT @salutation = 'Dear ' + T.DisplayName + ',', 
								@toEmailAddress = e.[Address]
						FROM dbo.Trainer T
						INNER JOIN dbo.TrainerEmail TE	ON T.Id = TE.TrainerId
						INNER JOIN dbo.Email E			ON TE.EmailId = E.Id
						WHERE T.Id = @recipientId;
					END
					ELSE IF(@startDearNamed = 'True' AND @sendAllClients = 'True')
					BEGIN
						SELECT @salutation = 'Dear ' + C.DisplayName + ',', 
								@toEmailAddress = e.[Address]
						FROM dbo.Client C
						INNER JOIN dbo.ClientEmail CE	ON C.Id = CE.ClientId
						INNER JOIN dbo.Email E			ON CE.EmailId = e.Id
						WHERE C.Id = @recipientId;
					END

					-- if not startDearNamed...
					IF(@startDearNamed = 'False' AND @sendAllTrainers = 'True')
					BEGIN
						SELECT @toEmailAddress = e.[Address]
						FROM dbo.Trainer T
						INNER JOIN dbo.TrainerEmail TE	ON T.Id = TE.TrainerId
						INNER JOIN dbo.Email E			ON TE.EmailId = E.Id
						WHERE T.Id = @recipientId;
					END
					ELSE IF(@startDearNamed = 'False' AND @sendAllClients = 'True')
					BEGIN
						SELECT @toEmailAddress = e.[Address]
						FROM dbo.Client C
						INNER JOIN dbo.ClientEmail CE	ON C.Id = CE.ClientId
						INNER JOIN dbo.Email E			ON CE.EmailId = e.Id
						WHERE C.Id = @recipientId;
					END

					SELECT @concatenatedEmailsForValidation = ISNULL(@toEmailAddress, '') + ';' + ISNULL(@CCEmailAddresses, '') + ';' + ISNULL(@BCCEmailAddresses, '');

					--Checks the concatenated email to make sure at least one of them is valid.
					SELECT @validEmailCheck = dbo.udfIsEmailAddressValid(@concatenatedEmailsForValidation);
					
					print '@concatenatedEmailsForValidation';
					print @concatenatedEmailsForValidation;
					print '@validEmailCheck';
					print @validEmailCheck;

					IF(@validEmailCheck = 'True')
					BEGIN
						--Set the full content by concatenating
						-- salutation and existing contenT.
						SELECT @concatenatedContent = @salutation 
													 + @lineBreak 
													 + @content;

						--Allow for Email Attachements
						SET @firstAttachmentId = NULL;
						SET @pendingEmailAttachmentId = NULL;
						SELECT TOP 1 @firstAttachmentId=Id
						FROM CourseGroupEmailRequestAttachment CGERA
						WHERE CGERA.CourseGroupEmailRequestId = @id;

						IF (@firstAttachmentId IS NOT NULL)
						BEGIN
							--First Attachment
							INSERT INTO [dbo].[PendingEmailAttachment] (SameEmailAs_PendingEmailAttachmentId, DocumentId, DateAdded)
							SELECT 
								NULL				AS SameEmailAs_PendingEmailAttachmentId
								, CGERA.DocumentId	AS DocumentId
								, GETDATE()			AS DateAdded
							FROM CourseGroupEmailRequestAttachment CGERA
							WHERE CGERA.Id = @firstAttachmentId
							AND CGERA.CourseGroupEmailRequestId = @id;
							
							SET @pendingEmailAttachmentId = SCOPE_IDENTITY();

							--Allow for Multiple Attachments
							INSERT INTO [dbo].[PendingEmailAttachment] (SameEmailAs_PendingEmailAttachmentId, DocumentId, DateAdded)
							SELECT 
								@pendingEmailAttachmentId	AS SameEmailAs_PendingEmailAttachmentId --Linking Attachments Together
								, CGERA.DocumentId			AS DocumentId
								, GETDATE()					AS DateAdded
							FROM CourseGroupEmailRequestAttachment CGERA
							WHERE CGERA.Id != @firstAttachmentId --Not the First One. All the Others
							AND CGERA.CourseGroupEmailRequestId = @id;
						END

						IF(@separateEmails = 'True')
						BEGIN

							print '@toEmailAddress';
							print @toEmailAddress;
							print '@CCEmailAddresses';
							print @CCEmailAddresses;
							print '@BCCEmailAddresses';
							print @BCCEmailAddresses;

							EXEC dbo.uspSendEmail @requestedByUserId --@requestedByUserId
												, @fromName --@fromName
												, @fromEmailAddress --@fromEmailAddresses
												, @toEmailAddress --@toEmailAddresses
												, @CCEmailAddresses --@ccEmailAddresses
												, @BCCEmailAddresses--@bccEmailAddresses
												, @subject --@emailSubject
												, @concatenatedContent --@emailContent
												, @sendASAP --@asapFlag
												, @sendAfterDateTime --@sendAfterDateTime
												, NULL--@emailServiceId
												, @organisationId --@organisationId
												, 'False' --@blindCopyToEmailAddress
												, @pendingEmailAttachmentId
												;
						END --IF(@separateEmails = 'True')

						ELSE IF(@oneEmailWithHiddenAddresses = 'True')
						BEGIN
							--Add the CCEmailAddress to BCCEmailAddresses
							IF(@BCCEmailAddressesCombined IS NULL)
							BEGIN
								SELECT @BCCEmailAddressesCombined = '';
							END

							IF(@toEmailAddress IS NOT NULL)
							BEGIN
								SELECT @BCCEmailAddressesCombined = @BCCEmailAddressesCombined + @toEmailAddress + ';';
							END

							IF(@CCEmailAddresses IS NOT NULL)
							BEGIN
								SELECT @BCCEmailAddressesCombined = @BCCEmailAddressesCombined + @CCEmailAddresses + ';';
							END

							IF(@BCCEmailAddresses IS NOT NULL)
							BEGIN
								SELECT @BCCEmailAddressesCombined = @BCCEmailAddressesCombined + @BCCEmailAddresses + ';';
							END

							--SELECT @BCCEmailAddressesCombined = ISNULL(@BCCEmailAddressesCombined, '') + ISNULL(@toEmailAddress, '') + ';' + ISNULL(@CCEmailAddresses, '') + ';' + ISNULL(@BCCEmailAddresses, '') + ';';
							print '@BCCEmailAddressesCombined';
							print @BCCEmailAddressesCombined;

							--If it's the last loop, send the email.
							IF(@cnt = @recipientCount)
							BEGIN
								print 'sending email';
								print '@BCCEmailAddressesCombined';
								print @BCCEmailAddressesCombined;
								print '@toEmailAddress';
								print @toEmailAddress;
								print '@organisationId';
								print @organisationId;

								EXEC dbo.uspSendEmail @requestedByUserId --@requestedByUserId
													, @fromName --@fromName
													, @fromEmailAddress --@fromEmailAddresses
													, '' --@toEmailAddresses
													, NULL --@ccEmailAddresses
													, @BCCEmailAddressesCombined--@bccEmailAddresses
													, @subject --@emailSubject
													, @concatenatedContent --@emailContent
													, @sendASAP --@asapFlag
													, @sendAfterDateTime --@sendAfterDateTime
													, NULL--@emailServiceId
													, @organisationId --@organisationId
													, 'True' --@blindCopyToEmailAddress
													, @pendingEmailAttachmentId
													;
							END --IF(@cnt = @recipientCount)

						END -- IF(@oneEmailWithHiddenAddresses = 'True')
			
						--Clear out the  variables used in loop.
						--SET @salutation = NULL;
						SET @concatenatedEmailsForValidation = NULL;
						SET @validEmailCheck = NULL;
						-- SET @BCCEmailAddressesCombined = NULL;
						--SET @concatenatedContent = NULL;

					END--EmailVerification
					SET @cnt = @cnt +1;
				END--while



				IF(@validEmailCheck = 'False')
											
				BEGIN
					UPDATE dbo.CourseGroupEmailRequest
					SET RequestRejected = 'True', RejectionReason = 'All destination email addresses were not in the correct format'
					WHERE Id = @id;
				END
				ELSE
				BEGIN
					UPDATE dbo.CourseGroupEmailRequest
					SET EmailsValidatedAndCreated = 'True', DateEmailsValidatedAndCreated = GETDATE()
					WHERE Id = @id;
				END

				DROP TABLE #RecipientIds;

			END --IF (@courseId IS NOT NULL AND I.ReadyToSend = 'True')
		END --END PROCESS

	END

GO
ALTER TRIGGER TRG_ScheduledEmail_Insert ON dbo.ScheduledEmail AFTER INSERT
	AS

	BEGIN
		DECLARE @id INT
				, @content VARCHAR(4000)
				, @startCheck BIT
				, @carriageReturnLineFeed VARCHAR(40) = CHAR(13) + CHAR(10)
				, @paragraph CHAR(7) = '</p><p>';

		SELECT @id = id
				, @content = Content
		FROM Inserted i;

		SELECT @startCheck = CASE WHEN LEFT(@content, 3) = '<p>' THEN 1 ELSE 0 END;

		IF(@startCheck = 'False')
		BEGIN
			SET @content = '<p>' + @content + '</p>';
			SET @content = REPLACE(@content, @carriageReturnLineFeed, @carriageReturnLineFeed + @paragraph);

			UPDATE dbo.ScheduledEmail
			SET Content = @content
			WHERE Id = @id;
		END --IF(@startCheck = 'False')

	END
		
GO
ALTER TRIGGER TRG_ClientMarkedForDelete_UPDATE ON ClientMarkedForDelete AFTER UPDATE
AS

BEGIN
		/*Insert a row in to ClientMarkedForDeleteCancelled when CancelledByUserId is updated from empty to having a UserId*/
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
											d.CancelledByUserId IS NULL)
				END
			END

		/*Delete row from ClientMarkedForDelete*/

		DELETE FROM dbo.ClientMarkedForDelete
		WHERE ClientMarkedForDelete.Id = (Select id from inserted)

END


	/*******************************************************************************************************************/
	
GO
ALTER TRIGGER TRG_CancelledCourseToDeleteCourseQuickSearch_INSERT ON CancelledCourse FOR INSERT
	AS

		
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN   
			DELETE cqs
			FROM INSERTED I
			INNER JOIN CourseQuickSearch CQS ON CQS.CourseId = I.CourseId;

		END --END PROCESS

	END

	/*******************************************************************************************************************/
	
GO
ALTER TRIGGER TRG_CancelledCourseToInsertCourseQuickSearch_DELETE ON CancelledCourse FOR INSERT
	AS

		
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN   
			DECLARE @CourseId INT;

			SELECT TOP 1 @CourseId = D.CourseId
			FROM DELETED D;

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;
			
		END --END PROCESS

	END

	
GO
ALTER TRIGGER TRG_User_INSERTUPDATE ON [User] FOR INSERT, UPDATE
	AS	
		DECLARE @InsertOnly BIT = 'False';
		SET @InsertOnly=(CASE WHEN EXISTS (SELECT * FROM DELETED) THEN 'False' ELSE 'True' END);

		DECLARE @UpdatedByUserId INT;

		INSERT INTO [dbo].[UserChangeLog] (UserId, ColumnName, PreviousValue, NewValue, DateChanged, ChangedByUserId)
		SELECT I.Id										AS UserId
			, 'LoginId'									AS ColumnName
			, CAST(ISNULL(D.LoginId,'') AS VARCHAR)		AS PreviousValue
			, CAST(ISNULL(I.LoginId,'') AS VARCHAR)		AS NewValue
			, GETDATE()									AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)								AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.LoginId <> D.LoginId)
		UNION SELECT I.Id									AS UserId
			, 'Password'									AS ColumnName
			, CAST(ISNULL(D.[Password],'') AS VARCHAR)		AS PreviousValue
			, CAST(ISNULL(I.[Password],'') AS VARCHAR)		AS NewValue
			, GETDATE()										AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)									AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[Password] <> D.[Password])
		UNION SELECT I.Id									AS UserId
			, 'Name'										AS ColumnName
			, CAST(ISNULL(D.[Name],'') AS VARCHAR)			AS PreviousValue
			, CAST(ISNULL(I.[Name],'') AS VARCHAR)			AS NewValue
			, GETDATE()										AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)									AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[Name] <> D.[Name])
		UNION SELECT I.Id									AS UserId
			, 'Email'										AS ColumnName
			, CAST(ISNULL(D.[Email],'') AS VARCHAR)			AS PreviousValue
			, CAST(ISNULL(I.[Email],'') AS VARCHAR)			AS NewValue
			, GETDATE()										AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)									AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[Email] <> D.[Email])
		UNION SELECT I.Id									AS UserId
			, 'Phone'										AS ColumnName
			, CAST(ISNULL(D.[Phone],'') AS VARCHAR)			AS PreviousValue
			, CAST(ISNULL(I.[Phone],'') AS VARCHAR)			AS NewValue
			, GETDATE()										AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId 
					END)									AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[Phone] <> D.[Phone])
		UNION SELECT I.Id										AS UserId
			, 'SecretQuestion'									AS ColumnName
			, CAST(ISNULL(D.[SecretQuestion],'') AS VARCHAR)	AS PreviousValue
			, CAST(ISNULL(I.[SecretQuestion],'') AS VARCHAR)	AS NewValue
			, GETDATE()											AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId	
					END)										AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[SecretQuestion] <> D.[SecretQuestion])
		UNION SELECT I.Id										AS UserId
			, 'SecretAnswer'									AS ColumnName
			, CAST(ISNULL(D.[SecretAnswer],'') AS VARCHAR)		AS PreviousValue
			, CAST(ISNULL(I.[SecretAnswer],'') AS VARCHAR)		AS NewValue
			, GETDATE()											AS DateChanged
			, (CASE WHEN @InsertOnly='True' 
					THEN I.CreatedByUserId 
					ELSE I.UpdatedByUserId	
					END)										AS ChangedByUserId
		FROM INSERTED I
		LEFT JOIN DELETED D ON D.Id = I.Id
		WHERE (I.[SecretAnswer] <> D.[SecretAnswer])
		;

	
GO
ALTER TRIGGER TRG_SystemStateSummary_UPDATE ON SystemStateSummary FOR UPDATE
	AS

		INSERT INTO SystemStateSummaryHistory
					(
					SystemStateSummaryId
					, OrganisationId
					, Code
					, [Message]
					, SystemStateId
					, DateUpdated
					, AddedByUserId
					)
		SELECT		
					i.id
					,i.OrganisationId
					, i.Code
					, i.[Message]
					, i.SystemStateId
					, i.DateUpdated
					, i.AddedByUserId

		FROM Inserted i 
		INNER JOIN Deleted d ON i.id = d.id
		WHERE (i.OrganisationId <> d.OrganisationId 
				OR i.Code <> d.Code
				OR i.[Message] <> d.[Message]
				OR i.SystemStateId <> d.SystemStateId
				OR i.AddedByUserId <> d.AddedByUserId
				OR i.DateUpdated <> d.DateUpdated
				)
		;
	/*******************************************************************************************************************/
	
GO
ALTER TRIGGER TRG_Course_CourseQuickSearchINSERTUPDATEDELETE ON Course FOR INSERT, UPDATE, DELETE
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			DECLARE @CourseId int;
			DECLARE @InsertId int;
			DECLARE @DeleteId int;
	
			SELECT @InsertId = i.Id FROM inserted i;
			SELECT @DeleteId = d.Id FROM deleted d;
	
			SELECT @CourseId = COALESCE(@InsertId, @DeleteId);	

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;	
		END --END PROCESS

	END
		--
GO
--ALTER TRIGGER TRG_DataView_INSERTUPDATE ON DataView FOR INSERT, UPDATE
		
--GO
ALTER TRIGGER TRG_DataView_INSERTUPDATE ON DataView AFTER INSERT, UPDATE
AS
	DECLARE @DataViewId int;
	DECLARE @DataViewName varchar(100);
	
	/* This will just capture single rows. 
	Won't work if multirows are inserted. */
	
	SELECT @DataViewId = i.Id, @DataViewName = i.Name FROM inserted i;
	
	EXEC dbo.usp_UpdateDataViewColumn @DataViewId, @DataViewName;
		
GO
ALTER TRIGGER TRG_PaymentCard_InsertUpdateDelete ON PaymentCard AFTER INSERT, UPDATE, DELETE
AS

BEGIN

/* When a new record is inserted on to the PaymentCard table */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
					, ChangeType
					, LogType 
					, DateChanged 
					, PaymentId 
					, PaymentCardSupplierId 
					, PaymentProviderId 
					, PaymentProviderTransactionReference
					, TransactionDate 
					, DateCreated 
					, CreatedByUserId
					, LogDate
					, PaymentCardTypeId)

		    SELECT    i.id
		 			, ChangeType = 'Insert'
		   			, LogType = 'New'
					, DateChanged = GETDATE()
					, i.PaymentId 
					, i.PaymentCardSupplierId 
					, i.PaymentProviderId 
					, i.PaymentProviderTransactionReference
					, i.TransactionDate 
					, i.DateCreated 
					, i.CreatedByUserId
					, LogDate = GETDATE()
					, i.PaymentCardTypeId

			FROM	inserted i INNER JOIN
					PaymentCard PC ON i.id = PC.id 
					AND NOT EXISTS(SELECT id from deleted d where d.id = PC.id)

/* When a record is deleted on the PaymentCard table */ 


	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
					, ChangeType
					, LogType 
					, DateChanged 
					, PaymentId 
					, PaymentCardSupplierId 
					, PaymentProviderId 
					, PaymentProviderTransactionReference
					, TransactionDate 
					, DateCreated 
					, CreatedByUserId
					, LogDate
					, PaymentCardTypeId)

			SELECT    d.id
		 			, ChangeType = 'Delete'
		   			, LogType = 'Delete'
					, DateChanged = GETDATE()
					, d.PaymentId 
					, d.PaymentCardSupplierId 
					, d.PaymentProviderId 
					, d.PaymentProviderTransactionReference
					, d.TransactionDate 
					, d.DateCreated 
					, d.CreatedByUserId
					, LogDate = GETDATE()
					, d.PaymentCardTypeId

			FROM	deleted d

/* When a record is updated on to the PaymentCard table - inserts previous values */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
					, ChangeType
					, LogType 
					, DateChanged 
					, PaymentId 
					, PaymentCardSupplierId 
					, PaymentProviderId 
					, PaymentProviderTransactionReference
					, TransactionDate 
					, DateCreated 
					, CreatedByUserId
					, LogDate
					, PaymentCardTypeId)

			SELECT    d.id
		 			, ChangeType = 'Update'
		   			, LogType = 'Previous Values'
					, DateChanged = GETDATE()
					, d.PaymentId 
					, d.PaymentCardSupplierId 
					, d.PaymentProviderId 
					, d.PaymentProviderTransactionReference
					, d.TransactionDate 
					, d.DateCreated 
					, d.CreatedByUserId
					, LogDate = GETDATE()
					, d.PaymentCardTypeId

			FROM	deleted d INNER JOIN
					inserted i ON d.id = i.id INNER JOIN
					PaymentCard PC ON PC.id = d.id

/* When a record is updated on to the PaymentCard table - inserts new values */ 

	INSERT INTO		 PaymentCardLog
					 (PaymentCardId
					, ChangeType
					, LogType 
					, DateChanged 
					, PaymentId 
					, PaymentCardSupplierId 
					, PaymentProviderId 
					, PaymentProviderTransactionReference
					, TransactionDate 
					, DateCreated 
					, CreatedByUserId
					, LogDate
					, PaymentCardTypeId)

			SELECT    i.id
		 			, ChangeType = 'Update'
		   			, LogType = 'New Values'
					, DateChanged = GETDATE()
					, i.PaymentId 
					, i.PaymentCardSupplierId 
					, i.PaymentProviderId 
					, i.PaymentProviderTransactionReference
					, i.TransactionDate 
					, i.DateCreated 
					, i.CreatedByUserId
					, LogDate = GETDATE()
					, i.PaymentCardTypeId

			FROM	deleted d INNER JOIN
					inserted i ON d.id = i.id INNER JOIN
					PaymentCard PC ON PC.id = d.id

END

