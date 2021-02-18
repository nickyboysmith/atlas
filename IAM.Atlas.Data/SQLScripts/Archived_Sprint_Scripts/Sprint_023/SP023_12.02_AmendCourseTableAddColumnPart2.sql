/*
 * SCRIPT: Amend Course Table Add Column. Populate the column
 * Author: Robert Newnham
 * Created: 14/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_12.02_AmendCourseTableAddColumnPart2.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Course Table Add Column. Populate the column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/*** START OF SCRIPT ***/
		
		IF OBJECT_ID('tempdb..#CourseDate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #CourseDate;
		END

		SELECT DISTINCT C.Id, MIN(CD.[DateStart]) AS CourseDateStart
		INTO #CourseDate
		FROM Course C
		INNER JOIN [dbo].[CourseDate] CD ON CD.CourseId = C.Id
		WHERE CD.[DateStart] IS NOT NULL
		GROUP BY C.Id
		ORDER BY C.Id;
		
		UPDATE C
		SET C.LastBookingDate = DATEADD(d, -1, CD.CourseDateStart)
		FROM dbo.Course C 
		INNER JOIN #CourseDate CD ON CD.Id = C.Id;

		IF OBJECT_ID('tempdb..#DORSControl', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #DORSControl;
		END

		/*** END OF SCRIPT ***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;