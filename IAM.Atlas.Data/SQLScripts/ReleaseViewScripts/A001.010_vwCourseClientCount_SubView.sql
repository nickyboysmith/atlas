
		--Create Sub View vwCourseClientCount_SubView
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseClientCount_SubView', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientCount_SubView;
		END		
		GO

		/*
			Create vwCourseClientCount_SubView
			NB. This view is used within view "vwCourseDetail"
		*/
		CREATE VIEW vwCourseClientCount_SubView
		AS
			SELECT 
				C.Id AS CourseId
				, Count(CC.ClientId) AS NumberOfClients
			FROM [dbo].[Course] C
			LEFT JOIN [dbo].[CourseClient] CC ON CC.CourseId = C.Id
			LEFT JOIN [dbo].[CourseClientRemoved] CCR ON CCR.CourseClientId = CC.Id
			WHERE CCR.Id IS NULL
			GROUP BY C.Id; 
		GO

		/*********************************************************************************************************************/
		