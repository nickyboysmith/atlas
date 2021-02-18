/*
	SCRIPT: Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 2
	Author: Daniel Hough
	Created: 13/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_31.02_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part2.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Inserted and Updated Row Check And Add uspLogTriggerRunning - Part 2';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_Course_CourseQuickSearchINSERTUPDATEDELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_Course_CourseQuickSearchINSERTUPDATEDELETE;
		END
	GO

	CREATE TRIGGER TRG_Course_CourseQuickSearchINSERTUPDATEDELETE ON dbo.Course FOR INSERT, UPDATE, DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_Course_CourseQuickSearchINSERTUPDATEDELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @CourseId INT
					, @InsertId INT
					, @DeleteId INT;
	
			SELECT @InsertId = i.Id FROM inserted i;
			SELECT @DeleteId = d.Id FROM deleted d;
	
			SELECT @CourseId = COALESCE(@InsertId, @DeleteId);	

			EXEC dbo.usp_RefreshSingleCourseQuickSearchData @CourseId;	

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseDateDORSNotified_Update', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseDateDORSNotified_Update;
		END
	GO

	CREATE TRIGGER TRG_CourseDateDORSNotified_Update ON dbo.Course AFTER UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_CourseDateDORSNotified_Update', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseTableCalculateLastBookingDate_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseTableCalculateLastBookingDate_INSERT;
		END
	GO

	CREATE TRIGGER TRG_CourseTableCalculateLastBookingDate_INSERT ON dbo.Course FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_CourseTableCalculateLastBookingDate_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @Id as INT;
			
			SELECT @Id = i.Id FROM inserted i;
			
			EXEC [dbo].[uspCalculateLastBookingDate] @Id;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseToInsertCourseDocument_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseToInsertCourseDocument_INSERT;
		END
	GO

	CREATE TRIGGER TRG_CourseToInsertCourseDocument_INSERT ON dbo.Course FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_CourseToInsertCourseDocument_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			INSERT INTO [dbo].[CourseDocument]
				([CourseId]
			   ,[DocumentId])
			SELECT
				i.Id
			   ,acd.DocumentId 
			FROM
			   inserted i
			   INNER JOIN AllCourseDocument acd on i.OrganisationId = acd.OrganisationId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT;
		END
	GO

	CREATE TRIGGER TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT ON dbo.Course FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_CourseToInsertCourseDocumentWithAllCourseTypeDocumentCheck_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
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
			   INNER JOIN AllCourseTypeDocument actd on i.CourseTypeId = actd.CourseTypeId;

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_CourseVenueEmail_InsertUpdate', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseVenueEmail_InsertUpdate;
		END
	GO

	CREATE TRIGGER TRG_CourseVenueEmail_InsertUpdate ON dbo.Course AFTER INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'Course', 'TRG_CourseVenueEmail_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_CourseCloneRequest_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseCloneRequest_Insert;
		END
	GO


	CREATE TRIGGER TRG_CourseCloneRequest_Insert ON dbo.CourseCloneRequest AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseCloneRequest', 'TRG_CourseCloneRequest_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#PreferredDates') IS NOT NULL
			BEGIN
				DROP TABLE #PreferredDates
			END

			IF OBJECT_ID('tempdb..#Courses') IS NOT NULL
			BEGIN
				DROP TABLE #Courses
			END

			IF OBJECT_ID('tempdb..#CourseDateTime') IS NOT NULL
			BEGIN
				DROP TABLE #CourseDateTime
			END
			
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

			IF OBJECT_ID('tempdb..#PreferredDates') IS NOT NULL
			BEGIN
				DROP TABLE #PreferredDates
			END

			IF OBJECT_ID('tempdb..#Courses') IS NOT NULL
			BEGIN
				DROP TABLE #Courses
			END

			IF OBJECT_ID('tempdb..#CourseDateTime') IS NOT NULL
			BEGIN
				DROP TABLE #CourseDateTime
			END

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseSchedule_DELETE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseSchedule_DELETE;
		END
	GO

	CREATE TRIGGER TRG_CourseSchedule_DELETE ON dbo.CourseSchedule FOR DELETE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseSchedule', 'TRG_CourseSchedule_DELETE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @CourseId INT
					, @DateCreated DATETIME
					, @CreatedByUserId INT
					, @Item VARCHAR(40)
					, @NewValue VARCHAR(100)
					, @OldValue VARCHAR(100);

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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseSchedule_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseSchedule_INSERT;
		END
	GO

	CREATE TRIGGER TRG_CourseSchedule_INSERT ON dbo.CourseSchedule FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseSchedule', 'TRG_CourseSchedule_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
			DECLARE @CourseId INT
					, @DateCreated DATETIME
					, @CreatedByUserId INT
					, @Item VARCHAR(40)
					, @NewValue VARCHAR(100)
					, @OldValue VARCHAR(100);

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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/


	IF OBJECT_ID('dbo.TRG_CourseSchedule_UPDATE', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseSchedule_UPDATE;
		END
	GO

	CREATE TRIGGER TRG_CourseSchedule_UPDATE ON dbo.CourseSchedule FOR UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseSchedule', 'TRG_CourseSchedule_UPDATE', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------
			
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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_CourseStencil_InsertUpdate', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseStencil_InsertUpdate;
		END
	GO

	CREATE TRIGGER TRG_CourseStencil_InsertUpdate ON dbo.CourseStencil AFTER INSERT, UPDATE
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseStencil', 'TRG_CourseStencil_InsertUpdate', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

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

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_CourseTypeCategory_Insert', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseTypeCategory_Insert;
		END
	GO

	CREATE TRIGGER TRG_CourseTypeCategory_Insert ON dbo.CourseTypeCategory AFTER INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseTypeCategory', 'TRG_CourseTypeCategory_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

			DECLARE @courseTypeId INT
				  , @courseTypeCategoryId INT
				  , @organisationId INT;

			SELECT @courseTypeId = i.CourseTypeId
				 , @organisationId = ct.OrganisationId
			FROM Inserted i
			LEFT JOIN dbo.CourseType ct ON i.CourseTypeId = ct.Id;

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
											 , NULL);

		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/



	IF OBJECT_ID('dbo.TRG_DashboardMeterExposure_INSERT', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_DashboardMeterExposure_INSERT;
		END
	GO

	CREATE TRIGGER TRG_DashboardMeterExposure_INSERT ON dbo.DashboardMeterExposure FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'DashboardMeterExposure', 'TRG_DashboardMeterExposure_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------------------------------------------------

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
		
		END --END PROCESS
	GO

	/**********************************************************************************************************************************************/




/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_31.02_AddInsertedUpdatedRowCheckAndAdduspLogTriggerRunning_Part2.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO