		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwReconciliationData', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwReconciliationData;
		END		
		GO
		/*
			Create vwReconciliationData
		*/
		 
		CREATE VIEW dbo.vwReconciliationData
		AS

			SELECT O.Id											AS OrganisationId
					, O.[Name]									AS OrganisationName
					, R.Id										AS ReconciliationId
					, RC.Id										AS ReconciliationConfigurationId
					, RD.Id										AS ReconciliationDataId
					, RD.ReconciliationTransactionDate			AS ReconciliationTransactionDate
					, RD.ReconciliationTransactionAmount		AS ReconciliationTransactionAmount
					, RD.ReconciliationReference1				AS ReconciliationReference1
					, RD.ReconciliationReference2				AS ReconciliationReference2
					, RD.ReconciliationReference3				AS ReconciliationReference3
					, RD.PaymentId								AS PaymentId
					, RD.PaymentTransactionDate					AS PaymentTransactionDate
					, RD.PaymentAmount							AS PaymentAmount
					, RD.PaymentAuthCode						AS PaymentAuthCode
					, RD.ReceiptNumber							AS ReceiptNumber
					, RD.Duplicate								AS Duplicate
					, RDC.ReconciliationDataComment				AS ReconciliationDataComment
			FROM dbo.Reconciliation R 
			INNER JOIN dbo.ReconciliationData RD ON R.Id = RD.ReconciliationId
			INNER JOIN dbo.ReconciliationConfiguration RC ON R.ReconciliationConfigurationId = RC.Id
			INNER JOIN dbo.Organisation O ON RC.OrganisationId = O.Id
			LEFT JOIN vwReconciliationDataComment RDC ON RDC.ReconciliationId = R.Id
			;
			
			GO


		/*********************************************************************************************************************/