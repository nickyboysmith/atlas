

/***************************************************************************************************************************/

IF OBJECT_ID('tempdb..#ReportWithColumns', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ReportWithColumns;
END

DECLARE @Rep1Name AS VARCHAR(100) = 'All Clients'
	, @Rep1Cat AS VARCHAR(100) = 'Client Reports'
	, @Rep1Cat2 AS VARCHAR(100) = ''
	, @Rep1DataView AS VARCHAR(100) = 'vwClientDetail'
	;
DECLARE @Par1ColumnName AS VARCHAR(100) = 'CourseReference'
	, @Par1Title AS VARCHAR(100) = 'Course Reference'
	, @Par1Type AS VARCHAR(100) = 'String'
	, @Par1TypeId AS INT = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'String')
	;
	
DECLARE @Par2ColumnName AS VARCHAR(100) = 'CourseStartDate'
	, @Par2Title AS VARCHAR(100) = 'Course Date'
	, @Par2Type AS VARCHAR(100) = 'BDate'
	, @Par2TypeId AS INT = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'BDate')
	;
	
DECLARE @Par3ColumnName AS VARCHAR(100) = 'ReferringAuthorityId'
	, @Par3Title AS VARCHAR(100) = 'Referring Authority'
	, @Par3Type AS VARCHAR(100) = 'ReferringAuthoritySingle'
	, @Par3TypeId AS INT = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'ReferringAuthoritySingle');
	;

SELECT DISTINCT
	T.Title
	, C.ReportCategory
	, T.DataViewName
	, T.ColumnName
	, T.ColumnTitle
	, T.ColumnDisplayOrder
	, T.ColumnSortOrder
INTO #ReportWithColumns
FROM (
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'ClientId'				AS ColumnName
		, 'Client ID'				AS ColumnTitle
		, 2							AS ColumnDisplayOrder
		, 2							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'DisplayName'				AS ColumnName
		, 'Client Name'				AS ColumnTitle
		, 1							AS ColumnDisplayOrder
		, 1							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseReference'			AS ColumnName
		, 'Course'					AS ColumnTitle
		, 3							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'StartDate'				AS ColumnName
		, 'Course Date'				AS ColumnTitle
		, 4							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'ReferralReference'		AS ColumnName
		, 'Referral Reference'		AS ColumnTitle
		, 5							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'AmountPaidByClient'		AS ColumnName
		, 'Paid'					AS ColumnTitle
		, 6							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	) T
, (SELECT @Rep1Cat AS ReportCategory UNION SELECT @Rep1Cat2 AS ReportCategory) C

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
FROM (SELECT DISTINCT Title FROM #ReportWithColumns) T
LEFT JOIN [dbo].[Report] R ON R.Title = T.Title
WHERE R.Id IS NULL;

INSERT INTO [dbo].[OrganisationReport] (OrganisationId, ReportId)
SELECT DISTINCT O.Id AS OrganisationId, R.Id AS ReportId
FROM #ReportWithColumns T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.Organisation O
WHERE NOT EXISTS (SELECT * FROM [dbo].[OrganisationReport] RO WHERE RO.ReportId = R.Id AND RO.OrganisationId = O.Id)
;

INSERT INTO [dbo].[ReportOwner] (ReportId, UserId)
SELECT DISTINCT R.Id AS ReportId, SAU.UserId AS UserId
FROM #ReportWithColumns T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.SystemAdminUser SAU
WHERE NOT EXISTS (SELECT * FROM [dbo].[ReportOwner] RO WHERE RO.ReportId = R.Id AND RO.UserId = SAU.UserId)
;

INSERT INTO [dbo].[ReportsReportCategory] (ReportId, ReportCategoryId)
SELECT DISTINCT R.Id AS ReportId, RC.Id AS ReportCategoryId
FROM #ReportWithColumns T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.ReportCategory
LEFT JOIN [dbo].[ReportsReportCategory] RRC ON RRC.ReportId = R.Id
											AND RRC.ReportCategoryId = RC.Id
WHERE RRC.Id IS NULL;


INSERT INTO [dbo].[ReportDataGrid] (ReportId, DataViewId)
SELECT DISTINCT R.Id AS ReportId, DV.Id AS DataViewId
FROM #ReportWithColumns T
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
FROM #ReportWithColumns T
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
	FROM #ReportWithColumns T
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
	FROM #ReportWithColumns T
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
	FROM #ReportWithColumns T
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



--*/