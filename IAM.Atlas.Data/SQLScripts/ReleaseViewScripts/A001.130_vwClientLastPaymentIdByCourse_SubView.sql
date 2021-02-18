
		/*
			Drop the Procedure if it already exists
		*/		
		IF OBJECT_ID('dbo.vwLastClientPaymentIdByCourse', 'V') IS NOT NULL
		BEGIN
			--Previous Name of the View
			DROP VIEW dbo.vwLastClientPaymentIdByCourse;
		END		
		GO	
		IF OBJECT_ID('dbo.vwClientLastPaymentIdByCourse_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientLastPaymentIdByCourse_SubView;
		END		
		GO

		/*
			Create View vwClientLastPaymentIdByCourse_SubView
			NB. This view is used within view "vwClientsWithinCourse"
		*/
		CREATE VIEW dbo.vwClientLastPaymentIdByCourse_SubView
		AS			
			SELECT 
				CourseId
				, ClientId
				, MAX(PaymentId) as LastPaymentId
			FROM CourseClientPayment 
			GROUP BY CourseId, ClientId

		GO
		
		/*********************************************************************************************************************/
		