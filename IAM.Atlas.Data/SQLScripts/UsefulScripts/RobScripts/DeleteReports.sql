

SELECT * FROM [dbo].[Report]

/*
  DELETE RCC
  FROM ReportChart RC
  INNER JOIN [dbo].[ReportChartColumn] RCC ON RCC.[ReportChartId] = RC.Id
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RC
  FROM ReportChart RC
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RP
  FROM ReportDataGrid RDG
  INNER JOIN [dbo].[ReportParameter] RP ON RP.ReportDataGridId = RDG.Id
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RDGC
  FROM ReportDataGrid RDG
  INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.ReportDataGridId = RDG.Id
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RDG
  FROM ReportDataGrid RDG
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RO
  FROM ReportOwner RO
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE RRC
  FROM [dbo].[ReportsReportCategory] RRC
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE OrgR
  FROM [dbo].[OrganisationReport] OrgR
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE UR
  FROM [dbo].[UserReport] UR
  WHERE ReportId In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)
  
  DELETE R
  FROM Report R
  WHERE Id In (8, 13, 14,15,16, 17, 18, 19, 20,31, 36, 37, 57)

  --*/
  
SELECT * FROM [dbo].[Report]
