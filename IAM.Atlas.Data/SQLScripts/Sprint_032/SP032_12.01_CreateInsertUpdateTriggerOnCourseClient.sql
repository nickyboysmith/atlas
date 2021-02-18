/*
	SCRIPT: Create Insert Update trigger TRG_CourseClientDocumentRequest_InsertUpdate on table CourseClient
	Author: Dan Hough
	Created: 17/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_12.01_CreateInsertUpdateTriggerOnCourseClient';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Update trigger TRG_CourseClientDocumentRequest_InsertUpdate on table CourseClient';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseClientDocumentRequest_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClientDocumentRequest_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_CourseClientDocumentRequest_InsertUpdate ON dbo.CourseClient AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClient', 'TRG_CourseClientDocumentRequest_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @courseSignInReqTypeId INT
					, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
					, @courseRegisterReqTypeId INT
					, @courseRegisterDescription CHAR(15) = 'Course Register';
			

			SELECT @courseId = CourseId FROM inserted i;
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
DECLARE @ScriptName VARCHAR(100) = 'SP032_12.01_CreateInsertUpdateTriggerOnCourseClient';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO