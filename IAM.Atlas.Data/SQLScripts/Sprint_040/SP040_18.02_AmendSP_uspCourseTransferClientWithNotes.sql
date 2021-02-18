/*
	SCRIPT: Amend uspCourseTransferClientWithNotes
	Author: Robert Newnham
	Created: 05/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_18.02_AmendSP_uspCourseTransferClientWithNotes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspCourseTransferClientWithNotes';
		
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
	CREATE PROCEDURE [dbo].[uspCourseTransferClientWithNotes] (@fromCourseId INT = -1
													, @toCourseId INT = -1
													, @fromClientId INT = -1
													, @toClientId INT = -1
													, @transferReason VARCHAR(100) = ''
													, @requestedByUserId INT = -1
													, @notes VARCHAR(1000) = '')
	AS

	BEGIN
		IF(@fromCourseId < 0) 
			OR (@toCourseId < 0)
			OR (@fromClientId < 0)
			OR (@toClientId < 0)
		BEGIN
			RAISERROR('@fromCourseId, @toCourseId, @fromClientId, @toClientId are all required parameters. Can not proceed.', 15, 1);
		END
		ELSE
		BEGIN

		DECLARE @requestAlreadyProcessedCheck INT, @rebookingFeeAmount MONEY;

		--Checks to see if a row on CourseClientTransferRequest exists
		-- if not, insert.
			IF(NOT EXISTS(SELECT * 
							FROM dbo.CourseClientTransferRequest
							WHERE TransferFromCourseId = @fromCourseId 
								AND TransferToCourseId = @toCourseId
								AND RequestedByClientId = @toClientId))
			BEGIN
			
				SELECT @rebookingFeeAmount = dbo.[udfCourseTodaysRebookingFee](@fromCourseId);
						
				INSERT INTO dbo.CourseClientTransferRequest (RequestedByClientId
															, DateTimeRequested
															, TransferFromCourseId
															, TransferToCourseId
															, RebookingFeeAmount)

													VALUES (@fromClientId
															, GETDATE()
															, @fromCourseId
															, @toCourseId
															, @rebookingFeeAmount);
			END


			SELECT @requestAlreadyProcessedCheck = Id 
			FROM dbo.CourseClientTransferred 
			WHERE TransferFromCourseId = @fromCourseId 
					AND TransferToCourseId = @toCourseId
					AND ClientId = @toClientId;

			IF(@requestAlreadyProcessedCheck IS NULL)
			BEGIN
				print @fromCourseId	
				print @toCourseId 
				print @fromClientId 
				print @toClientId 
				print @transferReason
				print @requestedByUserId

				EXEC dbo.uspCourseTransferClient @fromCourseId	
												, @toCourseId 
												, @fromClientId 
												, @toClientId 
												, @transferReason
												, @requestedByUserId;

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
					DECLARE @cnGeneralType INT = (SELECT TOP 1 Id FROM CourseNoteType WHERE Title = 'General');

					INSERT INTO dbo.CourseNote(CourseId
												, CourseNoteTypeId
												, Note
												, DateCreated
												, CreatedByUserId)

										VALUES (@fromCourseId
												, @cnGeneralType
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
												, @cnGeneralType
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
						AND RequestedByClientId = @toClientId
						AND TransferRequestAccepted = 'False';
				END
		END	
	END


	GO


	
DECLARE @ScriptName VARCHAR(100) = 'SP040_18.02_AmendSP_uspCourseTransferClientWithNotes.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO