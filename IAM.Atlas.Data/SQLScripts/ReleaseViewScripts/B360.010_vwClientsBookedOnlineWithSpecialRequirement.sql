
--vwClientsBookedOnlineWithSpecialRequirement
/*
	Drop the View if it already exists
*/
IF OBJECT_ID('dbo.vwClientsBookedOnlineWithSpecialRequirement', 'V') IS NOT NULL
BEGIN
	DROP VIEW dbo.vwClientsBookedOnlineWithSpecialRequirement;
END		
GO
/*
	Create vwClientsBookedOnlineWithSpecialRequirement
*/
CREATE VIEW vwClientsBookedOnlineWithSpecialRequirement
AS
	
	SELECT	c.Id				AS ClientId,
		c.DisplayName			AS ClientName,
		c.DateOfBirth			AS DateOfBirth,
		cp.PhoneNumber			AS PhoneNumber, 
		CLI.LicenceNumber		AS LicenceNumber,
		course.id				AS CourseId,
		cd.startdate			AS coursestartdate,
		CD.EndDate				AS CourseEndDate,
		Course.CourseTypeId		AS CourseTypeId, 
		CT.Title				AS CourseTypeTitle,
		course.organisationid	AS OrganisationId,
		(CASE WHEN CAST(C.[DateCreated] AS DATE) = CAST((Getdate()) AS DATE)
							THEN 1 ELSE 0 END) AS RegisteredOnlineToday
	FROM client c
	INNER JOIN [ClientOnlineBookingState] cobs ON cobs.clientid = c.id
	INNER JOIN Course ON cobs.courseid = course.id
	INNER JOIN [ClientSpecialRequirement] csr ON csr.clientid = c.id
	INNER JOIN vwCourseDates_SubView cd ON course.id = cd.courseid
	INNER JOIN CourseType CT ON CT.Id = Course.CourseTypeId
	LEFT JOIN ClientLicence CLI ON CLI.ClientId = c.Id
	LEFT JOIN clientPhone cp ON  CP.ClientId = c.Id
								 AND CP.DefaultNumber = 'True'
	WHERE cd.startdate > getdate()
	AND cobs.coursebooked = 'true' 
	AND cobs.FullPaymentRecieved = 'true';

GO


/*********************************************************************************************************************/
