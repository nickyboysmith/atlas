
	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwCourseClientAttended', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseClientAttended;
	END		
	GO

	/*
		Create View vwCourseClientFeeAtTimeOfBooking
	*/
	CREATE VIEW vwCourseClientAttended AS

	  SELECT CourseId, ClientId, CAST((CASE WHEN CourseDateCount = AttendanceCount THEN 'True' ELSE 'False' END) AS BIT) AS Attended
	  FROM
		  (SELECT CC.CourseId, CC.ClientId, COUNT(CD.Id) AS CourseDateCount, COUNT(CDCA.Id) AS AttendanceCount
		  FROM CourseClient CC
		  INNER JOIN CourseDate CD ON CC.CourseId = CD.CourseId
		  LEFT JOIN [CourseDateClientAttendance] CDCA ON CC.CourseId = CDCA.CourseId
														AND CC.ClientId = CDCA.ClientId
														AND CDCA.CourseDateId = CD.Id
		GROUP BY CC.CourseId, CC.ClientId) T;

	GO

		/*****************************************************************************************************************/