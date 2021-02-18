

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwTrainerDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwTrainerDetail;
END		
GO

CREATE VIEW dbo.vwTrainerDetail
AS
	SELECT 
		TOrg.OrganisationId								AS OrganisationId
		, O.[Name]										AS OrganisationName
		, TOrg.TrainerId								AS TrainerId
		, T.DisplayName									AS TrainerName
		, T.DateOfBirth									AS TraineDateOfBirth
		, T.GenderId									AS GenderId
		, G.[Name]										AS TrainerGender
		, TPR.[TrainerMainPhoneNumber]					AS TrainerMainPhoneNumber
		, TPR.[TrainerMainPhoneType]					AS TrainerMainPhoneType
		, TPR.[TrainerSecondPhoneNumber]				AS TrainerSecondPhoneNumber
		, TPR.[TrainerSecondPhoneType]					AS TrainerSecondPhoneType
		, L.[Address]									AS TrainerAddress
		, L.PostCode									AS TrainerPostCode
		, TLI.LicenceNumber								AS TrainerLicenceNumber
		, TLI.LicenceExpiryDate							AS TrainerLicenceExpiryDate
	FROM dbo.TrainerOrganisation TOrg
	INNER JOIN dbo.Organisation O						ON O.Id = Torg.OrganisationId 
	INNER JOIN dbo.Trainer T							ON T.Id = TOrg.TrainerId
	INNER JOIN dbo.Gender G								ON G.Id = T.GenderId
	LEFT JOIN dbo.vwTrainerPhoneRow TPR					ON TPR.TrainerId = TOrg.TrainerId
	LEFT JOIN dbo.TrainerLocation TL					ON TL.TrainerId = TOrg.TrainerId
														AND TL.MainLocation = 'True'
	LEFT JOIN dbo.[Location] L							ON L.Id = TL.LocationId
	LEFT JOIN vwTrainerMostCurrentLicence TLI			ON TLI.TrainerId = TOrg.TrainerId	
	;
GO

/*********************************************************************************************************************/