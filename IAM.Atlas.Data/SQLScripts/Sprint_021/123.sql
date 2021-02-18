/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.vwDashboardMeter_DocumentStats', 'V') IS NOT NULL
	BEGIN
		DROP VIEW dbo.vwDashboardMeter_DocumentStats;
	END		
	GO

	/*
		Create View vwDashboardMeter_DocumentStats
	*/
	CREATE VIEW vwDashboardMeter_DocumentStats AS	
	

WITH DocumentStats_CTE (OrganisationId, DateAdded, FileSize)
AS

	

	(	SELECT 
			o.Id AS OrganisationId
			, atd.DateAdded AS DateAdded
			, d.FileSize AS FileSize
		FROM
			Document d
			INNER JOIN AllTrainerDocument atd ON d.Id = atd.DocumentId
			INNER JOIN Organisation o ON o.Id = atd.OrganisationId
		UNION
		SELECT 
			o.Id AS OrganisationId
			, acd.DateAdded AS DateAdded
			, d.FileSize AS FileSize
		FROM
			Document d
			INNER JOIN AllCourseDocument acd ON d.Id = acd.DocumentId
			INNER JOIN Organisation o ON o.Id = acd.OrganisationId
		UNION
		SELECT
			o.Id AS OrganisationId
			, actd.DateAdded AS DateAdded
			, d.FileSize AS FileSize
		FROM
		Document d
			INNER  JOIN AllCourseTypeDocument actd ON d.Id = actd.DocumentId
			INNER  JOIN CourseType ct ON actd.CourseTypeId = ct.Id
			INNER  JOIN Organisation o ON o.Id = ct.OrganisationId
	)
	SELECT ds.OrganisationId,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId)
				AS NumberOfDocuments
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId)
				AS TotalFileSizeGB
			,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsCurrentMonth
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBCurrentMonth
			,
						(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsPreviousMonth
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBPreviousMonth
			,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsThisYear
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBThisYear
			,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsPreviousYear
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBPreviousYear	
			,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsPreviousTwoYears
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBPreviousTwoYears	
			,
			(SELECT COUNT(*) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS NumberOfDocumentsPreviousThreeYears
			,
			(SELECT SUM(FileSize)/ POWER(2.0,30.0) 
				FROM DocumentStats_CTE ds1 WHERE ds.OrganisationId = ds1.OrganisationId
					AND DateAdded BETWEEN DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
					AND DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0))
				AS TotalFileSizeGBPreviousThreeYears	
			FROM DocumentStats_CTE ds
			GROUP BY ds.OrganisationId
			
--select * from vwDashboardMeter_DocumentStats