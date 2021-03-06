



  DELETE RC
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[ReportChart] RC ON RC.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72
  
  DELETE RRC
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[ReportsReportCategory] RRC ON RRC.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72

  DELETE RO
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[ReportOwner] RO ON RO.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72

  DELETE RDGC
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
  INNER JOIN [dbo].[ReportDataGridColumn] RDGC ON RDGC.ReportDataGridId = RDG.Id
  WHERE R.Id BETWEEN 21  AND 72


  DELETE RDG
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[ReportDataGrid] RDG ON RDG.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72
  
  DELETE OrgR
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[OrganisationReport] OrgR ON OrgR.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72
  
  DELETE UR
  FROM [dbo].[Report] R
  INNER JOIN [dbo].[UserReport] UR ON UR.ReportId = R.Id
  WHERE R.Id BETWEEN 21  AND 72
  

  DELETE [dbo].[Report]
  WHERE Id BETWEEN 21  AND 72

