

DECLARE @ReportRequestId INT = 13;

DECLARE @OrgId int;
DECLARE @ReportRequestId int;
DECLARE @ReportId int;
DECLARE @DataViewId int
DECLARE @SQL NVARCHAR(4000);

--SET @OrgId = 30;
--SET @ReportId = 65;

SELECT
	@ReportRequestId = Id
	, @ReportId = RR.ReportId
FROM vwReportRequest RR
WHERE RR.Id = @ReportRequestId

SELECT @DataViewId = RDG.[DataViewId]
FROM [dbo].[ReportDataGrid] RDG
WHERE RDG.[ReportId] = @ReportId;


SET @SQL = 'SELECT ' + CAST(@ReportId AS VARCHAR) + ' AS ReportId '

--Now the SELECT Columns
SELECT @SQL = @SQL 
		+ ', ' --+ ', ''{{String}}''' + ' + CAST(' 
		+ DVC.[Name] --+ DVC.[Name] + ' AS VARCHAR)'
		+ ' AS [' +  + DVC.Title + '] ' --+ ' AS [' +  + DVC.[Name] + '] '
FROM [dbo].[ReportDataGrid] RDG
INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.[ReportDataGridId] = RDG.[Id]
INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[Id] = RDGC.[DataViewColumnId]
WHERE RDG.[ReportId] = @ReportId
ORDER BY RDGC.[DisplayOrder] ASC;

--Let The Report Viewer Know that this is a standard Row
SET @SQL = @SQL + ' , ''ReportRow'' AS ReportClass'

--Now the FROM
SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' FROM '
SELECT @SQL = @SQL + [Name]
FROM [dbo].[DataView] DV
WHERE DV.[Id] = @DataViewId;

--Now the WHERE 
SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' WHERE ';
SET @SQL = @SQL + ' [OrganisationId] = ' + CAST(@OrgId AS VARCHAR);

--Now the ORDER BY
SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' ORDER BY '
SELECT @SQL = @SQL 
		+ (CASE WHEN @SQL LIKE '%ORDER BY ' THEN '' ELSE ', ' END)
		+ DVC.[Name]
FROM [dbo].[ReportDataGrid] RDG
INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.[ReportDataGridId] = RDG.[Id]
INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[Id] = RDGC.[DataViewColumnId]
WHERE RDG.[ReportId] = @ReportId
ORDER BY RDGC.[SortOrder] ASC;


SELECT @SQL

EXECUTE sp_executesql @SQL



