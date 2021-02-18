
	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwCourseClientFeeAtTimeOfBooking', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwCourseClientFeeAtTimeOfBooking;
	END		
	GO

	/*
		Create View vwCourseClientFeeAtTimeOfBooking
	*/
	CREATE VIEW vwCourseClientFeeAtTimeOfBooking AS

		SELECT C.Id AS CourseId
				, CC.ClientId
				, MAX(CTF.CourseFee) AS CourseFee
		FROM Course C
		INNER JOIN dbo.CourseClient CC ON C.Id = CC.CourseId
		INNER JOIN dbo.ClientOrganisation CO ON CC.ClientId = CO.ClientId
		INNER JOIN dbo.CourseTypeFee CTF ON CO.OrganisationId = CTF.OrganisationId
											AND C.CourseTypeId = CTF.CourseTypeId
		WHERE CTF.EffectiveDate <= CC.DateAdded
		GROUP BY CC.ClientId, C.Id;

	GO

		/*****************************************************************************************************************/