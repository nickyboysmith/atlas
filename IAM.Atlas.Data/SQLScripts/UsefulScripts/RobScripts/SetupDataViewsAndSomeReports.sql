

/*
--Clear Down All Report and Information

PRINT 'DELETE [dbo].[OrganisationReport]'
DELETE [dbo].[OrganisationReport];

PRINT 'DELETE [dbo].[UserReport]'
DELETE [dbo].[UserReport];

PRINT 'DELETE [dbo].[ReportOwner]'
DELETE [dbo].[ReportOwner];

PRINT 'DELETE [dbo].[ReportExportOption]'
DELETE [dbo].[ReportExportOption];

PRINT 'DELETE [dbo].[ReportDataGridColumn]'
DELETE [dbo].[ReportDataGridColumn];

PRINT 'DELETE [dbo].[ReportRequestParameter]'
DELETE [dbo].[ReportRequestParameter]

PRINT 'DELETE [dbo].[ReportParameter]'
DELETE [dbo].[ReportParameter]

PRINT 'DELETE [dbo].[ReportDataGrid]'
DELETE [dbo].[ReportDataGrid];

PRINT 'DELETE [dbo].[ReportChartColumn]'
DELETE [dbo].[ReportChartColumn]

PRINT 'DELETE [dbo].[ReportChart]'
DELETE [dbo].[ReportChart]

PRINT 'DELETE [dbo].[OrganisationReportCategory]'
DELETE [dbo].[OrganisationReportCategory]

PRINT 'DELETE [dbo].[ReportsReportCategory]'
DELETE [dbo].[ReportsReportCategory]

PRINT 'DELETE [dbo].[ReportCategory]'
DELETE [dbo].[ReportCategory]

PRINT 'DELETE [dbo].[ReportRequest]'
DELETE [dbo].[ReportRequest]

PRINT 'DELETE [dbo].[Report]'
DELETE [dbo].[Report]

--*/


--Setup Data Views and some Reports

--Ensure Ceatain DataViews are setup

execute uspUpdateDataViewColumn 'vwClientDetail'
execute uspUpdateDataViewColumn 'vwClientHistory'
execute uspUpdateDataViewColumn 'vwClientPayment'
execute uspUpdateDataViewColumn 'vwClientsWithinCourse'
execute uspUpdateDataViewColumn 'vwCourseClient'
execute uspUpdateDataViewColumn 'vwCourseDetail'
execute uspUpdateDataViewColumn 'vwCourseHistory'
execute uspUpdateDataViewColumn 'vwCoursesWithinVenue'
execute uspUpdateDataViewColumn 'vwPaymentDetail'
execute uspUpdateDataViewColumn 'vwClientsCreatedToday'
execute uspUpdateDataViewColumn 'vwClientsCreatedYesterday'
execute uspUpdateDataViewColumn 'vwCourseTrainer'
execute uspUpdateDataViewColumn 'vwClientCourseTransfer'

/***************************************************************************************************************************/
/*Setup Initail Report Categories for every Organisation*/

IF OBJECT_ID('tempdb..#OrgRepCat', 'U') IS NOT NULL
BEGIN
	DROP TABLE #OrgRepCat;
END
IF OBJECT_ID('tempdb..#RepCat', 'U') IS NOT NULL
BEGIN
	DROP TABLE #RepCat;
END

SELECT Title, 'False' AS [Disabled]
INTO #RepCat
FROM (
	SELECT 'Payments Reports' AS Title
	UNION SELECT 'Client Reports' AS Title
	UNION SELECT 'Trainer Reports' AS Title
	UNION SELECT 'Course Reports' AS Title
	UNION SELECT 'Special Reports' AS Title
	UNION SELECT 'Other Reports' AS Title
	) T
;

SELECT O.Id AS OrganisationId, (T.Title + '~' + CAST(O.Id AS VARCHAR)) AS Title, T.Title AS RealTitle, T.[Disabled]
INTO #OrgRepCat
FROM #RepCat T
, Organisation O;

INSERT INTO [dbo].[ReportCategory] (Title, [Disabled])
SELECT DISTINCT T.Title, T.[Disabled]
FROM #OrgRepCat T
LEFT JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
LEFT JOIN [dbo].[ReportCategory] RCb ON RCb.Title = T.RealTitle
LEFT JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.ReportCategoryId = RCb.Id
WHERE RC.Id IS NULL
AND ORCa.Id IS NULL;

INSERT INTO [dbo].[OrganisationReportCategory] (OrganisationId, ReportCategoryId)
SELECT DISTINCT T.OrganisationId, RC.Id AS ReportCategoryId
FROM #OrgRepCat T
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
LEFT JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.ReportCategoryId = RC.Id
WHERE ORCa.Id IS NULL;

UPDATE RC
SET RC.Title = T.RealTitle
FROM #OrgRepCat T
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.Title
INNER JOIN [dbo].[OrganisationReportCategory] ORCa ON ORCa.OrganisationId = T.OrganisationId
													AND ORCa.ReportCategoryId = RC.Id
;

--*/
/***************************************************************************************************************************/

IF OBJECT_ID('tempdb..#ReportWithColumns', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ReportWithColumns;
END

DECLARE @Rep1Name AS VARCHAR(100) = 'Clients By Course'
	, @Rep1Cat AS VARCHAR(100) = 'Client Reports'
	, @Rep1Cat2 AS VARCHAR(100) = ''
	, @Rep1DataView AS VARCHAR(100) = 'vwClientsWithinCourse'
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
	
DECLARE @Par3ColumnName AS VARCHAR(100) = ''
	, @Par3Title AS VARCHAR(100) = ''
	, @Par3Type AS VARCHAR(100) = ''
	, @Par3TypeId AS INT = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = '');
	;

