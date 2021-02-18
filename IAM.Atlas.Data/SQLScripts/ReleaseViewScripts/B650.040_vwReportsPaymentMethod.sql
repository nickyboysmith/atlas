/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwReportsPaymentMethod', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwReportsPaymentMethod;
END		
GO

/*
	Create vwReportsPaymentMethod
*/
CREATE VIEW vwReportsPaymentMethod
AS
	SELECT DISTINCT
		CLO.OrganisationId					AS OrganisationId
		, O.[Name]							AS OrganisationName
		, PM.Id
		, PM.[Name]
			+ (CASE WHEN O.[Name] = PMO.[Name]
					THEN ''
					ELSE ' (' + PMO.[Name] + ')'
					END)					AS [Name]
		, PM.Description
		, PM.Code
		, PM.Disabled
	FROM dbo.ClientOrganisation CLO
	INNER JOIN dbo.Organisation O			ON O.Id = CLO.OrganisationId
	INNER JOIN dbo.ClientPayment CLP		ON CLP.ClientId = CLO.ClientId
	INNER JOIN dbo.Payment P				ON P.Id = CLP.PaymentId
	INNER JOIN dbo.PaymentMethod PM			ON PM.Id = P.PaymentMethodId
	INNER JOIN dbo.Organisation PMO			ON PMO.Id = PM.OrganisationId
	;

GO

/*********************************************************************************************************************/
