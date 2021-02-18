
			--INSERT INTO [dbo].[CourseVenue] (CourseId, VenueId, MaximumPlaces, ReservedPlaces, VenueLocaleId)
			--SELECT DISTINCT TOP 100
			--	CPI.CourseId					AS CourseId
			--	, V.Id							AS VenueId
			--	, OC.crs_places					AS MaximumPlaces
			--	, OC.[crs_placesAutoReserved]	AS ReservedPlaces
			--	, VL.Id							AS VenueLocaleId
			--FROM [migration].[tbl_Course] OC
			--INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = OC.[crs_ID]
			--INNER JOIN [migration].[tbl_Organisation_CourseTypes] OCT ON OCT.[orct_ct_id] = OC.[crs_ct_id]
			--INNER JOIN [migration].[tbl_LU_Organisation] OO ON OO.[org_id] = OCT.[orct_org_id]
			--INNER JOIN dbo.Organisation NewO ON NewO.Name = OO.[org_name]
			--INNER JOIN migration.tbl_LU_Venue OldV ON OldV.vnu_ID = OC.crs_vnu_ID
			--INNER JOIN dbo.Venue V ON V.Title = OldV.vnu_description
			--						AND V.OrganisationId = NewO.Id
			--LEFT JOIN dbo.VenueLocale VL ON VL.VenueId = V.Id
			--LEFT JOIN [dbo].[CourseVenue] CV ON CV.CourseId = CPI.CourseId
			--								AND CV.VenueId = V.Id
			--WHERE CV.Id IS NULL; --Not Already Inserted



			INSERT INTO [dbo].[CourseVenue] (CourseId, VenueId, MaximumPlaces, ReservedPlaces, VenueLocaleId)
			SELECT DISTINCT 
				CPI.CourseId						AS CourseId
				, V.Id								AS VenueId
				, OldCV.crs_places					AS MaximumPlaces
				, OldCV.[crs_placesAutoReserved]	AS ReservedPlaces
				, VL.Id								AS VenueLocaleId
			FROM [migration].[vwRobsMigrationView_CourseVenue] OldCV
			INNER JOIN dbo.CoursePreviousId CPI ON CPI.PreviousCourseId = OldCV.[crs_ID]
			INNER JOIN dbo.Organisation NewO ON NewO.Name = OldCV.[org_name]
			INNER JOIN dbo.Venue V ON V.Title = OldCV.vnu_description
									AND V.OrganisationId = NewO.Id
			LEFT JOIN dbo.VenueLocale VL ON VL.VenueId = V.Id
			LEFT JOIN [dbo].[CourseVenue] CV ON CV.CourseId = CPI.CourseId
											AND CV.VenueId = V.Id
			WHERE CV.Id IS NULL; --Not Already Inserted