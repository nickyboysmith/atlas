/*
	SCRIPT: Create Stored procedure uspCoursesessionAllocationRefreshDefault
	Author: Robert Newnham
	Created: 19/01/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_16.01_Create_SP_uspCourseSessionAllocationRefreshDefault.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Stored procedure uspCoursesessionAllocationRefreshDefault';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseSessionAllocationRefreshDefault', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseSessionAllocationRefreshDefault;
END		
GO
	/*
		Create uspCoursesessionAllocationRefreshDefault
	*/

	CREATE PROCEDURE dbo.uspCourseSessionAllocationRefreshDefault (@CourseId INT)
	AS
	BEGIN
	
			DELETE [dbo].[CourseSessionAllocation]
			WHERE CourseId = @CourseId;
			 
			--This Will Set The Defaults For CourseSessionAllocation Table
			-- WHEN The Session is Just AM OR PM OR EVE Then there will just be one Row  
			-- WHEN The Session is "AM & PM" OR "PM AND EVE" Then There will be two Rows 
			INSERT INTO [dbo].[CourseSessionAllocation] (CourseId, SessionNumber, TheoryElement, PracticalElement)
			SELECT Alloc.CourseId, Alloc.SessionNumber, Alloc.TheoryElement, Alloc.PracticalElement
			FROM (
					SELECT DISTINCT
						CD.CourseId
						, (CASE WHEN TS.Title IN ('AM', 'PM', 'EVE')
									THEN  CD.AssociatedSessionNumber
								WHEN TS.Title LIKE '%AM%' -- IE LIKE 'AM & PM'
									THEN (SELECT TOP 1 Number FROM TrainingSession WHERE Title = 'AM')
								WHEN TS.Title LIKE '%PM%' -- IE LIKE 'PM & EVE'
									THEN (SELECT TOP 1 Number FROM TrainingSession WHERE Title = 'PM')
								ELSE (SELECT TOP 1 Number FROM TrainingSession WHERE Title = 'EVE')
								END)							AS SessionNumber
						, ISNULL(C.TheoryCourse, 'False')		AS TheoryElement
						, (CASE WHEN TS.Title IN ('AM', 'PM', 'EVE') -- Theory and Practical Both in the Same Session
									AND ISNULL(C.PracticalCourse, 'False') = 'True' 
									THEN  'True'			
								ELSE 'False'						-- Multi Session or No Practical
								END)							AS PracticalElement
					FROM CourseDate CD
					INNER JOIN Course C ON C.Id = CD.CourseId
					INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
					WHERE CD.CourseId = @CourseId
					AND CD.[AssociatedSessionNumber] IS NOT NULL
					AND NOT (ISNULL(C.TheoryCourse, 'False') = 'False' AND ISNULL(C.PracticalCourse, 'False') = 'False')
					UNION -- Add in the Second Part of the Multi Session
					SELECT DISTINCT
						CD.CourseId
						, (CASE WHEN TS.Title LIKE '%EVE%' -- IE LIKE 'PM & EVE'
									THEN (SELECT TOP 1 Number FROM TrainingSession WHERE Title = 'EVE')
								ELSE (SELECT TOP 1 Number FROM TrainingSession WHERE Title = 'PM')
								END)							AS SessionNumber
						, (CASE WHEN ISNULL(C.PracticalCourse, 'False') = 'False'
									THEN ISNULL(C.TheoryCourse, 'False')		--Theory in Both Sessions
									ELSE 'False'
									END)						AS TheoryElement
						, ISNULL(C.PracticalCourse, 'False')	AS PracticalElement
					FROM CourseDate CD
					INNER JOIN Course C ON C.Id = CD.CourseId
					INNER JOIN TrainingSession TS ON TS.Number = CD.AssociatedSessionNumber
					WHERE CD.CourseId = @CourseId
					AND CD.[AssociatedSessionNumber] IS NOT NULL
					AND TS.Title NOT IN ('AM', 'PM', 'EVE')
					AND NOT (ISNULL(C.TheoryCourse, 'False') = 'False' AND ISNULL(C.PracticalCourse, 'False') = 'False')
					) Alloc
			LEFT JOIN [dbo].[CourseSessionAllocation] CSA	ON CSA.CourseId = Alloc.CourseId
			WHERE CSA.Id IS NULL -- Not Already Updated.

	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_16.01_Create_SP_uspCourseSessionAllocationRefreshDefault.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO