

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerMostCurrentLicence', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerMostCurrentLicence;
END		
GO

CREATE VIEW dbo.vwTrainerMostCurrentLicence
AS
	SELECT 
		TL.TrainerId
		, TL.LicenceNumber
		, TL.LicenceExpiryDate
		, TL.DriverLicenceTypeId
		, DLT.[Name] AS DriverLicenceType
		, TL.LicencePhotoCardExpiryDate
		, TL.LicenceCheckDue
		, TL.DateCreated
	FROM (SELECT TrainerId, MAX(DateCreated) AS DateCreated
				FROM [dbo].[TrainerLicence]
				GROUP BY TrainerId) T
	INNER JOIN [dbo].[TrainerLicence] TL ON TL.TrainerId = T.TrainerId
										AND TL.DateCreated = T.DateCreated
	LEFT JOIN DriverLicenceType DLT ON DLT.Id = TL.DriverLicenceTypeId	
	; 
GO

/*********************************************************************************************************************/
