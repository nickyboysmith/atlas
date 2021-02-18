/*
	SCRIPT: Create View New Courses Needing DORS to be Notified
	Author: Robert Newnham
	Created: 16/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_26.01_CreateViewvwNewCoursesAwaitinDORSNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create View Venue Details List';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwNewCoursesAwaitinDORSNotification', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwNewCoursesAwaitinDORSNotification;
	END		
	GO
		

	/*
		Create View vwNewCoursesAwaitinDORSNotification
	*/
	CREATE VIEW dbo.vwNewCoursesAwaitinDORSNotification 	
	AS
		SELECT 
			C.OrganisationId		AS OrganisationId
			, O.[Name]				AS OrganisationName	
			, C.Id					AS CourseId
			, C.CourseTypeId		AS CourseTypeId
			, CT.Title				AS CourseTypeTitle
			, CT.Code				AS CourseTypeCode
			, CD.StartDate			AS CourseStartDate
			, CD.EndDate			AS CourseEndDate
			, C.TrainersRequired	AS TrainersRequired
		FROM [dbo].[Course] C
		INNER JOIN [dbo].[Organisation] O ON O.Id = C.OrganisationId
		INNER JOIN [dbo].[CourseType] CT ON CT.Id = C.CourseTypeId
		INNER JOIN dbo.vwCourseDates_SubView CD ON CD.Courseid = C.Id
		WHERE [DORSCourse] = 'True'
		AND [DORSNotificationRequested] = 'True'
		AND [DORSNotified] = 'False';
		
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP026_26.01_CreateViewvwNewCoursesAwaitinDORSNotification.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 

