	/*
		Drop the View if it already exists
	*/

	IF OBJECT_ID('dbo.vwCourseInterpreterConcatenatedInterpreters_SubView', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseInterpreterConcatenatedInterpreters_SubView;
	END		
	GO

/*
	Create [vwCourseInterpreterConcatenatedInterpreters_SubView]

	NB. Used in vwCourseInterpreter
*/
CREATE VIEW [dbo].[vwCourseInterpreterConcatenatedInterpreters_SubView]
AS
	SELECT DISTINCT CI.CourseId 
		, STUFF(
					(
					SELECT ',' + CI1.InterpreterName
					FROM vwCourseInterpreters_SubView CI1
					WHERE CI1.CourseId = CI.CourseId
					FOR XML PATH('')
					)
					, 1, 1, '') AS Interpreters
		, CIC.NumberOfInterpreters
	FROM vwCourseInterpreters_SubView CI
	INNER JOIN vwCourseInterpretersCount_SubView CIC ON CIC.CourseId = CI.CourseId;

