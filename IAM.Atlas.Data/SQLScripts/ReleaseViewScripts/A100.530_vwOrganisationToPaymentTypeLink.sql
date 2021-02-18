
		-- Organisation to Payment Type Links List
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationToPaymentTypeLink', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationToPaymentTypeLink;
		END		
		GO

		/*
			Create vwOrganisationToPaymentTypeLink
		*/
		CREATE VIEW vwOrganisationToPaymentTypeLink
		AS
			SELECT DISTINCT
				O.Id						AS OrganisationId
				, OD.DisplayName			AS OrganisationName
				, PT.Id						AS PaymentTypeId
				, PT.[Name]					AS PaymentTypeName
			FROM dbo.Organisation O
			INNER JOIN dbo.OrganisationDisplay OD				ON OD.OrganisationId = O.Id
			INNER JOIN dbo.OrganisationPaymentType OPT			ON OPT.OrganisationId = O.Id
			INNER JOIN dbo.PaymentType PT						ON PT.Id = OPT.PaymentTypeId
			;
			
		GO
		/*********************************************************************************************************************/
		