/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.vwPaymentCardType', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwPaymentCardType;
END		
GO

/*
	Create View vwPaymentCardType
*/

CREATE VIEW dbo.vwPaymentCardType 
AS
	SELECT 
		PCT.Id								AS PaymentCardTypeId
		, PCT.[Name]						AS PaymentCardTypeName
		, PCT.DisplayName					AS PaymentCardTypeDisplayName
		, PCT.[Disabled]					AS PaymentCardTypeDisabled
		, PCT.PaymentCardValidationTypeId	AS PaymentCardValidationTypeId
		, PCVT.[Name]						AS PaymentCardValidationTypeName
	FROM dbo.PaymentCardType PCT
	LEFT JOIN dbo.PaymentCardValidationType PCVT ON PCVT.Id = PCT.PaymentCardValidationTypeId
	;
GO
		
/*********************************************************************************************************************/