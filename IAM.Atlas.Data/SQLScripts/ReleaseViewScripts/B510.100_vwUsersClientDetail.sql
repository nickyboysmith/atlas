

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwUsersClientDetail', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwUsersClientDetail;
END		
GO

CREATE VIEW dbo.vwUsersClientDetail
AS
	SELECT CV.ViewedByUserId AS UserId
			, U.[Name] AS UserName
			, CV.DateTimeViewed AS DateUserLastViewedClient
			, VWCD.OrganisationId
			, VWCD.OrganisationName
			, VWCD.ClientId
			, VWCD.DisplayName
			, VWCD.ClientCreatedDate
			, VWCD.PostCode
			, VWCD.LicenceNumber
			, VWCD.PhoneNumber
			, VWCD.ReferralReference
			, VWCD.CourseId
			, VWCD.CourseStartDate
			, VWCD.CourseReference
			, VWCD.CourseType
			, VWCD.AmountPaidByClient
			, VWCD.StillOnCourse
	FROM dbo.ClientView CV
	INNER JOIN dbo.[User] U ON CV.ViewedByUserId = U.Id
	INNER JOIN dbo.vwClientDetailMinimal VWCD ON CV.ClientId = VWCD.ClientId;
GO

/*********************************************************************************************************************/