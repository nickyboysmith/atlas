
  INSERT INTO [VehicleCategory] ([Name], [Disabled], AddedByUserId, DateAdded, [Description], OrganisationId)
  SELECT DISTINCT 
      T.[Name]
      , T.[Disabled]
      , T.[AddedByUserId]
      , T.[DateAdded]
      , T.[Description]
      , O.Id AS [OrganisationId]
	FROM dbo.Organisation O
	, (
	  SELECT  
		  'Dual Controlled Car' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Dual Controlled Car' AS [Description]
	  UNION SELECT  
		  'Built in Sat-Nav' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Built in Sat-Nav' AS [Description]
	  UNION SELECT  
		  'Convertible' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Convertible' AS [Description]
	  UNION SELECT  
		  'Has Tow Bar' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Has Tow Bar' AS [Description]
	  UNION SELECT  
		  '3 Door' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Three Door Car' AS [Description]
	  UNION SELECT  
		  '5 Door' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Five Door Car' AS [Description]
	  UNION SELECT  
		  'Green' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Green' AS [Description]
	  UNION SELECT  
		  'Armoured' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Armoured Car' AS [Description]
	  UNION SELECT  
		  'Vintage' AS [Name]
		  , 'False' AS [Disabled]
		  , dbo.udfGetSystemUserId() AS [AddedByUserId]
		  , GETDATE() AS [DateAdded]
		  , 'Vintage Car' AS [Description]
		  ) T
	WHERE NOT EXISTS (SELECT * FROM [VehicleCategory] VC WHERE VC.[Name] = T.[Name] AND VC.OrganisationId = O.Id) 


	SELECT [Id]
      ,[Name]
      ,[Disabled]
      ,[AddedByUserId]
      ,[DateAdded]
      ,[Description]
      ,[OrganisationId]
      ,[UpdatedByUserId]
      ,[DateUpdated]
  FROM [dbo].[VehicleCategory]
