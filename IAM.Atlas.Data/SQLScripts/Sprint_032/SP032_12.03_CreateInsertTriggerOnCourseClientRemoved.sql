/*
	SCRIPT: Create Insert Update trigger TRG_CourseClientRemovedDocumentRequest_Insert on table CourseClientRemovedDocumentRequest
	Author: Dan Hough
	Created: 17/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_12.03_CreateInsertTriggerOnCourseClientRemoved';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger TRG_CourseClientRemovedDocumentRequest_Insert on table CourseClientRemoved';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseClientRemovedDocumentRequest_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClientRemovedDocumentRequest_Insert;
	END
GO
	CREATE TRIGGER TRG_CourseClientRemovedDocumentRequest_Insert ON dbo.CourseClientRemoved AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClientRemoved', 'TRG_CourseClientRemovedDocumentRequest_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = Courseid FROM inserted i;
			SELECT @courseSignInReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseSignInDescription;
			SELECT @courseRegisterReqTypeId = Id FROM dbo.CourseDocumentRequestType WHERE [Name] = @courseRegisterDescription;

			IF(@courseId IS NOT NULL AND @courseSignInReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseSignInReqTypeId;
			END
			IF(@courseId IS NOT NULL AND @courseRegisterReqTypeId IS NOT NULL)
			BEGIN
				EXEC dbo.uspCreateCourseDocumentRequest @courseId, @courseRegisterReqTypeId;
			END

		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_12.03_CreateInsertTriggerOnCourseClientRemoved';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO