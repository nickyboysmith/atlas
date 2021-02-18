
		--Client Payment
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientPayment', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientPayment;
		END		
		GO
		/*
			Create vwClientPayment
		*/
		CREATE VIEW vwClientPayment 
		AS
			SELECT			   
				co.OrganisationId				AS OrganisationId
				, cp.Id							AS ClientId
				, c.DisplayName					AS ClientName
				, p.TransactionDate				AS PaymentTransactionDate
				, p.Amount						AS PaymentAmount
				, pt.Name						AS PaymentType
				, pm.name						AS PaymentMethod
				, p.ReceiptNumber				AS ReceiptNumber
				, p.CreatedByUserId				AS CreatedByUserId
				, u.Name						AS CreatedByUserName
				, n.Note						AS PaymentNote
			FROM  Payment p
			LEFT JOIN PaymentType pt ON p.PaymentTypeId = pt.Id
			LEFT JOIN PaymentMethod pm ON p.PaymentMethodId = pm.Id
			LEFT JOIN ClientPayment cp ON p.Id = cp.PaymentId
			LEFT JOIN ClientOrganisation co ON co.ClientId = cp.ClientId
			LEFT JOIN Client c ON c.Id = cp.ClientId
			LEFT JOIN [User] u ON u.Id = p.CreatedByUserId
			LEFT JOIN ClientPaymentNote cpn ON cpn.ClientId = cp.ClientId
											AND cpn.PaymentId = p.Id
			LEFT JOIN Note n ON n.Id = cpn.NoteId
			;
			GO
		/*********************************************************************************************************************/
