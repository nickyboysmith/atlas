/*
	SCRIPT: Create a stored procedure to update set default menu assignments for User or All
	Author: Robert Newnham
	Created: 16/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_29.02_CreateSP_uspSetCoursePaymentDueDateIfRequired.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update generate Report Data';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspSetCoursePaymentDueDateIfRequired', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspSetCoursePaymentDueDateIfRequired;
	END		
	GO

	/*
		Create uspSetCoursePaymentDueDateIfRequired
	*/

	CREATE PROCEDURE uspSetCoursePaymentDueDateIfRequired (@CourseId INT = NULL, @ClientId INT = NULL)
	AS
	BEGIN
		--NB If Not CourseId Supplied then it will Update for All Courses
		--NB If Not ClientId Supplied then it will Update for All Clients
				UPDATE CC
					SET CC.[PaymentDueDate] = DATEADD(DAY
													, (ISNULL(CTF.PaymentDays, 2) * -1)
													, CD.StartDate)
				FROM dbo.CourseClient CC
				INNER JOIN dbo.Course C						ON C.Id = CC.CourseId
				INNER JOIN vwCourseTypeDetail CTF			ON CTF.OrganisationId = C.OrganisationId
															AND CTF.Id = C.CourseTypeId
				INNER JOIN dbo.vwCourseDates_SubView CD		ON CD.Courseid = CC.CourseId
				WHERE CC.CourseId = ISNULL(@CourseId, CC.CourseId)
				AND CC.ClientId = ISNULL(@ClientId, CC.ClientId)
				AND (CC.[PaymentDueDate] IS NULL
					OR CC.[PaymentDueDate] <> DATEADD(DAY
													, (ISNULL(CTF.PaymentDays, 2) * -1)
													, CD.StartDate)
					)
				;
		
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP037_29.02_CreateSP_uspSetCoursePaymentDueDateIfRequired.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO