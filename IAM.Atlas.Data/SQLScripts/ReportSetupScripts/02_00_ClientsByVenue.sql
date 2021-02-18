
/***************************************************************************************************************************/

IF OBJECT_ID('tempdb..#ReportWithColumns2', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ReportWithColumns2;
END

SET @Rep1Name = 'Clients By Venue';
SET @Rep1Cat = 'Client Reports';
SET @Rep1Cat2 = '';
SET @Rep1DataView = 'vwCourseClient';

SET @Par1ColumnName = 'VenueId'
SET @Par1Title = 'Venue'
SET @Par1Type = 'VenueSingle'
SET @Par1TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'VenueSingle')
	
SET @Par2ColumnName = 'StartDate'
SET @Par2Title = 'Course Date'
SET @Par2Type = 'BDate'
SET @Par2TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'BDate')
	
SET @Par3ColumnName = ''
SET @Par3Title = ''
SET @Par3Type = ''
SET @Par3TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = '')

SELECT DISTINCT
	T.Title
	, T.ReportCategory
	, T.DataViewName
	, T.ColumnName
	, T.ColumnTitle
	, T.ColumnDisplayOrder
	, T.ColumnSortOrder
INTO #ReportWithColumns2
FROM (
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'VenueName'				AS ColumnName
		, 'Venue'					AS ColumnTitle
		, 1							AS ColumnDisplayOrder
		, 1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'ClientId'				AS ColumnName
		, 'Client ID'				AS ColumnTitle
		, 2							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'CourseReference'			AS ColumnName
		, 'Course'					AS ColumnTitle
		, 3							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'ClientName'				AS ColumnName
		, 'Client Name'				AS ColumnTitle
		, 4							AS ColumnDisplayOrder
		, 2							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'StartDate'				AS ColumnName
		, 'Course Date'				AS ColumnTitle
		, 5							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'ClientPoliceReference'	AS ColumnName
		, 'Referral Ref.'			AS ColumnTitle
		, 6							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	) T

INSERT INTO [dbo].[Report] (Title, [Description], CreatedByUserId, DateCreated, UpdatedByUserId, DateUpdated, AtlasSystemReport, Landscape, ChangeNo)
SELECT DISTINCT
	T.Title
	, 'Report: "' + T.Title + '"'	AS [Description]
	, dbo.udfGetSystemUserId()		AS CreatedByUserId
	, GETDATE()						AS DateCreated
	, dbo.udfGetSystemUserId()		AS UpdatedByUserId
	, GETDATE()						AS DateUpdated
	, 'True'						AS AtlasSystemReport
	, 'False'						AS Landscape
	, 1								AS ChangeNo
