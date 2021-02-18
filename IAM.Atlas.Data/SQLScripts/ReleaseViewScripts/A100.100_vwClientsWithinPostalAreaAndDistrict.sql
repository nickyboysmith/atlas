


		--Clients Within PostalArea And District
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwClientsWithinPostalAreaAndDistrict', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwClientsWithinPostalAreaAndDistrict;
		END		
		GO
		/*
			Create vwClientsWithinPostalAreaAndDistrict
		*/
		CREATE VIEW vwClientsWithinPostalAreaAndDistrict 
		AS		
			SELECT ISNULL(CO.OrganisationId,-1)					AS OrganisationId
					, dbo.ufn_GetPostCodeArea(L.PostCode)		AS PostalArea			
					, dbo.ufn_GetPostCodeDistrict(L.PostCode)	AS PostalDistrict		
					, L.PostCode								AS PostCode
					, CL.Id										AS ClientId
					, (CASE WHEN CE.Id IS NOT NULL
							THEN '**Data Encrypted**'
							ELSE C.DisplayName END)				AS ClientName
					, C.DateOfBirth								AS ClientDateofBirth
					, G.[Name]									AS ClientGender					
			FROM  Client C
			INNER JOIN ClientOrganisation CO				ON CO.ClientId = C.Id
			INNER JOIN Gender G								ON C.GenderId = G.Id
			INNER JOIN ClientLocation CL					ON C.Id = CL.ClientId
			INNER JOIN dbo.[Location] L						ON L.Id = CL.LocationId
			LEFT JOIN ClientEncryption CE					ON CE.ClientId = C.Id							  										
		GO
		/*********************************************************************************************************************/
 