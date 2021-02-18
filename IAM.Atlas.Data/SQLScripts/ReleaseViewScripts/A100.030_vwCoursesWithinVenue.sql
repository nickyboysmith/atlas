
		--Courses within Venue

		/*
			Drop the View if it already exists
		*/		
		IF OBJECT_ID('dbo.vwCoursesWithinVenue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCoursesWithinVenue;
		END		
		GO
		/*
			Create vwCoursesWithinVenue
		*/
		CREATE VIEW vwCoursesWithinVenue AS
		
			SELECT v.Id								AS VenueId
				, v.Title							AS VenueName
				, ct.Title							AS VenueCourseType    --Venue Course Type === Course Type?
				, CV.CourseId						AS CourseId
				, cd.StartDate						AS CourseStartDate
				, c.Reference						AS CourseReference
				, ct.Title							AS CourseType
				, ctc.Name							AS CourseTypeCategory
				, CLAES.CourseLocked				AS CourseLocked
				, CLAES.CourseProfileUneditable		AS CourseProfileUneditable
					
			FROM CourseVenue cv
			INNER JOIN Venue v ON cv.VenueId = v.Id
			INNER JOIN Course c ON c.id = cv.CourseId				  
			LEFT JOIN dbo.vwCourseDates_SubView CD				ON CD.CourseId = C.id
			LEFT JOIN CourseType ct ON ct.Id = c.CourseTypeId
			LEFT JOIN CourseTypeCategory ctc ON ctc.Id = c.CourseTypeCategoryId	
			LEFT JOIN dbo.vwCourseLockAndEditState CLAES		ON CLAES.CourseId = C.Id					
		GO
		/*********************************************************************************************************************/
