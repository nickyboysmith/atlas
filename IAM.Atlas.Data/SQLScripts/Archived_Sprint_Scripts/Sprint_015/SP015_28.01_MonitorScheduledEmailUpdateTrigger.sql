
/*
	SCRIPT: Add Update Trigger to the ScheduledEmail table
	Author: Nick Smith
	Created: 05/02/2016
	
	Description : Split into 2 parts
	
					Part i - First part handle change to the sendattempts column.
					If there has been a change to this field and sendattempts has reached the max allowed,
					then create a failure message and assign to all interested support users.
					Also create a failure email and schedule it to all interested support users.
					
					Part ii - Second Part handle change of email state.
					If state has changed to 'sent' create an entry into EmailServiceEmailsSent if not already exists.
					Need this check as state could change from 'sent' to something else and then back to 'sent' again, 
					hence triggering another insert into EmailServiceEmailsSent.
					Update Counts. For a ScheduledEmailId, count the number of entries in ScheduledEmailTo.
					This figure is used to increment/decrement the counts in EmailServiceEmailCount.
					
*/
				
DECLARE @ScriptName VARCHAR(100) = 'SP015_28.01_MonitorScheduledEmailUpdateTrigger.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create an Update Trigger On ScheduledEmail Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_ScheduledEmail_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[ScheduledEmail_UPDATE];
		END
GO
		CREATE TRIGGER ScheduledEmail_UPDATE ON ScheduledEmail AFTER UPDATE
AS

	BEGIN
	
	DECLARE @EmailServiceId int;
	DECLARE @SentDate datetime;
	DECLARE @Year smallint;
	DECLARE @Month smallint;
	DECLARE @Week smallint;
	DECLARE @Day smallint;
	DECLARE @Inc smallint;
	DECLARE @ScheduledEmailId int;
	DECLARE @SendAttempts smallint;
	DECLARE @OldStateId smallint;
	DECLARE @OldState varchar(100);
	DECLARE @NewStateId smallint;
	DECLARE @NewState varchar(100);
	
	DECLARE @InsertedMessageId int;
	DECLARE @InsertedScheduledEmailId int;
	
	DECLARE @InsertedMessageTable table (Id int);
	DECLARE @InsertedScheduledTable table (EmailId int);
	
	/* Failure Message Setup */
	DECLARE @MessageTitle varchar(100) = 'Multiple Send Email Attempts Failures';
	DECLARE @MessageContent varchar(100);
	DECLARE @MessageCategory int = 4; /* 4 = ERROR */
	DECLARE @MessageCreatedByUserId int = '1' /* 99 = System Support User ?? */
	DECLARE @MessageDisabled bit = 'false';
	DECLARE @MessageAllUsers bit = 'false';
	
	/* Failure Email Setup */
	DECLARE @EmailSubject varchar(100) = 'Multiple Send Email Attempts Failures';
	DECLARE @EmailFromName varchar(100) = 'System Support';
	DECLARE @EmailFromEmail varchar(100) = 'SystemSupport@atlas.co.uk';
	DECLARE @EmailContent varchar(100);
	DECLARE @EmailDisabled bit = 'false';
	DECLARE @EmailASAP bit = 'false';
	DECLARE @EmailSendAfter datetime = null;
	DECLARE @EmailSendAttempts int = 0;

	DECLARE @SendAttemptFailureTryCount int = 3;

	SET @SentDate = GetDate();
	SET @Week = DATEPART(WEEK, @SentDate);
	SET @Month = DATEPART(MONTH, @SentDate);
	SET @Year = DATEPART(YEAR, @SentDate);
	SET @Day = DATEPART(WEEKDAY, @SentDate);

	SET @Inc = 0;

	/* Drop UsersMultipleSendFailures */
	IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects
					WHERE ID = OBJECT_ID(N'tempdb..##SystemSupportUsers') AND [Type] ='U')
					BEGIN
						DROP TABLE #SystemSupportUsers
					END
					
	/* Drop ScheduledEmailStatusUpdates */
	IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects
					WHERE ID = OBJECT_ID(N'tempdb..##ScheduledEmailStateUpdates') AND [Type] ='U')
					BEGIN
						DROP TABLE #ScheduledEmailStateUpdates
					END
	   
	/* Only looking for a column change in either or both  */
	IF (UPDATE (SendAtempts) OR UPDATE (ScheduledEmailStateId))
		BEGIN
				/* Select All ScheduledEmails of interest. 
				   Where there is a status change and/or send attempts has changed to 3 or more
				 */
				SELECT i.Id as ScheduledEmailId
						, i.EmailProcessedEmailServiceId AS EmailServiceId
						, ses.id AS OldStateId
						, ses.Name AS OldState
						, ses1.id AS NewStateId 
						, ses1.Name AS NewState
						, i.SendAtempts AS SendAttempts 
				INTO #ScheduledEmailStateUpdates
				FROM Inserted i
				INNER JOIN Deleted d ON i.Id = d.Id
				INNER JOIN ScheduledEmailState ses ON ses.Id = d.ScheduledEmailStateId 
				INNER JOIN ScheduledEmailState ses1 ON ses1.Id = i.ScheduledEmailStateId
				WHERE (i.ScheduledEmailStateId <> d.ScheduledEmailStateId)
				OR ((i.SendAtempts <> d.SendAtempts) AND (i.SendAtempts >= @SendAttemptFailureTryCount))

				/* Select all interested System Support Users and details */  
				SELECT  u.Id AS UserId, u.Name, u.Email into #SystemSupportUsers 
				FROM [User] u 
				INNER JOIN SystemSupportUser ssu ON u.Id = ssu.UserId
				WHERE u.[Disabled] = 'false'

				/* Okay, do we have anything */
				WHILE EXISTS (SELECT * FROM #ScheduledEmailStateUpdates) 
				BEGIN
					
					/* take the first */					
					SELECT TOP 1 @ScheduledEmailId = ScheduledEmailId
							, @EmailServiceId = EmailServiceId
							, @OldStateId = OldStateId
							, @OldState = OldState 
							, @NewStateId = NewStateId
							, @NewState= NewState 
							, @SendAttempts = SendAttempts
					FROM #ScheduledEmailStateUpdates

					/* Part i - Have we reached the maximum SendAttempt Count */
					IF (@SendAttempts >= @SendAttemptFailureTryCount) AND (@NewState != 'Sent')
					BEGIN

						Set @MessageContent = 'Multiple Send Email Attempts Failures on Email Id : ' + CAST(@ScheduledEmailId as varchar(16)); 

						/* Create a Single Failed Attempt Message */
						INSERT INTO [Message]
							(Title
							,Content
							,CreatedByUserId
							,DateCreated
							,MessageCategoryId
							,[Disabled]
							,AllUsers)
							--OUTPUT [Message].Id INTO @InsertedMessageTable (OUTPUT not work in Triggers ?)
						SELECT 
							@MessageTitle
							,@MessageContent
							,@MessageCreatedByUserId
							,GetDate()
							,@MessageCategory
							,@MessageDisabled
							,@MessageAllUsers
							
						--SET @InsertedMessageId = (select Id from @InsertedMessageTable)
						SET @InsertedMessageId = SCOPE_IDENTITY();

						/* Create Multiple User Recipients for the Failed Attempt Message */
						INSERT INTO MessageRecipient 
							(MessageId
							, UserId)
						SELECT 
							@InsertedMessageid
							,ssu.UserId
						FROM 
							#SystemSupportUsers ssu 
						
						SET @EmailContent = 'Multiple Send Email Attempts Failures on Email Id : ' + CAST(@ScheduledEmailId as varchar(16)); 
						
						/* Create a Single Failed Attempt Email */
						INSERT INTO [ScheduledEmail]
							(FromName
							,FromEmail
							,Content
							,DateCreated
							,[Disabled]
							,ASAP
							,SendAfter
							,ScheduledEmailStateId
							,DateScheduledEmailStateUpdated
							,SendAtempts
							,[Subject]
							,EmailProcessedEmailServiceId)
							--OUTPUT [ScheduledEmail].Id INTO @InsertedScheduledTable (OUTPUT not work in Triggers ?)
						SELECT
							@EmailFromName
							,@EmailFromEmail
							,@EmailContent
							,GetDate()
							,@EmailDisabled
							,@EmailASAP
							,@EmailSendAfter
							,@NewStateId
							,GetDate()
							,@EmailSendAttempts
							,@EmailSubject
							,@EmailServiceId
							
						--SET @InsertedScheduledEmailId = (select EmailId from @InsertedScheduledTable)
						SET @InsertedScheduledEmailId = SCOPE_IDENTITY();
						
						/* Create Multiple User Recipients of Failed Attempt Email */
						INSERT INTO [ScheduledEmailTo]
							(ScheduledEmailId
							,[Name]
							,Email
							,CC
							,BCC)
						SELECT
							@InsertedScheduledEmailId
							,ssu.[Name]
							,ssu.Email
							,null 
							,null 
						FROM 
							#SystemSupportUsers ssu

					END
					/* End of Part i*/
					
					/* Part ii - Do we have a status change */
					IF (@OldState <> @NewState)
					BEGIN
						/* What type of status 
						   Change from something to 'sent' */
						IF (@NewState = 'Sent' AND @OldState != 'Sent' ) 
						BEGIN
							/* Potential BUG here, if status has been sent and then changed back from sent, 
							then back to sent .... */
							INSERT INTO EmailServiceEmailsSent
							   (ScheduledEmailId
							   ,DateSent
							   ,EmailServiceId)
							SELECT 
								@ScheduledEmailId
								,GETDATE()
								,@EmailServiceId
							WHERE NOT EXISTS (SELECT ScheduledEmailId FROM EmailServiceEmailsSent
												WHERE ScheduledEmailId = @ScheduledEmailId
												AND EmailServiceId = @EmailServiceId)
						
						END
						
						/* Get the Counts to increment or decrement in EmailServiceEmailCount */
						SELECT @Inc = Count(*) FROM ScheduledEmailTo st
						INNER JOIN ScheduledEmail se ON st.ScheduledEmailId = se.Id
						WHERE se.Id = @ScheduledEmailId
						
						/* If the status has been changed from 'sent' to something else, then this 
						   count becomes negative */		  
						IF (@OldState = 'Sent' AND @NewState != 'Sent') SET @Inc = @Inc * -1 
						
						/* Update the counts. If either was Sent and now is not ...
					       If the update fails then insert a new count row */	
					    IF (@NewState = 'Sent' AND @OldState != 'Sent' ) 
							OR (@OldState = 'Sent' AND @NewState != 'Sent')
					    BEGIN
					    
							UPDATE EmailServiceEmailCount
							SET 
								NumberSent = NumberSent + @Inc,
								NumberSentMonday = (CASE WHEN @DAY = 2 THEN NumberSentMonday + @Inc ELSE NumberSentMonday END),
								NumberSentTuesday = (CASE WHEN @DAY = 3 THEN NumberSentTuesday + @Inc ELSE NumberSentTuesday END),
								NumberSentWednesday = (CASE WHEN @DAY = 4 THEN NumberSentWednesday + @Inc ELSE NumberSentWednesday END),
								NumberSentThursday = (CASE WHEN @DAY = 5 THEN NumberSentThursday + @Inc ELSE NumberSentThursday END),
								NumberSentFriday = (CASE WHEN @DAY = 6 THEN NumberSentFriday + @Inc ELSE NumberSentFriday END),
								NumberSentSaturday = (CASE WHEN @DAY = 7 THEN NumberSentSaturday + @Inc ELSE NumberSentSaturday END),
								NumberSentSunday = (CASE WHEN @DAY = 1 THEN NumberSentSunday + @Inc ELSE NumberSentSunday END)
							WHERE	EmailServiceId = @EmailServiceId
									AND YearSent = @Year
									AND MonthSent = @Month
									AND WeekNumberSent = @Week
				      
							IF (@@ROWCOUNT = 0)
							BEGIN
								INSERT INTO EmailServiceEmailCount
								   (YearSent
								   ,MonthSent
								   ,WeekNumberSent
								   ,NumberSent
								   ,NumberSentMonday
								   ,NumberSentTuesday
								   ,NumberSentWednesday
								   ,NumberSentThursday
								   ,NumberSentFriday
								   ,NumberSentSaturday
								   ,NumberSentSunday
								   ,EmailServiceId)
							   SELECT 
								   @Year
								   ,@Month
								   ,@Week
								   ,@Inc
								   ,CASE WHEN @DAY = 2 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 3 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 4 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 5 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 6 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 7 THEN @Inc ELSE 0 END
								   ,CASE WHEN @DAY = 1 THEN @Inc ELSE 0 END
								   ,@EmailServiceId
							END
										
						END
					END
					/* End of Part ii */
					
					/* Remove ScheduleEmailId from the process list.
					   Select Top 1 from the beginning of WHILE loop is now the next to process */			
					DELETE #ScheduledEmailStateUpdates WHERE ScheduledEmailId = @ScheduledEmailId
					SET @Inc = 0;
				END	
			END
		END	

GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP015_28.01_MonitorScheduledEmailUpdateTrigger.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO
		
		
