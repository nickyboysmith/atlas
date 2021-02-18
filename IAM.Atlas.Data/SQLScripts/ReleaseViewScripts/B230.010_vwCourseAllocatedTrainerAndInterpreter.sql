/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwCourseAllocatedTrainerAndInterpreter', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwCourseAllocatedTrainerAndInterpreter;
END		
GO
/*
	Create vwCourseAllocatedTrainerAndInterpreter
*/
CREATE VIEW dbo.vwCourseAllocatedTrainerAndInterpreter
AS
	SELECT 
		OrganisationId
		, CourseId
		, CourseType
		, CourseTypeId
		, CourseTypeCategoryId
		, CourseTypeCategory
		, CourseReference
		, CourseStartDate
		, CourseEndDate
		, CourseCancelled
		, CourseVenueId
		, CourseVenueName
		, CAST('True' AS BIT)						AS IsTrainer
		, CAST('False' AS BIT)						AS IsInterpreter
		, TrainerId									AS TrainerOrInterpreterId
		, TrainerName								AS TrainerOrInterpreterName
		, TrainerGenderId							AS TrainerOrInterpreterGenderId
		, TrainerGender								AS TrainerOrInterpreterGender
		, 'Trainer: ' + TrainerName 
				+ (CASE WHEN ISNULL(TrainerDistanceToVenueInMilesRounded, -1) > 0
						THEN ' (' + CAST(TrainerDistanceToVenueInMilesRounded AS VARCHAR) + ' Miles from venue)'
						ELSE '' END)				AS TrainerOrInterpreterCourseDisplayName
	FROM vwCourseAllocatedTrainer
	UNION SELECT 
		OrganisationId
		, CourseId
		, CourseType
		, CourseTypeId
		, CourseTypeCategoryId
		, CourseTypeCategory
		, CourseReference
		, CourseStartDate
		, CourseEndDate
		, CourseCancelled
		, CourseVenueId
		, CourseVenueName
		, CAST('False' AS BIT)						AS IsTrainer
		, CAST('True' AS BIT)						AS IsInterpreter
		, InterpreterId								AS TrainerOrInterpreterId
		, InterpreterName							AS TrainerOrInterpreterName
		, InterpreterGenderId						AS TrainerOrInterpreterGenderId
		, InterpreterGender							AS TrainerOrInterpreterGender
		, 'Interpreter: ' + InterpreterName 
			+ ' (' + InterpreterLanguageList + ')'	AS TrainerOrInterpreterCourseDisplayName
	FROM vwCourseAllocatedInterpreter
	;
	

GO

/*********************************************************************************************************************/


