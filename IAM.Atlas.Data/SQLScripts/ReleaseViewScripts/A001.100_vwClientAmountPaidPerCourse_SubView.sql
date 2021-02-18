
		IF OBJECT_ID('dbo.vwAmountPaidPerCourse', 'V') IS NOT NULL
		BEGIN
			--Previous Name of the View
			DROP VIEW dbo.vwAmountPaidPerCourse;
		END		
		GO
		IF OBJECT_ID('dbo.vwClientAmountPaidPerCourse_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientAmountPaidPerCourse_SubView;
		END		
		GO
	
		/*
			Create View vwClientAmountPaidPerCourse_SubView
			NB. This view is used within view "vwCourseDetail" and "vwClientsWithinCourse"
		*/
		CREATE VIEW dbo.vwClientAmountPaidPerCourse_SubView
		AS
			SELECT
				CCP.ClientId 
				, CCP.CourseId
				, SUM(p.Amount) AS PaidSum
			FROM dbo.CourseClientPayment CCP
			INNER JOIN dbo.Payment P ON P.Id = CCP.PaymentId
			GROUP BY CCP.ClientId , CCP.CourseId
			;	
		GO
		
		/*********************************************************************************************************************/
		