/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwPaymentCardValidationType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwPaymentCardValidationType;
END		
GO

/*
	Create View vwPaymentCardValidationType
*/

CREATE VIEW dbo.vwPaymentCardValidationType
AS
	SELECT 
		PCVT.Id										AS PaymentCardValidationTypeId
		, PCVT.[Name]								AS PaymentCardValidationTypeName
		, PCVTV.Id									AS PaymentCardValidationTypeVariationId
		, PCVTV.IssuerIdentificationCharacters		AS IssuerIdentificationCharacters
		, PCVTL.Id									AS PaymentCardValidationTypeLengthId
		, PCVTL.ValidLength							AS ValidLength
	FROM [dbo].[PaymentCardValidationType] PCVT
	LEFT JOIN [dbo].[PaymentCardValidationTypeVariation] PCVTV			ON PCVTV.PaymentCardValidationTypeId = PCVT.Id
	LEFT JOIN [dbo].[PaymentCardValidationTypeLength] PCVTL				ON PCVTL.PaymentCardValidationTypeId = PCVT.Id
	WHERE PCVTV.[Disabled] = 'False'
	AND PCVTL.[Disabled] = 'False'
	;
GO
		
/*********************************************************************************************************************/