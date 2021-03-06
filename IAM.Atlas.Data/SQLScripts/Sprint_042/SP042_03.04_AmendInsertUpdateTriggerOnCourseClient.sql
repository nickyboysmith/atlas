/*
	SCRIPT: Amend Insert Update trigger TRG_CourseClientDocumentRequest_InsertUpdate on table CourseClient
	Author: Robert Newnham
	Created: 17/08/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP042_03.04_AmendInsertUpdateTriggerOnCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend & Rename Insert Update trigger on table CourseClient';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseClient_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClient_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_CourseClient_InsertUpdate ON dbo.CourseClient AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseClient', 'TRG_CourseClient_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @courseId INT
					, @clientId INT;
			SELECT @courseId = I.CourseId 
				, @clientId = I.ClientId 
			FROM INSERTED I;
			
			IF (@CourseId >= 0)
			BEGIN
				EXEC dbo.uspSetCourseProfileLockedIfRequired @CourseId;
			END 
			
			BEGIN
				DECLARE @courseSignInReqTypeId INT
						, @courseSignInDescription CHAR(25) = 'Course Attendance Sign-In'
						, @courseRegisterReqTypeId INT
						, @courseRegisterDescription CHAR(15) = 'Course Register';

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
			END

			BEGIN
				EXEC uspSetCoursePaymentDueDateIfRequired @courseId, @clientId
			END

			--Pick Up Referring Authority Organisations so that they get a view on the Courses their Clients are Assigned To.
			INSERT INTO dbo.OrganisationCourse (OrganisationId, CourseId)
			SELECT DISTINCT CO.OrganisationId AS OrganisationId, I.CourseId AS CourseId
			FROM INSERTED I
			INNER JOIN dbo.ClientOrganisation CO ON CO.ClientId = I.ClientId
			LEFT JOIN dbo.OrganisationCourse OC ON OC.OrganisationId = CO.OrganisationId
												AND OC.CourseId = I.CourseId
			WHERE CO.OrganisationId IS NOT NULL
			AND OC.Id IS NULL;

		END --END PROCESS
	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP042_03.04_AmendInsertUpdateTriggerOnCourseClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO