	/*
		Drop the View if it already exists
	*/

	IF OBJECT_ID('dbo.vwCourseInterpreterCount_SubView', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseInterpreterCount_SubView;
	END		
	GO
		/*
			Create [vwCourseInterpreterCount_SubView]
		*/
		CREATE VIEW [dbo].[vwCourseInterpreterCount_SubView] 
		AS		
			SELECT 
				ISNULL(C.OrganisationId,0)				AS OrganisationId
				, ISNULL(CIR.CourseId,0)				AS CourseId
				, InterpreterList.NumberOfInterpreters	AS NumberOfInterpretersBookedOnCourse
				, ISNULL(CIR.InterpreterId,0)			AS InterpreterId
				, ROW_NUMBER() OVER(PARTITION BY  C.OrganisationId, CIR.CourseId, InterpreterList.NumberOfInterpreters
									ORDER BY C.OrganisationId, CIR.CourseId, CIR.[DateCreated], InterpreterList.NumberOfInterpreters) AS InterpreterNumber
			FROM [dbo].[CourseInterpreter] CIR
			INNER JOIN [dbo].[Course] C ON C.Id = CIR.CourseId
			INNER JOIN dbo.vwCourseInterpreterConcatenatedInterpreters_SubView InterpreterList ON InterpreterList.CourseId = C.id			
			;

GO


