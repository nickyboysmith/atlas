/*
	SCRIPT: Amend Insert & Update trigger on table CourseDate for CourseSessionAllocation
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_34.02_AmendInsertUpdateTriggerOnCourseDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert & Update trigger on table CourseDate for CourseSessionAllocation';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_CourseDate_InsertUpdate_CourseSessionAllocation', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDate_InsertUpdate_CourseSessionAllocation;
	END
GO

--Rename The Trigger
IF OBJECT_ID('dbo.TRG_CourseDate_InsertUpdate', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.TRG_CourseDate_InsertUpdate;
	END
GO
	CREATE TRIGGER TRG_CourseDate_InsertUpdate ON dbo.CourseDate AFTER INSERT, UPDATE
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseDate', 'TRG_CourseDate_InsertUpdate', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			DECLARE @CourseId INT = -1;

			--NB. There is Always an Insert with Updates and Inserts. Hence the following correction.
			--SELECT @CourseId = ISNULL(I.CourseId, D.CourseId)
			--FROM INSERTED I
			--FULL JOIN DELETED D ON D.Id = I.Id;

			--Yes I know it achieves the same result. This way is quicker.2
			--Min You this does not allow for Multiple Inserts. Let's hope ther are none ;-)
			SELECT @CourseId = I.CourseId
			FROM INSERTED I;
			
			IF (@CourseId >= 0)
			BEGIN
				--Course Session Allocation
				EXEC dbo.uspCourseSessionAllocationRefreshDefault @CourseId;

				--Ensure Last Booking Date is set
				EXEC dbo.uspCalculateLastBookingDate @CourseId;
			END
			
			BEGIN
				DECLARE @CourseDateReason VARCHAR(200) = 'Course Date Reached.'

				--If the Course Date has been Set then we know when the Course should be locked from.
				INSERT INTO [dbo].[CourseLocked] (CourseId, AfterDate, Reason, UpdatedByUserId)
				SELECT CD.CourseId							AS CourseId
					, CAST(MIN(CD.DateStart) AS DATE)		AS AfterDate --Ensure From Start of Day
					, @CourseDateReason						AS Reason
					, dbo.udfGetSystemUserId()				AS UpdatedByUserId
				FROM INSERTED I
				INNER JOIN dbo.CourseDate CD	ON CD.CourseId = I.CourseId -- We have to Allow for the Fact that there may be more than one date
				LEFT JOIN dbo.CourseLocked CL	ON CL.CourseId = I.CourseId
												AND CL.Reason = @CourseDateReason
				WHERE CL.Id IS NULL --Only Insert if not already there
				AND CD.DateStart IS NOT NULL
				GROUP BY CD.CourseId;
			
				--If Already There Check that it does not need Updating			
				UPDATE CL
				SET CL.AfterDate = NEW.AfterDate --This will Only Chenge if the Course Date has Changed.
				FROM INSERTED I
				INNER JOIN dbo.CourseLocked CL	ON CL.CourseId = I.CourseId
												AND CL.Reason = @CourseDateReason
				INNER JOIN (
							SELECT CD.CourseId							AS CourseId
								, CAST(MIN(CD.DateStart) AS DATE)		AS AfterDate --Ensure From Start of Day
							FROM INSERTED I
							INNER JOIN dbo.CourseDate CD	ON CD.CourseId = I.CourseId
							GROUP BY CD.CourseId
							) NEW				ON NEW.CourseId = I.CourseId
				WHERE CL.AfterDate != NEW.AfterDate;
			END

		END --END PROCESS

	END

	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_34.02_AmendInsertUpdateTriggerOnCourseDate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO