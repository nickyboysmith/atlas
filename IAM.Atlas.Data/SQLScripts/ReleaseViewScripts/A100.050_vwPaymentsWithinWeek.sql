
		--Payments Within Week
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwPaymentsWithinWeek', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwPaymentsWithinWeek;
		END		
		GO
		/*
			Create vwPaymentsWithinWeek
		*/
		CREATE VIEW vwPaymentsWithinWeek AS
		
					SELECT co.OrganisationId				AS OrganisationId
						 , DATEPART(YEAR, p.DateCreated)	AS PaymentYear   
						 , DATEPART(WEEK, p.DateCreated)	AS PaymentWeek  
						 , pt.Name							AS PaymentType
						 , pm.Name							AS PaymentMethod
						 , p.Amount							AS PaymentAmount
					
					FROM  Payment p
						  LEFT JOIN PaymentType pt
						  ON p.PaymentTypeId = pt.Id
						  LEFT JOIN PaymentMethod pm
						  ON p.PaymentMethodId = pm.Id
						  LEFT JOIN ClientPayment cp
						  ON p.Id = cp.PaymentId
						  LEFT JOIN ClientOrganisation co
						  ON co.ClientId = cp.ClientId										
		GO
		/*********************************************************************************************************************/
