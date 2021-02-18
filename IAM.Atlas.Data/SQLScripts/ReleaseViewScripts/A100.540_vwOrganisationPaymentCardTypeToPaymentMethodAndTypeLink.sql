
		-- Organisation Payment Card Type to Payment Method and Type Links List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLink', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLink;
		END		
		GO

		/*
			Create vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLink
		*/
		CREATE VIEW vwOrganisationPaymentCardTypeToPaymentMethodAndTypeLink
		AS
			SELECT DISTINCT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, PT.Id						AS PaymentTypeId
				, PT.[Name]					AS PaymentTypeName
				, PCT.Id					AS PaymentCardTypeId
				, PCT.[Name]				AS PaymentCardTypeName
				, PM.Id						AS PaymentMethodId
				, PM.[Name]					AS PaymentMethodName
			FROM dbo.Organisation O
			INNER JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
			LEFT JOIN dbo.OrganisationPaymentType OPT			ON OPT.OrganisationId = O.Id
			LEFT JOIN dbo.PaymentType PT						ON PT.Id = OPT.PaymentTypeId
			LEFT JOIN dbo.PaymentMethod PM						ON PM.OrganisationId = O.Id
			LEFT JOIN dbo.PaymentCardTypePaymentMethod PCTPM	ON PCTPM.PaymentMethodId = PM.Id
			LEFT JOIN dbo.PaymentCardType PCT					ON PCT.Id = PCTPM.PaymentCardTypeId
			;
			
		GO

		/*********************************************************************************************************************/
		