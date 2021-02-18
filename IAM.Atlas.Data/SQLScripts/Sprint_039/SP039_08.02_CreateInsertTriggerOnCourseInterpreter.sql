/*
	SCRIPT: Create insert trigger on the CourseInterpreter table
	Author: Dan Hough
	Created: 13/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_08.02_CreateInsertTriggerOnCourseInterpreter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create insert trigger on the CourseInterpreter table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_CourseInterpreter_Insert]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.TRG_CourseInterpreter_Insert;
		END
GO


CREATE TRIGGER [dbo].[TRG_CourseInterpreter_Insert] ON [dbo].[CourseInterpreter] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN --START PROCESS
			--Log Trigger Running
			EXEC uspLogTriggerRunning 'CourseInterpreter', 'TRG_CourseInterpreter_Insert', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------

			DECLARE @interpreterId INT
					, @courseId INT
					, @organisationId INT
					, @interpretersHaveCourseReference BIT;

			SELECT @interpreterId = i.InterpreterId
					, @courseId = i.CourseId
					, @organisationId = c.OrganisationId
					, @interpretersHaveCourseReference = osc.TrainersHaveCourseReference
			FROM Inserted i
			INNER JOIN dbo.Course c ON i.CourseId = c.Id
			INNER JOIN dbo.OrganisationSelfConfiguration osc ON c.OrganisationId = osc.OrganisationId;

			IF ((@interpretersHaveCourseReference = 'True') AND (@interpreterId > 0) AND (@courseId > 0) AND (@organisationId > 0)) 
			BEGIN
				EXEC dbo.uspInsertCourseInterpreterReference @organisationId, @courseId, @interpreterId;
			END
		END --END PROCESS
	END
	

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP039_08.02_CreateInsertTriggerOnCourseInterpreter.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO