		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwReconciliationList', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwReconciliationList;
		END		
		GO
		/*
			Create vwReconciliationList
		*/
		 
		CREATE VIEW dbo.vwReconciliationList
		AS

			SELECT O.Id						AS OrganisationId
					, O.[Name]				AS OrganisationName
					, R.Id					AS ReconciliationId
					, R.DateCreated			AS DateCreated
					, RC.Id					AS ReconciliationConfigurationId
					, R.[Name]				AS ReconciliationName
			FROM dbo.Reconciliation R 
			INNER JOIN dbo.ReconciliationConfiguration RC ON R.ReconciliationConfigurationId = RC.Id
			INNER JOIN dbo.Organisation O ON RC.OrganisationId = O.Id
			;
			
			GO


		/*********************************************************************************************************************/