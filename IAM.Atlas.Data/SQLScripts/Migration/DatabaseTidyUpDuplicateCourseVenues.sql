
		--/*
		IF OBJECT_ID('tempdb..#TidyUpVenue', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #TidyUpVenue;
		END
		IF OBJECT_ID('tempdb..#VenuesToDelete', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #VenuesToDelete;
		END
		--*/
		
		--SELECT V.OrganisationId, V.Title, COUNT(*) AS CNT
		--FROM [dbo].[Venue] V
		--GROUP BY V.OrganisationId, V.Title
		--HAVING COUNT(*) > 1
		
		PRINT('');PRINT('*CREATE #TidyUpVenue');
		SELECT DISTINCT TUV.OrganisationId, TUV.Title
		INTO #TidyUpVenue
		FROM (
			SELECT V.OrganisationId, V.Title, COUNT(*) AS CNT
			FROM [dbo].[Venue] V
			GROUP BY V.OrganisationId, V.Title
			HAVING COUNT(*) > 1
			) TUV
		
		PRINT('');PRINT('*CREATE #VenuesToDelete');
		SELECT TUV.OrganisationId, TUV.Title, V.Id AS VenueId
		INTO #VenuesToDelete
		FROM #TidyUpVenue TUV
		INNER JOIN [dbo].[Venue] V ON V.OrganisationId = TUV.OrganisationId
									AND V.Title = TUV.Title
		WHERE V.Id NOT IN (SELECT TOP 1 V2.Id
							FROM [dbo].[Venue] V2
							WHERE V2.OrganisationId = TUV.OrganisationId
							AND V2.Title = TUV.Title) 

		PRINT('');PRINT('*DELETE CourseVenue');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN CourseVenue D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueAddress');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueAddress D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueCost');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueCost D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueCourseType');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueCourseType D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueDirections');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueDirections D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueEmail');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueEmail D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueImageMap');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueImageMap D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueLocale');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueLocale D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE VenueRegion');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN VenueRegion D ON D.VenueId = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE Venue');
		DELETE D
		FROM #VenuesToDelete VTD
		INNER JOIN Venue D ON D.Id = VTD.VenueId
		WHERE VTD.VenueId IS NOT NULL
		
		PRINT('');PRINT('*DELETE Duplicate/Invalid Coursees In CourseVenue');
		--SELECT CV.*
		DELETE CV
		FROM CourseVenue CV
		INNER JOIN Course C ON C.Id = CV.CourseId
		LEFT JOIN Venue V ON V.Id = CV.Id
							AND V.OrganisationId = C.OrganisationId
		WHERE V.Id IS NULL