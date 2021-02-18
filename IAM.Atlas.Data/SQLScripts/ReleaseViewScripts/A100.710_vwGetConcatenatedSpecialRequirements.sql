/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwGetConcatenatedSpecialRequirements', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwGetConcatenatedSpecialRequirements;
END		
GO

/*
	Create View vwGetConcatenatedSpecialRequirements
*/

CREATE VIEW dbo.vwGetConcatenatedSpecialRequirements 
AS	
	SELECT C.Id AS ClientId, STRING_AGG([Description], CHAR(13) + CHAR(10)) AS SpecialRequirements
	FROM dbo.Client C
	INNER JOIN dbo.ClientSpecialRequirement CSR on C.id = CSR.ClientId
	INNER JOIN dbo.SpecialRequirement SR on CSR.SpecialRequirementId = SR.Id
	GROUP BY C.Id
GO
		
/*********************************************************************************************************************/