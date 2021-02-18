
--Find All Triggers
SELECT
  [Table] = Left((CASE WHEN TR.Parent_Class = 0 THEN '(Database)' ELSE Object_Name(TR.Parent_ID) END), 32)
  , [Schema] = Left(Coalesce(Object_Schema_Name(TR.Object_ID), '(None)'), 16)
  , [Trigger name] = TR.Name --Left(TR.Name, 32)
  , [Event] = Left(
					(CASE WHEN TR.Parent_Class = 0 
					THEN (SELECT TOP 1 Left(Te.Event_Group_Type_Desc, 40)
							FROM Sys.Trigger_Events As Te
							WHERE Te.Object_ID = TR.Object_ID)
					ELSE (
							(CASE WHEN TR.Is_Instead_Of_Trigger = 1 THEN 'Instead Of ' ELSE 'After ' END)) +
							SUBSTRING(CAST(
											(SELECT [text()] = ', ' 
													+ Left(Te.Type_Desc, 1) 
													+ LOWER(SUBSTRING(Te.Type_Desc, 2, 32)) 
													+ (CASE WHEN Te.Is_First = 1 THEN ' (First)' 
															WHEN Te.Is_Last = 1 THEN ' (Last)' 
															ELSE '' END)
											FROM Sys.Trigger_Events As Te
											WHERE Te.Object_ID = TR.Object_ID
											ORDER BY Te.[Type]
											FOR Xml Path ('')
											) As Character Varying)
										, 3, 60) 
					END)
					, 60)
  , (CASE WHEN TR.Is_Disabled = 0 THEN '' ELSE '*DISABLED*' END)
  , TR.type_desc
FROM Sys.Triggers As TR
ORDER BY [Table], TR.Parent_Class

--Find Triggers That Contain ............
SELECT 
      Tables.Name TableName,
      Triggers.name TriggerName,
      Triggers.crdate TriggerCreatedDate,
      Comments.Text TriggerText
FROM      sysobjects Triggers
      Inner Join sysobjects Tables On Triggers.parent_obj = Tables.id
      Inner Join syscomments Comments On Triggers.id = Comments.id
WHERE      Triggers.xtype = 'TR'
      And Tables.xtype = 'U'
	  AND Comments.Text LIKE '%TheTriggerName%'
ORDER BY Tables.Name, Triggers.name

