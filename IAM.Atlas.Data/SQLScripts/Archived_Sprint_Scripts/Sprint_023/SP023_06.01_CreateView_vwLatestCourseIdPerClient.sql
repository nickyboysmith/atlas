
/*
	SCRIPT: Create a view to find the latest course Id per client
	Author: Dan Hough
	Created: 11/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_06.01_CreateView_vwLatestCourseIdPerClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to find the latest course Id per client';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwLatestCourseIdPerClient', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwLatestCourseIdPerClient;
	END		
	GO

	/*
		Create View vwLatestCourseIdPerClient
	*/
	CREATE VIEW dbo.vwLatestCourseIdPerClient AS	
	
		SELECT Max(CourseId) AS CourseId
			 , ClientId
		FROM CourseClient
		GROUP BY ClientId

GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_06.01_CreateView_vwLatestCourseIdPerClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
