/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Id]
      ,[FromName]
      ,[FromEmail]
      ,[Content]
      ,[DateCreated]
      ,[Disabled]
      ,[ASAP]
      ,[SendAfter]
      ,[ScheduledEmailStateId]
      ,[DateScheduledEmailStateUpdated]
      ,[SendAtempts]
      ,[Subject]
      ,[EmailProcessedEmailServiceId]
      ,[DateUpdated]
  FROM [dbo].[ScheduledEmail]
  ORDER BY [DateCreated] DESC

  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].[ScheduledEmailAttachment] DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;
  
  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].ScheduledEmailNote DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;
  
  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].ScheduledEmailTo DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;
  
  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].ScheduledEmailTo DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;
  
  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].OrganisationScheduledEmail DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;
  
  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].ClientScheduledEmail DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;

  DELETE DEL
  FROM ScheduledEmail SE
  INNER JOIN [dbo].CourseClientEmailReminder DEL ON DEL.ScheduledEmailId = SE.Id
  WHERE SE.[Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR SE.[Subject] IS NULL;

  
  DELETE ScheduledEmail 
  WHERE [Subject] IN ('Course Overbooked'
						, 'Course Reminder'
						, 'Unpaid reserved course has been removed (unbooked)'
						, 'Atlas - Error sending email'
						)
	OR [Subject] IS NULL;


