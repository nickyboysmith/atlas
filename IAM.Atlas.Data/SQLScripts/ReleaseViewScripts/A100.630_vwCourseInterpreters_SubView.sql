	/*
		Drop the View if it already exists
	*/

	IF OBJECT_ID('dbo.vwCourseInterpreters_SubView', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseInterpreters_SubView;
	END		
	GO

/*
	Create [vwCourseInterpreters_SubView]
	NB. This view is used within view "vwCourseInterpreterConcatenatedInterpreters_SubView"
*/
CREATE VIEW [dbo].[vwCourseInterpreters_SubView]
AS
	SELECT 
		CI.[CourseId] AS CourseId
		, CI.[InterpreterId] AS InterpreterId
		, (CASE WHEN I.[DisplayName] IS NULL OR I.[DisplayName] = '' 
				THEN  + ' ' + I.[FirstName] + ' ' + I.[Surname]
				ELSE I.[DisplayName]
				END) AS InterpreterName
	FROM dbo.CourseInterpreter CI
	INNER JOIN dbo.Interpreter I ON I.id = CI.InterpreterId;




