/*
	SCRIPT: Create stored procedure uspCourseTransferClientWithNotes
	Author: Nick Smith
	Created: 18/04/2017

*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_10.01_Create_uspCourseTransferClientWithNotes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspCourseTransferClientWithNotes';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseTransferClientWithNotes', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseTransferClientWithNotes;
END		
GO

/*
	Create uspCourseTransferClientWithNotes
*/
CREATE PROCEDURE [dbo].[uspCourseTransferClientWithNotes] (@fromCourseId INT
												, @toCourseId INT
												, @fromClientId INT
												, @toClientId INT
												, @transferReason VARCHAR(100)
												, @requestedByUserId INT
												, @notes VARCHAR(1000))
AS

BEGIN
	IF(@fromCourseId IS NULL 
		OR @toCourseId IS NULL
		OR @fromClientId IS NULL
		OR @toClientId IS NULL)
	BEGIN
		RAISERROR('@fromCourseId, @toCourseId, @fromClientId, @toClientId are all required parameters. Can not proceed.', 15, 1)
	END
	ELSE
	BEGIN




		DECLARE @requestAlreadyProcessedCheck INT;

		SELECT @requestAlreadyProcessedCheck = Id 
		FROM dbo.CourseClientTransferred 
		WHERE TransferFromCourseId = @fromCourseId 
				AND TransferToCourseId = @toCourseId
				AND ClientId = @toClientId;

		IF(@requestAlreadyProcessedCheck IS NULL)
		BEGIN

			EXEC dbo.uspCourseTransferClient @fromCourseId	
													, @toCourseId 
													, @fromClientId 
													, @toClientId 
													, @transferReason
													, @requestedByUserId


			IF ((@notes IS NOT NULL) OR (LEN(@notes) > 0))
			BEGIN
			
				IF(@fromClientId = @toClientId)
				BEGIN
					INSERT INTO dbo.Note (Note
										, DateCreated
										, CreatedByUserId)
								VALUES (@notes
										, GETDATE()
										, @requestedByUserId);

					INSERT INTO dbo.ClientNote(ClientId, NoteId)
					VALUES(@fromClientId, SCOPE_IDENTITY());
				END

				--If client id's are different, create a note for each client
				IF(@fromClientId != @toClientId)
				BEGIN

					--Insert note for the 'To' client
					INSERT INTO dbo.Note (Note
										, DateCreated
										, CreatedByUserId)
								VALUES (@notes
										, GETDATE()
										, @requestedByUserId);

					INSERT INTO dbo.ClientNote(ClientId, NoteId)
					VALUES(@toClientId, SCOPE_IDENTITY());

					--Insert note for the 'From' client
					INSERT INTO dbo.Note (Note
										, DateCreated
										, CreatedByUserId)
								VALUES (@notes
										, GETDATE()
										, @requestedByUserId);

					INSERT INTO dbo.ClientNote(ClientId, NoteId)
					VALUES(@fromClientId, SCOPE_IDENTITY());
				END

				--Add course notes

				--For the 'From' course
				INSERT INTO dbo.CourseNote(CourseId
											, CourseNoteTypeId
											, Note
											, DateCreated
											, CreatedByUserId)

									VALUES (@fromCourseId
											, 1 --General 
											, @notes
											, GETDATE()
											, @requestedByUserId);

				--For the 'To' course
				INSERT INTO dbo.CourseNote(CourseId
											, CourseNoteTypeId
											, Note
											, DateCreated
											, CreatedByUserId)

									VALUES (@toCourseId
											, 1 --General 
											, @notes
											, GETDATE()
											, @requestedByUserId);
			END
		END

		ELSE
			BEGIN
				UPDATE dbo.CourseClientTransferRequest
				SET TransferRequestAccepted = 'True'
				WHERE TransferFromCourseId = @fromCourseId 
					AND TransferToCourseId = @toCourseId
					AND TransferRequestAccepted = 'False';
			END
	END	
END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP036_10.01_Create_uspCourseTransferClientWithNotes.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO