
SELECT TOP (1000) [Id]
      ,[Title]
      ,[Content]
      ,[CreatedByUserId]
      ,[DateCreated]
      ,[MessageCategoryId]
      ,[Disabled]
      ,[AllUsers]
  FROM [dbo].[Message]
  ORDER BY [DateCreated] DESC


	DELETE MA
	FROM [dbo].[Message] M
	INNER JOIN  [dbo].[MessageAcknowledgement] MA ON MA.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE MR
	FROM [dbo].[Message] M
	INNER JOIN [dbo].[MessageRecipient]  MR ON MR.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE MRE
	FROM [dbo].[Message] M
	INNER JOIN [dbo].MessageRecipientException  MRE ON MRE.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE MRO
	FROM [dbo].[Message] M
	INNER JOIN [dbo].MessageRecipientOrganisation  MRO ON MRO.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE MROE
	FROM [dbo].[Message] M
	INNER JOIN [dbo].MessageRecipientOrganisationException  MROE ON MROE.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE MS
	FROM [dbo].[Message] M
	INNER JOIN [dbo].MessageSchedule  MS ON MS.MessageId = M.Id
	WHERE M.Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);
	
	DELETE [dbo].[Message]
	WHERE Title IN ('Course Overbooked'
					, '*Multiple Send Email Attempts on Email*'
					, 'Unpaid reserved course has been removed (unbooked)'
					, 'Documents marked for deletion.'
					, 'Client Booked on Course with Special Requirement'
					, 'TotalSend is disabled'
					);


