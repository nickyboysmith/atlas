/*
	SCRIPT: Add insert trigger to the CourseDate table to calculate the last booking date
	Author: Dan Murray
	Created: 20/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_25.01_AddInsertTriggerToCourseDateTableToUpdateLastBookingDate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the CourseDate table to calculate the last booking date';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_CourseDateTableCalculateLastBookingDate_INSERT];
		END
GO
		CREATE TRIGGER TRG_CourseDateTableCalculateLastBookingDate_INSERT ON CourseDate FOR INSERT
AS
		DECLARE @TheCourseStartDate DATETIME;
				DECLARE @DaysToAdd int;
				SET @DaysToAdd = 1;

				IF EXISTS(SELECT * 
						  FROM inserted i
						  INNER JOIN dbo.Course iC
						  ON iC.Id = i.CourseId 
						  WHERE iC.LastBookingDate IS NULL)
				BEGIN
					--Get The Earliest Course Start Date
					SELECT @TheCourseStartDate=MIN(CD.DateStart)
					FROM inserted i
					INNER JOIN [dbo].[Course] C ON C.Id = i.CourseId /* The Difference */
					INNER JOIN [dbo].[CourseDate] CD ON CD.CourseId = i.CourseId;

					--Get The Days to Add
					SELECT @DaysToAdd=CTC.DaysBeforeCourseLastBooking
					FROM inserted i
					INNER JOIN [dbo].[Course] C ON C.Id = i.CourseId /* The Difference */
					INNER JOIN [dbo].[CourseTypeCategory] CTC ON CTC.Id = C.[CourseTypeCategoryId];

					SET @TheCourseStartDate = DATEADD(d, @DaysToAdd, @TheCourseStartDate);

					UPDATE C
					SET C.LastBookingDate = @TheCourseStartDate
					FROM inserted i
					INNER JOIN dbo.Course C ON C.Id = i.Id;
				END
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP023_25.01_AddInsertTriggerToCourseDateTableToUpdateLastBookingDate.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO

