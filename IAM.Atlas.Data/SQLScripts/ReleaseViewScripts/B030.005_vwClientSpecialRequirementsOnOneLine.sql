

/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientSpecialRequirementsOnOneLine', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientSpecialRequirementsOnOneLine;
END		
GO

/*
	Create vwClientSpecialRequirementsOnOneLine
*/
CREATE VIEW vwClientSpecialRequirementsOnOneLine
AS
	SELECT C.Id AS ClientId, CONCAT(C.DisplayName, ' ', STRING_AGG(SR.[Name], ', '), '.') AS SpecialRequirements
	FROM Client C
	INNER JOIN ClientSpecialRequirement CSR ON CSR.ClientId = C.Id
	INNER JOIN SpecialRequirement SR ON SR.Id = CSR.SpecialRequirementId
	WHERE SR.[Disabled] = 'False'
	GROUP BY C.Id, C.DisplayName;

GO