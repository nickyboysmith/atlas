
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwLatestExpiringTrainerLicence', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwLatestExpiringTrainerLicence;
END		
GO
/*
	Create vwLatestExpiringTrainerLicence

*/
CREATE VIEW vwLatestExpiringTrainerLicence
AS
	SELECT TL1.TrainerId
			, TL1.LicenceNumber
			, TL1.LicenceExpiryDate
			, TL1.DriverLicenceTypeId
			, TL1.LicencePhotoCardExpiryDate
			, TL1.LicenceCheckDue
			, TL1.DateCreated
		FROM TrainerLicence TL1
		INNER JOIN
			(SELECT TrainerId, MAX(LicenceExpiryDate) AS LicenceExpiryDate, MAX(Datecreated) AS DateCreated
			FROM dbo.TrainerLicence
			GROUP BY TrainerId) TL2 ON TL1.TrainerId = TL2.TrainerId
										AND TL1.LicenceExpiryDate = TL2.LicenceExpiryDate
										AND TL1.DateCreated = TL2.DateCreated;

GO


/*********************************************************************************************************************/
	