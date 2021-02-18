

		

		--vwClientNotes_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientNotes_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientNotes_SubView;
		END		
		GO
		/*
			Create vwClientNotes_SubView
			NB. This view is used in GetEntry method in ClientController.
			Refactoring, will enable it to be used in vwClientDetails when this view is created.
		*/
		CREATE VIEW vwClientNotes_SubView
		AS
			SELECT DISTINCT C1.ClientId
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
							FROM [dbo].[ClientNote] CN
							INNER JOIN [dbo].[Note] N ON N.Id = CN.NoteId
							INNER JOIN [dbo].[User] U ON U.Id = N.CreatedByUserId
							LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = N.CreatedByUserId
							WHERE C1.ClientId = CN.ClientId
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)')
						, 1, 1, '') AS Notes
			FROM ClientNote C1
			GROUP by ClientId
		GO


		/*********************************************************************************************************************/
		