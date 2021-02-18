
		IF OBJECT_ID('dbo.vwRobsMigrationView_CourseVenue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwRobsMigrationView_CourseVenue;
		END		
		IF OBJECT_ID('migration.vwRobsMigrationView_CourseVenue', 'V') IS NOT NULL
		BEGIN
			DROP VIEW migration.vwRobsMigrationView_CourseVenue;
		END		
		GO

		/*
			Create View vwDashboardMeter_UserAccess
		*/
		CREATE VIEW migration.vwRobsMigrationView_CourseVenue
		AS
			SELECT DISTINCT
				OC.[crs_ID]
				, OC.[crs_ct_id]
				, OC.crs_places
				, OC.[crs_placesAutoReserved]
				, OC.crs_vnu_ID
				, OCT.[orct_org_id]
				, OO.[org_name]
				, OldV.vnu_description
			FROM [migration].[tbl_Course] OC
			INNER JOIN [migration].[tbl_Organisation_CourseTypes] OCT ON OCT.[orct_ct_id] = OC.[crs_ct_id]
			INNER JOIN [migration].[tbl_LU_Organisation] OO ON OO.[org_id] = OCT.[orct_org_id]
			INNER JOIN migration.tbl_LU_Venue OldV ON OldV.vnu_ID = OC.crs_vnu_ID
			;

			GO



			