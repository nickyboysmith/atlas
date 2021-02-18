
		IF OBJECT_ID('dbo.vwCourseAmountPaid_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseAmountPaid_SubView;
		END		
		GO
	
		/*
			Create View vwCourseAmountPaid_SubView
			NB. This view is used within view "vwCourseDetail" and "vwClientsWithinCourse"
		*/
		CREATE VIEW dbo.vwCourseAmountPaid_SubView
		AS
			SELECT
				CCP.CourseId
				, SUM(p.Amount) AS PaidSum
			FROM dbo.CourseClientPayment CCP
			INNER JOIN dbo.Payment P ON P.Id = CCP.PaymentId
			GROUP BY CCP.CourseId
			;	
		GO
		
		/*********************************************************************************************************************/
		
