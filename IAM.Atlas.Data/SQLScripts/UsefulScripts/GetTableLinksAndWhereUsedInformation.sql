
--EXEC sp_fkeys 'ScheduledEmail'

DECLARE @TableName Varchar(100), @TableSchema Varchar(20);
SET @TableName = 'DocumentTemplateRequest';
SET @TableSchema = 'dbo';

SELECT
	SCHEMA_NAME(o.SCHEMA_ID) AS [Schema]
	, o.name AS ReferenceObject
	, o.type_desc AS ObjectType
	, '' AS ColumnName
	, '' AS ReferencedKeyName
	--,sed.* -- Uncomment for all the columns
FROM sys.sql_expression_dependencies sed
INNER JOIN sys.objects o ON sed.referencing_id = o.[object_id] 
LEFT OUTER JOIN sys.objects o1 ON sed.referenced_id = o1.[object_id] 
WHERE referenced_entity_name = @TableName
AND (referenced_schema_name = @TableSchema OR referenced_schema_name IS NULL)
UNION ALL
SELECT 
    sc.name AS [Schema]
	, t.name as ReferenceObject
    , 'Foreign Key: "' + OBJECT_NAME(fkc.constraint_object_id) + '"; Column: "' AS ObjectType
	, c.name as ColumnName
	, i.name AS ReferencedKeyName
FROM sys.foreign_key_columns fkc
INNER JOIN sys.index_columns ic	ON ic.object_id = fkc.parent_object_id
								AND ic.column_id = fkc.parent_column_id
INNER JOIN sys.indexes i ON i.index_id = ic.index_id
						AND i.object_id = ic.object_id
INNER JOIN sys.columns c ON c.object_id = ic.object_id
						AND c.column_id = ic.column_id  
INNER JOIN sys.tables t ON t.object_id = c.object_id
INNER JOIN sys.schemas sc ON sc.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
AND OBJECT_NAME(fkc.referenced_object_id) = @TableName
ORDER BY [Schema], ReferenceObject, ColumnName
