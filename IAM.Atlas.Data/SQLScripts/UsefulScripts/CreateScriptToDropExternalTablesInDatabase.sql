
DECLARE @newLine varchar(4);
SET @newLine = CHAR(13) + CHAR(10);

SELECT 'IF EXISTS (SELECT * FROM sys.tables WHERE name = ''' + name + ''')' 
			+ @newLine + 'BEGIN' 
			+ @newLine + '       DROP EXTERNAL TABLE [migration].[' + name + '];' 
			+ @newLine + 'END' + @newLine + ''
FROM sys.tables
WHERE name <> '__MigrationHistory'
ORDER BY name

