/*
	SCRIPT: Amend Insert trigger on CourseClientPayment
	Author: Robert Newnham
	Created: 16/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_02.01_AmendInsertTriggerOnCourseClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert trigger on CourseClientPayment';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseClientPayment_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClientPayment_Insert;
	END
GO
IF OBJECT_ID('dbo.TRG_CourseClientPayment_INSERT', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseClientPayment_INSERT;
	END
GO
	CREATE TRIGGER [dbo].[TRG_CourseClientPayment_INSERT] ON [dbo].[CourseClientPayment] AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0)
		BEGIN --START PROCESS
			EXEC uspLogTriggerRunning 'CourseClientPayment', 'TRG_CourseClientPayment_INSERT', @insertedRows, @deletedRows;
			------------------------------------------------------------------------------------------------
			
			--The Following Should already be there. This is a Just in case.......
			DECLARE @courseId INT = NULL
				, @clientId INT = NULL;
			SELECT @courseId = I.CourseId, @clientId = I.ClientId
			FROM INSERTED I;

			EXEC dbo.uspInsertCourseDORSClientDataIfMissing @courseId, @clientId;
			/****************************************************************************************************************/

			--Now Check the Total Amount Paid by the Client for the Course
			DECLARE @TotalAmountPaid MONEY;
			DECLARE @rowsUpdated INT = 0;

			SELECT @TotalAmountPaid = SUM(P.Amount)
			FROM INSERTED I
			INNER JOIN [dbo].[CourseClientPayment] CCP ON CCP.CourseId = I.CourseId
														AND CCP.ClientId = I.ClientId
			INNER JOIN [dbo].[Payment] P ON P.Id = CCP.PaymentId
			;

			UPDATE CDC
			SET CDC.[PaidInFull] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
										THEN 'True' ELSE 'False' END)
			, CDC.[DatePaidInFull] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
										THEN GETDATE() ELSE CDC.[DatePaidInFull] END)
			, CDC.[OnlyPartPaymentMade] = (CASE WHEN @TotalAmountPaid >= CC.TotalPaymentDue 
												THEN 'False' 
												ELSE (CASE WHEN @TotalAmountPaid > 0 THEN 'True' ELSE 'False' END)
												END)
			FROM [dbo].[CourseDORSClient] CDC
			INNER JOIN [dbo].[CourseClient] CC ON CC.[CourseId] = CDC.[CourseId]
												AND CC.[ClientId] = CDC.[ClientId]
			WHERE CDC.[CourseId] = @courseId
			AND CDC.[ClientId] = @clientId
			AND CDC.[PaidInFull] = 'False'
			;
			SET @rowsUpdated = @@rowcount;

			IF (@rowsUpdated > 0)
			BEGIN
				--This will trigger a new DORS Notification. But only if Fully Paid
				UPDATE CDC
				SET CDC.[DORSNotified] = 'False'
				, CDC.[DateDORSNotified] = NULL
				, CDC.[NumberOfDORSNotificationAttempts] = 0
				, CDC.[DateDORSNotificationAttempted] = NULL
				FROM [dbo].[CourseDORSClient] CDC
				INNER JOIN [dbo].[CourseClient] CC ON CC.[CourseId] = CDC.[CourseId]
													AND CC.[ClientId] = CDC.[ClientId]
				WHERE CDC.[CourseId] = @courseId
				AND CDC.[ClientId] = @clientId
				AND CDC.[PaidInFull] = 'True'
				;
				
			END

			/****************************************************************************************************************/
			
		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_02.01_AmendInsertTriggerOnCourseClientPayment.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO