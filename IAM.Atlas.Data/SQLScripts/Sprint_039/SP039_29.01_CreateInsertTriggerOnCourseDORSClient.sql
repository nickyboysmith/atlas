/*
	SCRIPT: Create Insert trigger on CourseDORSClient
	Author: Robert Newnham
	Created: 28/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_29.01_CreateInsertTriggerOnCourseDORSClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Insert trigger on CourseDORSClient';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseDORSClient_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDORSClient_Insert;
	END
GO

	CREATE TRIGGER [dbo].[TRG_CourseDORSClient_INSERT] ON [dbo].[CourseDORSClient] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'CourseDORSClient', 'TRG_CourseDORSClient_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			DELETE CDC
			FROM INSERTED I
			INNER JOIN CourseDORSClient CDC ON CDC.CourseId = I.CourseId
											AND CDC.ClientId = I.ClientId
			WHERE I.Id != CDC.Id

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_29.01_CreateInsertTriggerOnCourseDORSClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO