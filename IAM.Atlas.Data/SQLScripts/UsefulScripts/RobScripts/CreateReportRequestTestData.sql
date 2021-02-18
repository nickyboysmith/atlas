
DECLARE @ReportRequestId INT = -1;

INSERT INTO [dbo].[ReportRequest] (ReportId, CreatedByUserId, DateCreated)
SELECT R.Id AS ReportId
	, dbo.udfGetSystemUserId() AS CreatedByUserId
	, GETDATE() AS DateCreated
FROM [dbo].[Report] R
WHERE R.Title = '60 Day Attendance'

SET @ReportRequestId = SCOPE_IDENTITY();

INSERT INTO [dbo].[ReportRequestParameter] (ReportRequestId, ReportParameterId, ParameterValue)
SELECT
	@ReportRequestId AS ReportRequestId
	, RP.Id AS ReportParameterId
	, (CASE 
			WHEN RRT.DataTypeName IN ('String') THEN 'Test Paraameter'
			WHEN RRT.DataTypeName IN ('Date') THEN '2015-12-01'
			WHEN RRT.DataTypeName IN ('Number') THEN '123'
			WHEN RRT.DataTypeName IN ('Currency', 'Decimal') THEN '123.45'
			ELSE 'NULL' END)
								AS ParameterValue
FROM [dbo].[ReportRequest] RR
INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = RR.ReportId
INNER JOIN [dbo].[ReportParameter] RP ON RP.ReportDataGridId = RDG.Id
INNER JOIN [dbo].[DataViewColumn] RDV ON RDV.Id = RP.DataViewColumnId
INNER JOIN [dbo].[ReportDataType] RRT ON RRT.Id = RP.ReportDataTypeId
WHERE RR.Id = @ReportRequestId
AND RDG.DataViewId = RDG.DataViewId
