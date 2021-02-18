

		

--vwRefundRequestNotes_SubView
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwRefundRequestNotes_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwRefundRequestNotes_SubView;
END		
GO
/*
	Create vwRefundRequestNotes_SubView
*/
CREATE VIEW vwRefundRequestNotes_SubView
AS
	SELECT DISTINCT RRN1.RefundRequestId
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
					FROM [dbo].[RefundRequestNote] RRN
					INNER JOIN [dbo].[Note] N ON N.Id = RRN.NoteId
					INNER JOIN [dbo].[User] U ON U.Id = N.CreatedByUserId
					LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = N.CreatedByUserId
					WHERE RRN1.RefundRequestId = RRN.RefundRequestId
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, '') AS Notes
	FROM RefundRequestNote RRN1
	GROUP by RefundRequestId
GO


/*********************************************************************************************************************/
		