
		-- Organisation Payment Card Type to Payment Method Links List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationPaymentCardTypeToPaymentMethodLink', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationPaymentCardTypeToPaymentMethodLink;
		END		
		GO

		/*
			Create vwOrganisationPaymentCardTypeToPaymentMethodLink
		*/
		CREATE VIEW vwOrganisationPaymentCardTypeToPaymentMethodLink
		AS
			SELECT DISTINCT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, PCT.Id					AS PaymentCardTypeId
				, PCT.[Name]				AS PaymentCardTypeName
				, PM.Id						AS PaymentMethodId
				, PM.[Name]					AS PaymentMethodName
			FROM dbo.Organisation O
			INNER JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
			INNER JOIN dbo.PaymentMethod PM						ON PM.OrganisationId = O.Id
			LEFT JOIN dbo.PaymentCardTypePaymentMethod PCTPM	ON PCTPM.PaymentMethodId = PM.Id
			LEFT JOIN dbo.PaymentCardType PCT					ON PCT.Id = PCTPM.PaymentCardTypeId
			;
			
		GO
		/*********************************************************************************************************************/
		