
		--Course Client Details
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwCourseClientsWithoutEmail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwCourseClientsWithoutEmail;
		END		
		GO
		/*
			Create vwCourseClientsWithoutEmail
		*/
		CREATE VIEW vwCourseClientsWithoutEmail 
		AS
			SELECT			
				ISNULL(C.OrganisationId,0)			AS OrganisationId
				, ISNULL(C.Id,0)					AS CourseId
				, CT.Title							AS CourseType
				, CT.Id								AS CourseTypeId
				, CTC.Id							AS CourseTypeCategoryId
				, CTC.Name							AS CourseTypeCategory
				, C.Reference						AS CourseReference
				, CD.StartDate						AS CourseStartDate
				, CD.EndDate						AS CourseEndDate
				, CL.Id								AS ClientId
				, (CASE WHEN CE.Id IS NOT NULL
						THEN '**Data Encrypted**'
						ELSE 
							(CASE WHEN CL.DisplayName IS NULL 
								THEN LTRIM(RTRIM(
										ISNULL(CL.Title,'') 
										+ ' ' + ISNULL(CL.FirstName,'') 
										+ ' ' + ISNULL(CL.Surname,'')
										))
								ELSE CL.DisplayName END)
						END)						AS ClientName
				, CLI.LicenceNumber					AS ClientLicenceNumber
				, CL.[GenderId]						AS ClientGenderId
				, G.[Name]							AS ClientGender
				, L.[Address]						AS ClientAddress
				, L.PostCode						AS CientPostCode
				, CP.ClientMainPhoneNumber			AS ClientMainPhoneNumber
				, CP.ClientMainPhoneTypeId			AS ClientMainPhoneTypeId
				, CP.ClientMainPhoneType			AS ClientMainPhoneType
				, CP.ClientSecondPhoneNumber		AS ClientSecondPhoneNumber
				, CP.ClientSecondPhoneTypeId		AS ClientSecondPhoneTypeId
				, CP.ClientSecondPhoneType			AS ClientSecondPhoneType
				, CL.DateOfBirth					AS ClientDateOfBirth
			FROM Course C
			INNER JOIN dbo.vwCourseDates_SubView CD		ON CD.CourseId = C.id
			INNER JOIN CourseType CT					ON CT.Id = C.CourseTypeId
			INNER JOIN [dbo].[CourseClient] CCL			ON CCL.CourseId = C.Id
			INNER JOIN [dbo].[Client] CL				ON CL.Id = CCL.ClientId
			INNER JOIN [dbo].[Gender] G					ON G.Id = CL.[GenderId]
			LEFT JOIN [dbo].[CourseClientRemoved] CCR	ON CCR.CourseClientId = CCL.Id
			LEFT JOIN CourseTypeCategory CTC			ON CTC.Id = C.CourseTypeCategoryId
			LEFT JOIN ClientEncryption CE				ON CE.ClientId = CL.Id
			LEFT JOIN ClientEmail CEM					ON CEM.ClientId = CL.Id
			LEFT JOIN Email E							ON E.Id = CEM.EmailId
			LEFT JOIN ClientLocation CLO				ON CLO.ClientId = CL.Id
			LEFT JOIN Location L						ON L.Id = CLO.LocationId
			LEFT JOIN ClientLicence CLI					ON CLI.ClientId = CL.Id
			LEFT JOIN vwClientPhoneRow CP				ON CP.ClientId = CL.Id
			WHERE CCR.Id IS NULL
			AND (CEM.Id IS NULL
				OR E.Id IS NULL
				OR dbo.udfIsEmailAddressValid(E.Address) = 'False'
				)
			;
		GO
		/*********************************************************************************************************************/
		