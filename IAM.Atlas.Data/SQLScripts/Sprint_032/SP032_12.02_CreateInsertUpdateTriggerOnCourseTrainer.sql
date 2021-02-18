/*
	SCRIPT: Create Insert Update trigger TRG_CourseTrainerDocumentRequest_InsertUpdate on table CourseClient
	Author: Dan Hough
	Created: 17/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_12.02_CreateInsertUpdateTriggerOnCourseTrainer';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert Update trigger TRG_CourseTrainerDocumentRequest_InsertUpdate on table CourseTrainer';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseTrainerDocumentRequest_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseTrainerDocumentRequest_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_CourseTrainerDocumentRequest_InsertUpdate ON dbo.CourseTrainer AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseTrainer', 'TRG_CourseTrainerDocumentRequest_InsertUpdate', @insertedRows, @deletedRows;
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
DECLARE @ScriptName VARCHAR(100) = 'SP032_12.02_CreateInsertUpdateTriggerOnCourseTrainer';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO