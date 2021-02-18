	/*
		Drop the View if it already exists
	*/

	IF OBJECT_ID('dbo.vwCourseInterpretersCount_SubView', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseInterpretersCount_SubView;
	END		
	GO


	/*
		Create vwCourseTrainersCount_SubView
		NB. This view is used within view "vwCourseInterpreter"
		AND [vwCourseInterpreterConcatenatedInterpreters_SubView]
	*/

	CREATE VIEW dbo.vwCourseInterpretersCount_SubView
	AS
		SELECT 
			CI.CourseId AS CourseId
			, COUNT(*) As NumberOfInterpreters
		FROM CourseInterpreter CI
		GROUP BY CI.[CourseId]
	GO

	/*********************************************************************************************************************/
