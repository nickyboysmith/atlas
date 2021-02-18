

		

		--vwPaymentNotes_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwPaymentNotes_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwPaymentNotes_SubView;
		END		
		GO
		/*
			Create vwPaymentNotes_SubView
			NB. This view is used within view "vwPaymentDetail" 
		*/
		CREATE VIEW vwPaymentNotes_SubView
		AS
			SELECT DISTINCT P1.PaymentId
				, STUFF( 
							(SELECT ','
								+ 'NOTE ADDED: ' + CONVERT(NVARCHAR(MAX), N.DateCreated, 0) 
								+ ' BY: ' + (CASE WHEN SAU.Id IS NOT NULL 
												THEN 'Atlas Systems Administration' 
												ELSE U.[Name] END)
								+ CHAR(13) + CHAR(10)
								+ N.Note
								+ CHAR(13) + CHAR(10)
								+ '------------------------------------'
								+ CHAR(13) + CHAR(10)
							FROM [dbo].[PaymentNote] PN
							INNER JOIN [dbo].[Note] N ON N.Id = PN.NoteId
							INNER JOIN [dbo].[User] U ON U.Id = N.CreatedByUserId
							LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = N.CreatedByUserId
							WHERE P1.PaymentId = PN.PaymentId
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)')
						, 1, 1, '') AS Notes
			FROM PaymentNote P1
			GROUP by PaymentId
		GO


		/*********************************************************************************************************************/
		