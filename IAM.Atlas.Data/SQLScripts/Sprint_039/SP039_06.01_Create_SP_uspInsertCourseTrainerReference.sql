/*
	SCRIPT: Create uspInsertCourseTrainerReference
	Author: Dan Hough
	Created: 13/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_06.01_Create_SP_uspInsertCourseTrainerReference.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspInsertCourseTrainerReference';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspInsertCourseTrainerReference', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspInsertCourseTrainerReference;
END		
GO
	/*
		Create uspCancelOldUnprocessedRefundRequests
	*/

	CREATE PROCEDURE dbo.uspInsertCourseTrainerReference (@organisationId INT, @courseId INT, @trainerId INT)
	AS
	BEGIN
		DECLARE @trainersHaveCourseReference BIT
				, @reference VARCHAR(80)
				, @autoGenerateTrainerCourseReference BIT
				, @letAtlasSystemGenerateUniqueNumber BIT
				, @referencesStartWithCourseTypeCode BIT
				, @startAllReferencesWith VARCHAR(20)
				, @dateReference BIGINT = FORMAT(GETDATE(), 'yyyyMMddHHmmssffff')
				, @generatedReference VARCHAR(100)
				, @courseTypeCode VARCHAR(20)
				, @dateTime DATETIME
				, @dateTimeString VARCHAR(100)
				, @isNumberUnique BIT = 'False';

		SELECT @trainersHaveCourseReference = TrainersHaveCourseReference
		FROM dbo.OrganisationSelfConfiguration
		WHERE OrganisationId = @organisationId;

		IF ((@trainersHaveCourseReference = 'True') AND (@courseId > 0))
		BEGIN
			SELECT @reference = Reference
			FROM dbo.CourseTrainer
			WHERE TrainerId = @trainerId AND CourseId = @courseId;

			IF ((@reference IS NULL) OR (LEN(RTRIM(LTRIM(@reference))) = 0))
			BEGIN
				SELECT @autoGenerateTrainerCourseReference = AutoGenerateTrainerCourseReference
						, @letAtlasSystemGenerateUniqueNumber = LetAtlasSystemGenerateUniqueNumber
						, @referencesStartWithCourseTypeCode = ReferencesStartWithCourseTypeCode
						, @startAllReferencesWith = StartAllReferencesWith
				FROM dbo.OrganisationTrainerSetting
				WHERE OrganisationId = @organisationId;

				SELECT @courseTypeCode = Code
				FROM dbo.CourseType CT
				INNER JOIN dbo.Course C ON CT.Id = C.CourseTypeId
				WHERE C.Id = @courseId;

				SELECT @generatedReference = CAST(@dateReference AS VARCHAR);

				IF(@letAtlasSystemGenerateUniqueNumber = 'True')
				BEGIN
					WHILE (@isNumberUnique = 'False')
					BEGIN
						BEGIN TRY
							INSERT INTO dbo.UniqueCourseTrainerInterpreterReferenceNumber (ReferenceNumber)
							VALUES(@dateReference);

							SET @isNumberUnique = 'True';
						END TRY
						BEGIN CATCH
							SELECT @dateReference = FORMAT(GETDATE(), 'yyyyMMddHHmmssffff'); 
						END CATCH
					END

					IF(@referencesStartWithCourseTypeCode = 'True') AND ((@courseTypeCode IS NOT NULL) OR (LEN(LTRIM(RTRIM(@courseTypeCode))) > 0))
					BEGIN
						SET @generatedReference = ISNULL(@courseTypeCode, '') + CAST(@dateReference AS VARCHAR);
					END

					IF((@startAllReferencesWith IS NOT NULL) AND (LEN(LTRIM(RTRIM(@startAllReferencesWith))) > 0))
					BEGIN
						SET @generatedReference = ISNULL(@startAllReferencesWith, '') + CAST(@dateReference AS VARCHAR);
					END

				END

				UPDATE dbo.CourseTrainer
				SET Reference  = @generatedReference
				WHERE CourseId = @courseId AND TrainerId = @trainerId;

			END
		END
	END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP039_06.01_Create_SP_uspInsertCourseTrainerReference.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO