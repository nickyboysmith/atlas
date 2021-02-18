/*
	SCRIPT: Create a Dashboard Meter View for Documents
	Author: Nick Smith
	Created: 14/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_52.01_CreateView_vwDashboardMeter_DocumentStats.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a view to retrieve DashboardMeter_DocumentStats';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

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
--	CREATE VIEW vwDashboardMeter_DocumentStats AS	
	


--WITH DocumentStats (OrganisationId, DateAdded, OrganisationId, DateAdded, OrganisationId, DateAdded, FileSize)
--AS
--	(SELECT 
--			oatd.Id AS OrganisationId
--			, atd.DateAdded AS DateAdded
--			, oacd.Id AS OrganisationId
--			, acd.DateAdded AS DateAdded
--			, oct.Id AS OrganisationId
--			, actd.DateAdded AS DateAdded
--			, d.FileSize AS FileSize
--FROM
--			Document d
--			LEFT JOIN AllTrainerDocument atd ON d.Id = atd.DocumentId
--			LEFT JOIN AllCourseDocument acd ON d.Id = acd.DocumentId
--			LEFT JOIN AllCourseTypeDocument actd ON d.Id = actd.DocumentId
--			LEFT JOIN CourseType ct ON actd.CourseTypeId = ct.Id
--			LEFT JOIN Organisation oatd ON oatd.Id = atd.OrganisationId
--			LEFT JOIN Organisation oacd ON oacd.Id = acd.OrganisationId
--			LEFT JOIN Organisation oct ON oct.Id = ct.OrganisationId
--			WHERE (oatd.Id IS NOT NULL OR oacd.Id IS NOT NULL OR oct.Id IS NOT NULL)
--		)

--   /*
--		Drop the Procedure if it already exists
--	*/		
--	IF OBJECT_ID('dbo.vwDashboardMeter_DocumentStats', 'V') IS NOT NULL
--	BEGIN
--		DROP VIEW dbo.vwDashboardMeter_DocumentStats;
--	END		
--	GO

	/*
		Create View vwDashboardMeter_DocumentStats
	*/
	CREATE VIEW vwDashboardMeter_DocumentStats AS	
	
--TrainerOrgId, TrainerDateAdded, CourseOrgId, CourseDateAdded, CourseTypeOrgId, CourseTypeDateAdded, FileSize

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
	SELECT TotalSystem.OrganisationId
			, TotalSystem.NumberOfDocuments
			, TotalSystem.TotalFileSizeGB
			, CurrentMonth.NumberOfDocumentsCurrentMonth FROM 
			(
			SELECT OrganisationId
				, COUNT(*) AS NumberOfDocuments
				, SUM(FileSize)/ POWER(2.0,30.0) AS TotalFileSizeGB 
				FROM DocumentStats_CTE
				GROUP BY OrganisationId) AS TotalSystem,
			(
			SELECT OrganisationId, COUNT(*) AS NumberOfDocumentsCurrentMonth
				FROM DocumentStats_CTE
				WHERE DateAdded BETWEEN 
				 DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0)
				 AND 
				 DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)
				 GROUP BY OrganisationId) AS CurrentMonth
			
	


		FROM [dbo].[Payment] P
		INNER JOIN [dbo].[User] U ON U.Id = P.CreatedByUserId
		INNER JOIN [dbo].[OrganisationUser] OU ON OU.[UserId] = U.Id
		INNER JOIN [dbo].[Organisation] O ON O.[Id] = OU.[OrganisationId]
		LEFT JOIN [dbo].[ClientPayment] CP ON CP.[PaymentId] = P.Id
		LEFT JOIN [dbo].[ClientOrganisation] CO ON CO.[ClientId] = CP.[ClientId]
		LEFT JOIN [dbo].[Organisation] CO_O ON CO_O.[Id] = CO.[OrganisationId]
		LEFT JOIN (
					SELECT O2.[Id] AS OrganisationId
						, O2.Name AS OrganisationName
						, COUNT(*) AS NumberOfUnpaidBookedCourses
					FROM [dbo].[Organisation] O2
					INNER JOIN [dbo].[Course] C2 ON C2.[OrganisationId] = O2.Id
					INNER JOIN [dbo].[CourseClient] CC2 ON CC2.[CourseId] = C2.Id
					LEFT JOIN [dbo].[CourseClientPayment] CCP2 ON CCP2.[CourseId] = C2.Id
																AND CCP2.[ClientId] = CC2.[ClientId]
					WHERE CCP2.Id IS NULL
					GROUP BY O2.[Id], O2.Name 
					) OrgCourse ON OrgCourse.OrganisationId = O.Id
		WHERE [DateCreated] >= CAST(DATEADD(YEAR, -1, GetDate()) AS DATE) --Only Data going back 1 year ago
		GROUP BY O.[Id], O.Name, CONVERT(date, P.[DateCreated])
		;

		/* 250 Gb */
DECLARE @MY_NumberOfBytes NUMERIC(12,0) = 268435456000;
/* bytes */
SELECT 
    'Bytes'                             AS UNIT
   ,@MY_NumberOfBytes                   AS NUMBER
UNION ALL
/* Kilobytes, divide by 2^10 (1024) */
SELECT 
    'Kilobytes'                         AS UNIT
   ,@MY_NumberOfBytes / POWER(2.0,10.0) AS NUMBER
UNION ALL
/* Megabytes, divide by 2^20 (1048576) */
SELECT 
    'Megabytes'                         AS UNIT
   ,@MY_NumberOfBytes / POWER(2.0,20.0) AS NUMBER
UNION ALL
/* Gigabytes, divide by 2^30 (1073741824) */
SELECT 
    'Gigabytes'                         AS UNIT
   ,@MY_NumberOfBytes / POWER(2.0,30.0) AS NUMBER
UNION ALL
/* Terabytes, divide by 2^40 (1099511627776) */
SELECT 
    'Terabytes'                         AS UNIT
   ,@MY_NumberOfBytes / POWER(2.0,40.0) AS NUMBER;




		/*****************************************************************************************************************/
	GO

DECLARE @ScriptName VARCHAR(100) = 'SP021_52.01_CreateView_vwDashboardMeter_DocumentStats.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO


