/*
	SCRIPT: Amend Insert trigger on CourseType
	Author: Dan Hough
	Created: 10/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_23.01_AmendInsertTriggerOnCourseType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Insert Trigger on CourseType';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.TRG_CourseType_Insert', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER TRG_CourseType_Insert;
	END

	GO

	CREATE TRIGGER TRG_CourseType_Insert ON dbo.CourseType AFTER INSERT
	AS
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'CourseType', 'TRG_CourseType_Insert', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
				DECLARE @courseTypeId INT
						  , @title VARCHAR(200)
						  , @code VARCHAR(20)
						  , @description VARCHAR(1000)
						  , @organisationId INT
						  , @disabled BIT
						  , @dorsOnly BIT
						  , @userId INT;

					SELECT @courseTypeId = Id
						 , @title = Title
						 , @code = Code
						 , @description = [Description]
						 , @organisationId = OrganisationId
						 , @disabled = [Disabled]
						 , @dorsOnly = DORSOnly
					FROM Inserted i;

					INSERT INTO dbo.CourseTypeFee(OrganisationId
												, CourseTypeId
												, EffectiveDate 
												, CourseFee
												, BookingSupplement
												, PaymentDays
												, AddedByUserId
												, DateAdded
												, [Disabled])

									VALUES(@organisationId
										 , @courseTypeId
										 , GETDATE()
										 , 0
										 , 0
										 , 0
										 , dbo.udfGetSystemUserId()
										 , GETDATE()
										 , 0);

				INSERT INTO [dbo].[OrganisationContactCourseType] (OrganisationId, CourseTypeId, SameAsDefault)
				VALUES(@organisationId, @courseTypeId, 'True'); --True is the default value upon insertion on this table.
	
		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP040_23.01_AmendInsertTriggerOnCourseType.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

