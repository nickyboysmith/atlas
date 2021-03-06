
  
  DELETE RRP
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportParameter] RP ON RP.ReportDataGridId = RDG.Id
  INNER JOIN [dbo].[ReportRequestParameter] RRP ON RRP.[ReportParameterId] = RP.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RCC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportChart] RC ON RC.ReportId = RDG.ReportId
  INNER JOIN [dbo].[ReportChartColumn] RCC ON RCC.ReportChartId = RC.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RCC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportChartColumn] RCC ON RCC.DataViewColumnId = DVC.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RDGC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.DataViewColumnId = DVC.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportChart] RC ON RC.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RP
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportParameter] RP ON RP.ReportDataGridId = RDG.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RRC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportsReportCategory] RRC ON RRC.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RO
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportOwner] RO ON RO.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE R
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[OrganisationReport] R ON R.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE R
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[UserReport] R ON R.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE R
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportRequest] R ON R.ReportId = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE R
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[Report] R ON R.Id = RDG.ReportId
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RDGC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.ReportDataGridId = RDG.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)

  DELETE RDG
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.[DataViewId] = DV.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE DVC2
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewForDocumentTemplate] DVC ON DVC.[DataViewId] = DV.Id
  INNER JOIN [dbo].[DataViewForDocumentTemplateViewableColumn] DVC2 ON DVC2.DataViewForDocumentTemplateId = DVC.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE DVC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewLog] DVC ON DVC.[DataViewId] = DV.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE DVC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewForDocumentTemplate] DVC ON DVC.[DataViewId] = DV.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE DVC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[DataViewColumn] DVC ON DVC.[DataViewId] = DV.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)
  
  DELETE RC
  FROM [dbo].[DataView] DV
  INNER JOIN [dbo].[ReportChart] RC ON RC.DataViewId = DV.Id
  WHERE DV.ID IN (1,3,4,5,6,10,11)

  DELETE [dbo].[DataView] 
  WHERE ID IN (1,3,4,5,6,10,11)