/*
	SCRIPT: Amend a stored procedure to update generate Report Data
	Author: Robert Newnham
	Created: 09/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP037_19.01_AmendSP_uspGetReportData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update generate Report Data';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspGetReportData', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetReportData;
	END		
	GO

	/*
		Create uspGetReportData
	*/

	CREATE PROCEDURE uspGetReportData (@ReportRequestId INT)
	AS
	BEGIN
	
		DECLARE @OrgId int;
		DECLARE @ReportId int;
		DECLARE @DataViewId int;
		DECLARE @DataViewColumns int;
		DECLARE @SQL NVARCHAR(4000);
		DECLARE @MaxReportColumns INT = 30; --This Relates to the ReportData Class Data Columns in the "ReportController.cs"

		SELECT
			@ReportId = RR.ReportId
			, @DataViewId = RR.ReportDataViewId
			, @OrgId = RR.OrganisationId
		FROM vwReportRequest RR
		WHERE RR.ReportRequestId = @ReportRequestId;
		
		SELECT @DataViewColumns=COUNT(*)
		FROM vwReportColumn RC
		WHERE RC.[ReportId] = @ReportId;

		SET @SQL = 'SELECT ' + CAST(@ReportId AS VARCHAR) + ' AS ReportId '
							+ ' , ''ReportRow'' AS ReportClass' --Let The Report Viewer Know that this is a standard Row
							+ ' , ' + CAST(@DataViewColumns AS VARCHAR) + ' AS NumberOfDataColumns'
		
		--Now the SELECT Columns
		SELECT @SQL = @SQL 
				+ ', ' + ' + CAST(' 
				+ RC.ColumnName + ' AS VARCHAR)'
				--+ ' AS [C' +  + RC.ColumnTitle + '] ' --+ ' AS [' +  + DVC.[Name] + '] '
				+ ' AS [C' + CAST(RC.ColumnDisplayOrder AS VARCHAR) + '] ' --+ ' AS [' +  + DVC.[Name] + '] '
		FROM vwReportColumn RC
		WHERE RC.[ReportId] = @ReportId
		ORDER BY RC.ColumnDisplayOrder ASC;

		
		SELECT TOP (@MaxReportColumns - @DataViewColumns) ROW_NUMBER() OVER(ORDER BY A.[Name]) + @DataViewColumns AS ColumnNumber
		INTO #ColumnNumber
		FROM SYS.ALL_OBJECTS A
		
		--Now the Dummy Columns
		SELECT @SQL = @SQL + ', NULL AS C' + CAST(ColumnNumber AS VARCHAR)
		FROM #ColumnNumber

		--Now the FROM
		SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' FROM '
		SELECT @SQL = @SQL + '[' + [Name] + ']'
		FROM [dbo].[DataView] DV
		WHERE DV.[Id] = @DataViewId;

		--Now the WHERE 
		SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' WHERE ';
		SET @SQL = @SQL + ' [OrganisationId] = ' + CAST(@OrgId AS VARCHAR);		--All Reports Must Use OrganisationId

		--Now Build the Rest of the Where
		IF EXISTS (SELECT * 
					FROM vwReportRequestParameter RRP 
					WHERE RRP.[ReportId] = @ReportId 
					AND RRP.ReportParameterId IS NOT NULL 
					AND ISNULL(RRP.NumberOfReportRequestParameters,0) > 0)
		BEGIN
			SELECT @SQL = @SQL + ' AND '
							+ (CASE WHEN RRP.ReportDataTypeName = 'String'
									THEN RRP.ReportDataViewColumnName + ' = ''' + RRP.ReportRequestParameterValue + ''' '
									WHEN RRP.ReportDataTypeName IN('Number', 'Currency', 'Decimal', 'CourseType')
									THEN RRP.ReportDataViewColumnName + ' = ' + RRP.ReportRequestParameterValue + ' '
									WHEN RRP.ReportDataTypeName = 'Date'
									THEN RRP.ReportDataViewColumnName + ' = CAST(''' + RRP.ReportRequestParameterValue + ''' AS DATE) '
									WHEN RRP.ReportDataTypeName = 'BDate' AND RRP.FirstBDate = 'True'
									THEN RRP.ReportDataViewColumnName + ' >= CAST(''' + RRP.ReportRequestParameterValue + ''' AS DATE) '
									WHEN RRP.ReportDataTypeName = 'BDate' AND RRP.FirstBDate = 'False'
									THEN RRP.ReportDataViewColumnName + ' <= CAST(''' + RRP.ReportRequestParameterValue + ''' AS DATE) '
									ELSE '' END)
			FROM vwReportRequestParameter RRP
			WHERE RRP.[ReportId] = @ReportId
			AND RRP.ReportParameterId IS NOT NULL
			;
		END

		--Now the ORDER BY
		IF EXISTS (SELECT * FROM vwReportColumn RC WHERE RC.[ReportId] = @ReportId AND ISNULL(RC.ColumnSortOrder,-1) >= 0)
		BEGIN
			SET @SQL = @SQL + CHAR(13) + CHAR(10) + ' ORDER BY '
			SELECT @SQL = @SQL 
					+ (CASE WHEN @SQL LIKE '%ORDER BY ' THEN '' ELSE ', ' END)
					+ RC.ColumnName
			FROM vwReportColumn RC
			WHERE RC.[ReportId] = @ReportId
			AND ISNULL(RC.ColumnSortOrder,-1) >= 0
			ORDER BY RC.ColumnSortOrder ASC;
		END

		EXECUTE sp_executesql @SQL

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP037_19.01_AmendSP_uspGetReportData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO