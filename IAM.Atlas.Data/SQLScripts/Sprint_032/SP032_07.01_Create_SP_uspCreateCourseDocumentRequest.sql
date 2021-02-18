/*
	SCRIPT: Create uspCreateCourseDocumentRequest
	Author: Dan Hough
	Created: 13/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_07.01_Create_SP_uspCreateCourseDocumentRequest.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspCreateCourseDocumentRequest';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateCourseDocumentRequest', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateCourseDocumentRequest;
END		
GO
	/*
		Create uspCreateCourseDocumentRequest
	*/

	CREATE PROCEDURE dbo.uspCreateCourseDocumentRequest @courseId INT, @courseDocumentRequestTypeId INT
	AS
	BEGIN
				
		INSERT INTO dbo.CourseDocumentRequest(CourseId
												, DateRequested
												, RequestedByUserId
												, CourseDocumentRequestTypeId
												, RequestCompleted)

										VALUES(@courseId
												, GETDATE()
												, dbo.udfGetSystemUserId()
												, @courseDocumentRequestTypeId
												, 'False');
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP032_07.01_Create_SP_uspCreateCourseDocumentRequest.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

