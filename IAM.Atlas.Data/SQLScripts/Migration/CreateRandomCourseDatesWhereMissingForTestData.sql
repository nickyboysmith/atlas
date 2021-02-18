


/* INSERT Randon Course Dates into Courses where missing */
INSERT INTO CourseDate (
	CourseId
	, DateStart
	, DateEnd
	, Available
	, CreatedByUserId
	, DateUpdated
	, AttendanceUpdated
	, AttendanceVerified
	)
SELECT 
	CourseId
	, DateStart
	, DATEADD(HOUR, +4
				, DateStart
				)		AS DateEnd
	, Available
	, CreatedByUserId
	, DateUpdated
	, AttendanceUpdated
	, AttendanceVerified
FROM (
		SELECT 
			C.Id								AS CourseId
			, DATEADD(HOUR, -4
						, (GETDATE() + ABS(Checksum(NewID()) % 105) + 10)
						)						AS DateStart /* Create Randon Course Dates between 10 and 105 days from now. .... Subtracted 4 as the time was at 5pm */
			, NULL								AS DateEnd
			, 'True'							AS Available
			, dbo.udfGetSystemUserId()			AS CreatedByUserId
			, GETDATE()							AS DateUpdated
			, 'False'							AS AttendanceUpdated
			, 'False'							AS AttendanceVerified
		FROM Course C
		LEFT JOIN CourseDate CD ON CD.CourseId = C.Id
		WHERE CD.Id IS NULL
	) AS CDS

