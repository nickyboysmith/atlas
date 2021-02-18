/*
	SCRIPT: Create Single Course Quick Search Data Stored Procedure
	Author: Dan Murray
	Created: 02/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_07.01_Create_usp_RefreshSingleCourseQuickSearchData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to create Course quick-search data';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.usp_RefreshSingleCourseQuickSearchData', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_RefreshSingleCourseQuickSearchData;
END		
GO

/*
	Create usp_RefreshSingleCourseQuickSearchData
*/
CREATE PROCEDURE usp_RefreshSingleCourseQuickSearchData
(
	@courseId int
)
AS
BEGIN
	BEGIN TRAN
	DELETE FROM dbo.CourseQuickSearch
	WHERE Id = @courseId
	
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
	/*INSERT ENTRY FOR COURSE TABLE*/
	BEGIN TRAN
	INSERT INTO dbo.CourseQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 [Date],
			 OrganisationId,
			 CourseId
			)			
			SELECT 
					ct.Title,
					ct.Title + '(' + CONVERT(VARCHAR, cd.DateStart,106) + ')',
					cd.DateStart,
					c.OrganisationId,
					c.id
			
			FROM Course c
			LEFT JOIN CourseType ct
			ON c.CourseTypeId = ct.Id
			LEFT JOIN CourseDate cd
			ON cd.CourseId = c.Id
			WHERE c.Id = @courseId
				  AND cd.DateStart IS NOT NULL
				  AND ct.Title IS NOT NULL
			
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN

	/*INSERT ENTRY FOR COURSE DATE*/
	BEGIN TRAN
	INSERT INTO dbo.CourseQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 [Date],
			 OrganisationId,
			 CourseId
			)			
			SELECT 
					c.Reference,
					c.Reference + ' - ' + ct.Title + '(' + CONVERT(VARCHAR, cd.DateStart,106) + ')',
					cd.DateStart,
					c.OrganisationId,
					c.id
			
			FROM Course c
			LEFT JOIN CourseType ct
			ON c.CourseTypeId = ct.Id
			LEFT JOIN CourseDate cd
			ON cd.CourseId = c.Id
			WHERE c.Id = @courseId
				  AND cd.DateStart IS NOT NULL
				  AND ct.Title IS NOT NULL
				  AND c.Reference IS NOT NULL
			
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN

	/*INSERT ENTRY FOR COURSETYPE, COURSECATEGORY AND COURSEDATE*/
	BEGIN TRAN
	INSERT INTO dbo.CourseQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 [Date],
			 OrganisationId,
			 CourseId
			)			
			SELECT 
					ctc.Name,
					ct.Title + ' - ' + ctc.Name + '(' + CONVERT(VARCHAR, cd.DateStart,106) + ')',
					cd.DateStart,
					c.OrganisationId,
					c.id
			
			FROM Course c
			LEFT JOIN CourseType ct
			ON c.CourseTypeId = ct.Id
			LEFT JOIN CourseDate cd
			ON cd.CourseId = c.Id
			LEFT JOIN CourseTypeCategory ctc
			ON ctc.CourseTypeId = ct.Id
			WHERE c.Id = @courseId
				  AND cd.DateStart IS NOT NULL
				  AND ct.Title IS NOT NULL
				  AND ctc.Name  IS NOT NULL
			
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN



	/*INSERT ENTRY FOR COURSETYPE, COURSETRAINER, TRAINER AND COURSEDATE*/
	BEGIN TRAN
	INSERT INTO dbo.CourseQuickSearch
			(
			 SearchContent,
			 DisplayContent,
			 [Date],
			 OrganisationId,
			 CourseId
			)			
			SELECT 
					t.DisplayName,
					t.DisplayName + ' - ' + ct.Title + '(' + CONVERT(VARCHAR, cd.DateStart,106) + ')',
					cd.DateStart,
					c.OrganisationId,
					c.id
			
			FROM Course c
			LEFT JOIN CourseType ct
			ON c.CourseTypeId = ct.Id
			LEFT JOIN CourseDate cd
			ON cd.CourseId = c.Id
			LEFT JOIN CourseTrainer ctr
			ON ctr.CourseId = c.Id
			LEFT JOIN Trainer t
			ON ctr.TrainerId = t.Id
			WHERE c.Id = @courseId
				  AND cd.DateStart IS NOT NULL
				  AND ct.Title IS NOT NULL
				  AND t.DisplayName  IS NOT NULL
			

			--CourseType", "CourseTrainer", "Trainer", "CourseDate
			IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
END
/***END OF SCRIPT***/

/*LOG SCRIPT COMPLETED*/
DECLARE @ScriptName VARCHAR(100) = 'SP011_07.01_Create_usp_RefreshSingleCourseQuickSearchData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO
	