FROM (SELECT DISTINCT Title FROM #ReportWithColumns2) T
LEFT JOIN [dbo].[Report] R ON R.Title = T.Title
WHERE R.Id IS NULL;

INSERT INTO [dbo].[OrganisationReport] (OrganisationId, ReportId)
SELECT DISTINCT O.Id AS OrganisationId, R.Id AS ReportId
FROM #ReportWithColumns2 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.Organisation O
WHERE NOT EXISTS (SELECT * FROM [dbo].[OrganisationReport] RO WHERE RO.ReportId = R.Id AND RO.OrganisationId = O.Id)
;

INSERT INTO [dbo].[ReportOwner] (ReportId, UserId)
SELECT DISTINCT R.Id AS ReportId, SAU.UserId AS UserId
FROM #ReportWithColumns2 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.SystemAdminUser SAU
WHERE NOT EXISTS (SELECT * FROM [dbo].[ReportOwner] RO WHERE RO.ReportId = R.Id AND RO.UserId = SAU.UserId)
;

INSERT INTO [dbo].[ReportsReportCategory] (ReportId, ReportCategoryId)
SELECT DISTINCT R.Id AS ReportId, RC.Id AS ReportCategoryId
FROM #ReportWithColumns2 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.ReportCategory
LEFT JOIN [dbo].[ReportsReportCategory] RRC ON RRC.ReportId = R.Id
											AND RRC.ReportCategoryId = RC.Id
WHERE RRC.Id IS NULL;


INSERT INTO [dbo].[ReportDataGrid] (ReportId, DataViewId)
SELECT DISTINCT R.Id AS ReportId, DV.Id AS DataViewId
FROM #ReportWithColumns2 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
INNER JOIN [dbo].[DataView] DV ON DV.[Name] = T.DataViewName
LEFT JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
									AND RDG.DataViewId = DV.Id
WHERE RDG.Id IS NULL;

INSERT INTO [dbo].[ReportDataGridColumn] (DataViewColumnId, DisplayOrder, ReportDataGridId, SortOrder, ColumnTitle)
SELECT DISTINCT DVC.Id AS DataViewColumnId
				--, (ROW_NUMBER() OVER (Order by ReportDataGridId, DataViewColumnId)) AS DisplayOrder
				, T.ColumnDisplayOrder AS DisplayOrder
				, RDG.Id AS ReportDataGridId
				--, (ROW_NUMBER() OVER (Order by ReportDataGridId, DataViewColumnId)) AS SortOrder
				, T.ColumnSortOrder AS SortOrder
				, T.ColumnTitle AS ColumnTitle
FROM #ReportWithColumns2 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
INNER JOIN [dbo].[DataView] DV ON DV.[Name] = T.DataViewName
INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
									AND RDG.DataViewId = DV.Id
INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.DataViewId = DV.Id
									AND DVC.[Name] = T.ColumnName
LEFT JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.DataViewColumnId = DVC.Id
											AND RDGC.ReportDataGridId = RDG.Id
WHERE RDGC.Id IS NULL;

INSERT INTO [dbo].[ReportParameter] (Title, ReportDataGridId, DataViewColumnId, ReportDataTypeId)
SELECT DISTINCT T.Title, T.ReportDataGridId, T.DataViewColumnId, T.ReportDataTypeId
FROM (
	SELECT
		@Par1Title AS Title
		, RDG.Id AS ReportDataGridId
		, DVC.Id AS DataViewColumnId
		, @Par1TypeId AS ReportDataTypeId
	FROM #ReportWithColumns2 T
	INNER JOIN [dbo].[Report] R ON R.Title = T.Title
	INNER JOIN [dbo].[DataView] DV ON DV.[Name] = T.DataViewName
	INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
										AND RDG.DataViewId = DV.Id
	INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.DataViewId = DV.Id
										AND DVC.[Name] = @Par1ColumnName
	UNION
	SELECT
		@Par2Title AS Title
		, RDG.Id AS ReportDataGridId
		, DVC.Id AS DataViewColumnId
		, @Par2TypeId AS ReportDataTypeId
	FROM #ReportWithColumns2 T
	INNER JOIN [dbo].[Report] R ON R.Title = T.Title
	INNER JOIN [dbo].[DataView] DV ON DV.[Name] = T.DataViewName
	INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
										AND RDG.DataViewId = DV.Id
	INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.DataViewId = DV.Id
										AND DVC.[Name] = @Par2ColumnName
	UNION
	SELECT
		@Par3Title AS Title
		, RDG.Id AS ReportDataGridId
		, DVC.Id AS DataViewColumnId
		, @Par3TypeId AS ReportDataTypeId
	FROM #ReportWithColumns2 T
	INNER JOIN [dbo].[Report] R ON R.Title = T.Title
	INNER JOIN [dbo].[DataView] DV ON DV.[Name] = T.DataViewName
	INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
										AND RDG.DataViewId = DV.Id
	INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.DataViewId = DV.Id
										AND DVC.[Name] = @Par3ColumnName
) T
LEFT JOIN [dbo].[ReportParameter] RP	ON RP.Title = T.Title
										AND RP.ReportDataGridId = T.ReportDataGridId
										AND RP.DataViewColumnId = T.DataViewColumnId
WHERE RP.Id IS NULL;

/***************************************************************************************************************************/
