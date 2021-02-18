select * from Organisation
select * from NickOrganisation

--INSERT INTO [dbo].[Organisation]
--           ([Name]
--           ,[CreationTime]
--           ,[Active]
--           ,[CreatedByUserId]
--           ,[PreviousSystemName]
--           ,[DateUpdated]
--           ,[UpdatedByUserId])
--     SELECT 
--           N.Name
--           , CAST(N'2017-05-01 20:40:33.423' AS DateTime)
--           , N.Active
--           , 4
--           , N.PreviousSystemName
--           , CAST(N'2017-05-01 20:40:33.423' AS DateTime)
--           , 4
--		   , O.Name -- remove
--	FROM NickOrganisation N
--	LEFT JOIN Organisation O ON N.Name = O.Name
--	WHERE O.Name IS NULL 

	

GO

SELECT * from Organisation o
Inner JOIN Organisation n ON n.Name = o.Name
Where NOT Exists (select * from Organisation where name = n.name)

SELECT o.id from Organisation o
Where NOT Exists (SELECT o.id from Organisation o
Inner JOIN NickOrganisation n ON n.Name = o.Name)

