
		-- Dashboard Meter Data - DORS Offers Withdrawn
		/*
			Drop the View if it already exists
		*/
		IF OBJECT_ID('dbo.vwDashboardMeter_DORSOfferWithdrawn', 'V') IS NOT NULL
		BEGIN
			DROP VIEW dbo.vwDashboardMeter_DORSOfferWithdrawn;
		END		
		GO
		/*
			Create vwDashboardMeter_DORSOfferWithdrawn
		*/
		CREATE VIEW vwDashboardMeter_DORSOfferWithdrawn
		AS
			SELECT
				OrganisationId
				, OrganisationName
				, DateAndTimeRefreshed
				, TotalCreatedToday
				, TotalCreatedYesterday
				, TotalCreatedThisWeek
				, TotalCreatedThisMonth
				, TotalCreatedPreviousMonth
				, TotalCreatedTwoMonthsAgo
			FROM [dbo].[DashboardMeterData_DORSOfferWithdrawn] D
			;
			--SELECT ISNULL(OrganisationId,0)			AS OrganisationId
			--		, OrganisationName				AS OrganisationName
			--		, SUM(CASE WHEN CreatedToday = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedToday
			--		, SUM(CASE WHEN CreatedYesterday = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedYesterday
			--		, SUM(CASE WHEN CreatedThisWeek = 'True' THEN 1 ELSE 0 END)			AS TotalCreatedThisWeek
			--		, SUM(CASE WHEN CreatedThisMonth = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedThisMonth
			--		, SUM(CASE WHEN CreatedPreviousMonth = 'True' THEN 1 ELSE 0 END)	AS TotalCreatedPreviousMonth
			--		, SUM(CASE WHEN CreatedTwoMonthsAgo = 'True' THEN 1 ELSE 0 END)		AS TotalCreatedTwoMonthsAgo
			--FROM vwDORSOfferWithdrawn
			--GROUP BY ISNULL(OrganisationId,0), OrganisationName
			--;
		GO
		/*********************************************************************************************************************/
		