SELECT DISTINCT
	T.Title
	, T.ReportCategory
	, T.DataViewName
	, T.ColumnName
	, T.ColumnTitle
	, T.ColumnDisplayOrder
	, T.ColumnSortOrder
INTO #ReportWithColumns
FROM (
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'ClientId'				AS ColumnName
		, 'Client ID'				AS ColumnTitle
		, 1							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'CourseReference'			AS ColumnName
		, 'Course'					AS ColumnTitle
		, 2							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1Cat					AS ReportCategory
		, @Rep1DataView				AS DataViewName
		, 'CourseStartDate'			AS ColumnName
		, 'Course Date'				AS ColumnTitle
		, 3							AS ColumnDisplayOrder
		, 1							AS ColumnSortOrder
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
		, 'ClientPoliceReference'	AS ColumnName
		, 'Referral Ref.'			AS ColumnTitle
		, 5							AS ColumnDisplayOrder
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

--/*
PRINT 'Report 3'
IF OBJECT_ID('tempdb..#ReportWithColumns3', 'U') IS NOT NULL
BEGIN
	DROP TABLE #ReportWithColumns3;
END

SET @Rep1Name = 'Courses by Trainer';
SET @Rep1Cat = 'Course Reports';
SET @Rep1Cat2 = 'Trainer Reports';
SET @Rep1DataView = 'vwCourseTrainer';

SET @Par1ColumnName = 'CourseReference'
SET @Par1Title = 'Course Reference'
SET @Par1Type = 'String'
SET @Par1TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'String')
	
SET @Par2ColumnName = 'StartDate'
SET @Par2Title= 'Course Date'
SET @Par2Type = 'BDate'
SET @Par2TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'BDate')
	
SET @Par3ColumnName = 'TrainerId'
SET @Par3Title = 'Trainer'
SET @Par3Type = 'TrainerSingle'
SET @Par3TypeId = (SELECT TOP 1 Id FROM dbo.ReportDataType WHERE DataTypeName = 'TrainerSingle')

SELECT DISTINCT
	T.Title
	, C.ReportCategory
	, T.DataViewName
	, T.ColumnName
	, T.ColumnTitle
	, T.ColumnDisplayOrder
	, T.ColumnSortOrder
INTO #ReportWithColumns3
FROM (
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseReference'			AS ColumnName
		, 'Course'					AS ColumnTitle
		, 1							AS ColumnDisplayOrder
		, 2							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'StartDate'				AS ColumnName
		, 'Course Date'				AS ColumnTitle
		, 2							AS ColumnDisplayOrder
		, 1							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseType'				AS ColumnName
		, 'Course Type'				AS ColumnTitle
		, 3							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'VenueName'				AS ColumnName
		, 'Venue'					AS ColumnTitle
		, 4							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'TrainerName'				AS ColumnName
		, 'Trainer'					AS ColumnTitle
		, 5							AS ColumnDisplayOrder
		, 3							AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseTrainerRefenece'	AS ColumnName
		, 'Reference'				AS ColumnTitle
		, 6							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseTrainerSessionBooking'	AS ColumnName
		, 'Sessions'				AS ColumnTitle
		, 7							AS ColumnDisplayOrder
		, -1						AS ColumnSortOrder
	UNION
	SELECT @Rep1Name				AS Title
		, @Rep1DataView				AS DataViewName
		, 'CourseTrainerPaymentDue'	AS ColumnName
		, 'Fee'						AS ColumnTitle
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
FROM (SELECT DISTINCT Title FROM #ReportWithColumns3) T
LEFT JOIN [dbo].[Report] R ON R.Title = T.Title
WHERE R.Id IS NULL;

INSERT INTO [dbo].[OrganisationReport] (OrganisationId, ReportId)
SELECT DISTINCT O.Id AS OrganisationId, R.Id AS ReportId
FROM #ReportWithColumns3 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.Organisation O
WHERE NOT EXISTS (SELECT * FROM [dbo].[OrganisationReport] RO WHERE RO.ReportId = R.Id AND RO.OrganisationId = O.Id)
;

INSERT INTO [dbo].[ReportOwner] (ReportId, UserId)
SELECT DISTINCT R.Id AS ReportId, SAU.UserId AS UserId
FROM #ReportWithColumns3 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
, dbo.SystemAdminUser SAU
WHERE NOT EXISTS (SELECT * FROM [dbo].[ReportOwner] RO WHERE RO.ReportId = R.Id AND RO.UserId = SAU.UserId)
;

INSERT INTO [dbo].[ReportsReportCategory] (ReportId, ReportCategoryId)
SELECT DISTINCT R.Id AS ReportId, RC.Id AS ReportCategoryId
FROM #ReportWithColumns3 T
INNER JOIN [dbo].[Report] R ON R.Title = T.Title
INNER JOIN [dbo].[ReportCategory] RC ON RC.Title = T.ReportCategory
LEFT JOIN [dbo].[ReportsReportCategory] RRC ON RRC.ReportId = R.Id
											AND RRC.ReportCategoryId = RC.Id
WHERE RRC.Id IS NULL;


INSERT INTO [dbo].[ReportDataGrid] (ReportId, DataViewId)
SELECT DISTINCT R.Id AS ReportId, DV.Id AS DataViewId
FROM #ReportWithColumns3 T
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
FROM #ReportWithColumns3 T
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
	FROM #ReportWithColumns3 T
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
	FROM #ReportWithColumns3 T
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
	FROM #ReportWithColumns3 T
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