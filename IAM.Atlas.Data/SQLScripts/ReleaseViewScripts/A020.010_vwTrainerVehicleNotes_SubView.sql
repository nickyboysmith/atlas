
--vwTrainerVehicleNotes_SubView
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerVehicleNotes_SubView', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerVehicleNotes_SubView;
END		
GO
/*
	Create vwTrainerVehicleNotes_SubView
*/
CREATE VIEW vwTrainerVehicleNotes_SubView
AS
	SELECT
		O.Id								AS OrganisationId
		, O.[Name]							AS OrganisationName
		, TOrg.TrainerId					AS TrainerId
		, TV.Id								AS TrainerVehicleId
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
					FROM [dbo].[TrainerVehicleNote] TVN2
					INNER JOIN [dbo].[Note] N ON N.Id = TVN2.NoteId
					INNER JOIN [dbo].[User] U ON U.Id = N.CreatedByUserId
					LEFT JOIN [dbo].[SystemAdminUser] SAU ON SAU.UserId = N.CreatedByUserId
					WHERE TVN2.TrainerVehicleId = TV.Id
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
				, 1, 1, '') AS Notes
	FROM dbo.Organisation O
	INNER JOIN dbo.TrainerOrganisation TOrg				ON TOrg.OrganisationId = O.Id
	INNER JOIN dbo.TrainerVehicle TV					ON TV.TrainerId = TOrg.TrainerId
	;

GO


/*********************************************************************************************************************/
		