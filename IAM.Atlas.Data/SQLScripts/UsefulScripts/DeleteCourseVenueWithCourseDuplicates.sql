

PRINT 'BACKUP';
SELECT *
INTO #BackCV
FROM CourseVenue;


PRINT 'GET BAD COURSES';
SELECT CourseId, COUNT(*) AS HowMany
INTO #BadCourses
FROM CourseVenue
GROUP BY CourseId
HAVING COUNT(*) > 1 

DECLARE @counter INT = 1;
DECLARE @rows INT = (SELECT COUNT(*) FROM #BadCourses);
DECLARE @prevCourseId  INT = -1;
DECLARE @nextCourseId  INT = -1;
DECLARE @notDeleteId  INT = -1;

PRINT 'ALTER BAD COURSES TABLE';
	ALTER TABLE #BadCourses
	ADD Id INT IDENTITY(1,1) PRIMARY KEY;
	
PRINT 'DO IT....';
		WHILE (@counter <= @rows)
		BEGIN

			SELECT @nextCourseId = CourseId
			FROM #BadCourses 
			WHERE Id = @counter;

			IF (@nextCourseId != @prevCourseId)
			BEGIN
				SELECT TOP 1 @notDeleteId=Id
				FROM CourseVenue
				WHERE CourseId = @nextCourseId;

				DELETE CourseVenue
				WHERE CourseId = @nextCourseId
				AND ID != @notDeleteId;

				PRINT 'DELETE: ' + CAST(@nextCourseId AS VARCHAR);
			END

			SET @prevCourseId = @nextCourseId;
			SET @counter = @counter + 1;
		END
