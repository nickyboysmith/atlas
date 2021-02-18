/*
	SCRIPT: Create stored procedure uspCourseTransferClient
	Author: Dan Hough 
	Created: 15/12/2016

*/

DECLARE @ScriptName VARCHAR(100) = 'SP030_23.01_Amend_uspCourseTransferClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create stored procedure uspCourseTransferClient';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCourseTransferClient', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCourseTransferClient;
END		
GO

/*
	Create uspCourseTransferClient
*/
CREATE PROCEDURE [dbo].[uspCourseTransferClient] (@fromCourseId INT
												, @toCourseId INT
												, @fromClientId INT
												, @toClientId INT
												, @transferReason VARCHAR(100)
												, @requestedByUserId INT)
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
		DECLARE @isDORSCourse BIT
				, @prevCourseTotalPaymentDue MONEY
				, @rebookingFee MONEY
				, @newTotalPaymentDue MONEY
				, @paymentId INT
				, @noteId INT
				, @fromClientName VARCHAR(640)
				, @dorsAttendanceRef INT
				, @DORSAttendanceStateIdentifier INT
				, @paidInFull BIT
				, @onlyPartPaymentMade BIT
				, @datePaidInFull DATETIME
				, @requestAlreadyProcessedCheck INT;

		--This checks to see if the request has already been 
		-- received and processed. If hasn't proceed. If it has
		-- skip to end and just update the row as 'request accepted'
		SELECT @requestAlreadyProcessedCheck = Id 
		FROM dbo.CourseClientTransferred 
		WHERE TransferFromCourseId = @fromCourseId 
				AND TransferToCourseId = @toCourseId
				AND ClientId = @toClientId;

		IF(@requestAlreadyProcessedCheck IS NULL)
		BEGIN
			-- Grab the 'from' client's name for use in later insert
			SELECT @fromClientName = DisplayName
			FROM dbo.Client
			WHERE Id = @fromClientId;

	
			--Get system user id if @requestedByUserId is null
			IF(@requestedByUserId IS NULL)
			BEGIN
				SET @requestedByUserId = dbo.udfGetSystemUserId();
			END

			--Checks the @fromCourseId to see if it's a DORS course 
			SELECT @isDORSCourse = DORSCourse
			FROM dbo.Course
			WHERE Id = @fromCourseId;

			--If it's a DORS course then update TransferredToCourseId in dbo.CourseDORSClient
			--and insert a new row into CourseDORSClient with 'to' course information
			IF(@isDORSCourse = 'True')
			BEGIN
				UPDATE dbo.CourseDORSClient
				SET TransferredToCourseId = @toCourseId
				WHERE CourseId = @fromCourseId AND ClientId = @fromClientId;

				SELECT @dorsAttendanceRef = DORSAttendanceRef
						, @DORSAttendanceStateIdentifier = DORSAttendanceStateIdentifier
						, @paidInFull = PaidInFull
						, @onlyPartPaymentMade = OnlyPartPaymentMade
						, @datePaidInFull = DatePaidInFull
				FROM dbo.CourseDORSClient
				WHERE CourseId = @fromCourseId AND ClientId = @fromClientId;

				INSERT INTO dbo.CourseDORSClient( CourseId
												, ClientId
												, DateAdded
												, DORSNotified
												, DORSAttendanceRef
												, DORSAttendanceStateIdentifier
												, NumberOfDORSNotificationAttempts
												, PaidInFull
												, OnlyPartPaymentMade
												, TransferredFromCourseId)

										VALUES( @toCourseId
												, @toClientId
												, GETDATE()
												, 'False'
												, @dorsAttendanceRef
												, @DORSAttendanceStateIdentifier
												, 0
												, @paidInFull
												, @onlyPartPaymentMade
												, @fromCourseId);
			END

			--Insert information in to dbo.CourseClientTransferred
			INSERT INTO dbo.CourseClientTransferred( TransferFromCourseId
													, TransferToCourseId
													, ClientId
													, DateTransferred
													, TransferredByUserId
													, Reason)

											VALUES  ( @fromCourseId
													, @toCourseId
													, @toClientId ----Rob anticipates that this SP will be used for moving same client around.
													, GETDATE()
													, @requestedByUserId
													, @transferReason);
	
			INSERT INTO dbo.CourseClientRemoved( CourseId
												, ClientId
												, DateRemoved
												, RemovedByUserId
												, Reason
												, DORSOfferWithdrawn)

										VALUES(   @fromCourseId
												, @fromClientId
												, GETDATE()
												, @requestedByUserId
												, @transferReason
												, NULL);

			SELECT @prevCourseTotalPaymentDue = TotalPaymentDue
			FROM dbo.CourseClient 
			WHERE CourseId = @fromCourseId AND ClientId = @fromClientId;

			SELECT @rebookingFee = RebookingFeeAmount
			FROM dbo.CourseClientTransferRequest
			WHERE TransferFromCourseId = @fromCourseId AND TransferToCourseId = @toCourseId;

			SET @newTotalPaymentDue = ISNULL(@prevCourseTotalPaymentDue, 0) + ISNULL(@rebookingFee, 0);

			INSERT INTO dbo.CourseClient(CourseId
										, ClientId
										, DateAdded
										, AddedByUserId
										, TotalPaymentDue
										, EmailReminderSent
										, SMSReminderSent)

								VALUES (@toCourseId
										, @toClientId
										, GETDATE()
										, @requestedByUserId
										, @newTotalPaymentDue
										, 'False'
										, 'False');

			SELECT @paymentId = PaymentId
			FROM dbo.CourseClientPayment
			WHERE CourseId = @fromCourseId AND ClientId = @fromClientId;

			--If a paymentId is found, then update CourseClientPayment
			--and insert a new row in to CourseClientPaymentTransfer
			IF(@paymentId IS NOT NULL)
			BEGIN
				UPDATE dbo.CourseClientPayment
				SET CourseId = @toCourseId, TransferredFromCourseId = @fromCourseId
				WHERE CourseId = @fromCourseId AND ClientId = @fromClientId;
				
				INSERT INTO dbo.CourseClientPaymentTransfer(TransferDate
															, FromCourseId
															, FromClientId
															, ToCourseId
															, ToClientId
															, PaymentId
															, CreatedByUserId)
													VALUES (GETDATE()
															, @fromCourseId
															, @fromClientId
															, @toCourseId
															, @toClientId
															, @paymentId
															, @requestedByUserId);
			END

			UPDATE dbo.CourseClientTransferRequest
			SET ToCourseBooked = 'True'
				, FromCourseUnbooked = 'True'
				, TransferRequestAccepted = 'True'
			WHERE TransferFromCourseId = @fromCourseId AND TransferToCourseId = @toCourseId;

			IF(@fromClientId = @toClientId)
			BEGIN
				INSERT INTO dbo.Note (Note
									, DateCreated
									, CreatedByUserId)
							VALUES ('Transferred from Course Id: ' + CAST(@fromCourseId AS VARCHAR) + ' to Course Id: ' + CAST(@toCourseId AS VARCHAR)
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
							VALUES ('Transferred into Course Id: ' + CAST(@toCourseId AS VARCHAR) 
										+ ' replacing Client: ' + @fromClientName + ' on Course Id: ' + CAST(@toCourseId AS VARCHAR)
									, GETDATE()
									, @requestedByUserId);

				INSERT INTO dbo.ClientNote(ClientId, NoteId)
				VALUES(@toClientId, SCOPE_IDENTITY());

				--Insert note for the 'From' client
				INSERT INTO dbo.Note (Note
									, DateCreated
									, CreatedByUserId)
							VALUES ('Transferred out of Course Id: ' + @toCourseId
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
										, 'Client Name: ' + @fromClientName + ', Id: ' + CAST(@fromClientId AS VARCHAR) 
											+ ' - transferred out of this course on to Course Id: ' + CAST(@toCourseId AS VARCHAR)
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
										, 'Client Name: ' + @fromClientName + ', Id: ' + CAST(@fromClientId AS VARCHAR) 
											+ ' - transferred into this course from course Id: ' + CAST(@fromCourseId  AS VARCHAR)
										, GETDATE()
										, @requestedByUserId);
		END --If request already processed checked
		ELSE
		BEGIN
			UPDATE dbo.CourseClientTransferRequest
			SET TransferRequestAccepted = 'True'
			WHERE TransferFromCourseId = @fromCourseId AND TransferToCourseId = @toCourseId;
		END

	END --if input params are null check
END

GO

DECLARE @ScriptName VARCHAR(100) = 'SP030_23.01_Amend_uspCourseTransferClient.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO