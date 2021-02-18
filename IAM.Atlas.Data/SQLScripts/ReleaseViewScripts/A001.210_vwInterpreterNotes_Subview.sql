

		

		--vwInterpreterNotes_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwInterpreterNotes_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwInterpreterNotes_SubView;
		END		
		GO
		/*
			Create vwInterpreterNotes_SubView
			NB. This view is used within view "vwPaymentDetail" 
		*/
		CREATE VIEW vwInterpreterNotes_SubView
		AS
			SELECT DISTINCT I1.InterpreterId
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
							FROM [dbo].[InterpreterNote] INN
							INNER JOIN [dbo].[Note] N ON N.Id = INN.NoteId
							INNER JOIN [dbo].[User] U ON U.Id = N.CreatedByUserId
							LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = N.CreatedByUserId
							WHERE I1.InterpreterId = INN.InterpreterId
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)')
						, 1, 1, '') AS Notes
			FROM InterpreterNote I1
			GROUP by InterpreterId
		GO


		/*********************************************************************************************************************/
		