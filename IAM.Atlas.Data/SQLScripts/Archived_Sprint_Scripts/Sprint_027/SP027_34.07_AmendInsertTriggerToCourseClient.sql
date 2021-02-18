/*
	SCRIPT: Amend Insert Trigger on CourseClient Table
	Author: Robert Newnham
	Created: 15/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_34.07_AmendInsertTriggerToCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert Trigger on CourseClient Table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseClient_Insert]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_CourseClient_Insert];
	END
GO
		CREATE TRIGGER TRG_CourseClient_Insert ON CourseClient AFTER INSERT
		AS

		BEGIN
			DECLARE @courseId INT = NULL
				, @clientId INT = NULL;
			SELECT @courseId = I.CourseId, @clientId = I.ClientId
			FROM INSERTED I;

			EXEC dbo.uspInsertCourseDORSClientDataIfMissing @courseId, @clientId;

		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP027_34.07_AmendInsertTriggerToCourseClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO