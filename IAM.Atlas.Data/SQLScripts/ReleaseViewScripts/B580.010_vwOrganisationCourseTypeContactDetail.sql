/*********************************************************************************************************************/

		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwOrganisationCourseTypeContactDetail', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwOrganisationCourseTypeContactDetail;
		END		
		GO
		/*
			Create vwOrganisationCourseTypeContactDetail
		*/
		CREATE VIEW vwOrganisationCourseTypeContactDetail 
		AS
			SELECT 
				O.Id								AS OrganisationId
			, O.[Name]								AS OrganisationName
			, OCCT.SameAsDefault					AS UsingDefault
			, CT.Id									AS CourseTypeId
			, CT.Title								AS CourseType
			, CT.DORSOnly							AS DORSCourseType
			, DS.DORSSchemeIdentifier				AS DORSSchemeIdentifier
			, CASE WHEN OCCT.SameAsDefault = 'True'
				THEN L.[Address]
				ELSE L2.[Address]
				END									AS PostalAddress
			, CASE WHEN OCCT.SameAsDefault = 'True'
				THEN L.PostCode
				ELSE L2.PostCode
				END									AS PostCode
			, CASE WHEN OCCT.SameAsDefault = 'True'
				THEN E.[Address]
				ELSE E2.[Address]
				END									AS EmailAddress
			, CASE WHEN OCCT.SameAsDefault = 'True'
				THEN OC.PhoneNumber
				ELSE OCCT.PhoneNumber
				END									AS PhoneNumber
			FROM dbo.OrganisationContactCourseType OCCT
			INNER JOIN dbo.Organisation O ON OCCT.OrganisationId = O.Id
			INNER JOIN dbo.CourseType CT ON OCCT.CourseTypeId = CT.Id
			LEFT JOIN dbo.DORSSchemeCourseType DSCT ON CT.Id = DSCT.CourseTypeId
			LEFT JOIN dbo.DORSScheme DS ON DSCT.DORSSchemeId = DS.Id
			LEFT JOIN dbo.OrganisationContact OC ON O.Id = OC.OrganisationId
			LEFT JOIN dbo.[Location] L ON OC.LocationId = L.Id
			LEFT JOIN dbo.[Location] L2 ON OCCT.LocationId = L2.Id
			LEFT JOIN dbo.Email E ON OC.EmailId = E.Id
			LEFT JOIN dbo.Email E2 ON OCCT.EmailId = E2.Id;
			
	GO

	/*********************************************************************************************************************/

