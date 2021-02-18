/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportsTrainerDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportsTrainerDetail;
END		
GO

/*
	Create vwReportsTrainerDetail
*/
CREATE VIEW vwReportsTrainerDetail
AS
	SELECT DISTINCT
		OCO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, TD.TrainerId
		, TD.TrainerName
			+ (CASE WHEN O.[Name] = TD.OrganisationName
					THEN ''
					ELSE ' (' + TD.OrganisationName + ')'
					END)					AS TrainerName
		, TD.TraineDateOfBirth
		, TD.GenderId
		, TD.TrainerGender
		, TD.TrainerMainPhoneNumber
		, TD.TrainerMainPhoneType
		, TD.TrainerSecondPhoneNumber
		, TD.TrainerSecondPhoneType
		, TD.TrainerAddress
		, TD.TrainerPostCode
		, TD.TrainerLicenceNumber
		, TD.TrainerLicenceExpiryDate
	FROM dbo.OrganisationCourse OCO
	INNER JOIN dbo.Organisation O		ON O.Id = OCO.OrganisationId
	INNER JOIN dbo.CourseTrainer CT		ON CT.CourseId = OCO.CourseId
	INNER JOIN dbo.vwTrainerDetail TD	ON TD.TrainerId = CT.TrainerId
	;

GO

/*********************************************************************************************************************/
