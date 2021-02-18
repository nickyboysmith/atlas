
/*
	SCRIPT: Returns a Reports Sub Titles For the Report
	Author: Robert Newnham
	Created: 02/10/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP044_14.01_CreateFunction_udfGetReportSubTitle.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Returns a Reports Sub Titles For the Report';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Function if it already exists
	*/		
	IF OBJECT_ID('dbo.udfGetReportSubTitle', 'FN') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.udfGetReportSubTitle;
	END		
	GO
	
	/*
		Create udfGetDate
	*/
	CREATE FUNCTION dbo.udfGetReportSubTitle (@ReportRequestId INT)
	RETURNS NVARCHAR(1000)
	AS
	BEGIN
		DECLARE @ReportSubTitle VARCHAR(1000) = '';
		DECLARE @NewLine CHAR(2) = CHAR(13) + CHAR(10);

		SELECT @ReportSubTitle = STRING_AGG('<DIV CLASS="ReportSubTitleRow">' 
			+ (CASE WHEN RDT.DataTypeName IN ('String')
						THEN RP.Title + ' IS "' + RRP.ParameterValueText + '"'
					WHEN RDT.Title LIKE '%Single Select'
						THEN 'For ' + RP.Title + ': ' + RRP.ParameterValueText + ''
					WHEN RDT.DataTypeName = 'BDATE'
						THEN RP.Title
							+ ' Between ' + CAST(T.StartBDate AS VARCHAR(11))
							+ ' And ' + CAST(T.EndBDate AS VARCHAR(11))
					ELSE RP.Title+ ' IS "' + RRP.ParameterValueText + '"' 
					END)
			+ '</DIV>', @NewLine )
		FROM dbo.ReportRequest RR
		INNER JOIN dbo.ReportRequestParameter RRP		ON RRP.ReportRequestId = RR.Id
		INNER JOIN dbo.ReportParameter RP				ON RP.Id = RRP.ReportParameterId
		INNER JOIN dbo.DataViewColumn DVC				ON DVC.Id = RP.DataViewColumnId
		INNER JOIN dbo.ReportDataType RDT				ON RDT.Id = RP.ReportDataTypeId
				
		LEFT JOIN (SELECT RRP2.ReportRequestId
						, MIN(CAST(RRP2.ParameterValue AS DATETIME)) StartBDate
						, MAX(CAST(RRP2.ParameterValue AS DATETIME)) EndBDate
					FROM [dbo].[ReportRequestParameter] RRP2
					INNER JOIN dbo.ReportParameter RP2	ON RP2.Id = RRP2.ReportParameterId
					INNER JOIN dbo.ReportDataType RDT2	ON RDT2.Id = RP2.ReportDataTypeId
					WHERE RDT2.DataTypeName = 'BDate'
					GROUP BY RRP2.ReportRequestId
					) T ON T.ReportRequestId = RR.Id
		WHERE RR.Id = @ReportRequestId
		AND (RDT.DataTypeName != 'BDATE'
			OR (RDT.DataTypeName = 'BDATE' AND CAST(RRP.ParameterValue AS DATETIME) = T.StartBDate)
			)
		;

		RETURN @ReportSubTitle;
	END
	GO
	
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP044_14.01_CreateFunction_udfGetReportSubTitle.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO