
DECLARE @sql VARCHAR(MAX) = '';
DECLARE @newLine CHAR(2) = CHAR(13) + CHAR(10);
DECLARE @TheTable VARCHAR(200) = 'DashboardMeterData_UnpaidBookedCourse';

SELECT @sql = @sql + (CASE WHEN @sql = '' 
				THEN 'INSERT INTO dbo.' + T.[Name] + '(' 
					+ @newLine + C.[Name]
				ELSE @newLine + ', ' + C.[Name] END)
FROM SYS.Tables T
INNER JOIN SYS.Columns C ON C.object_id = T.object_id
WHERE T.[Name] = @TheTable
AND C.[Name] <> 'Id'
;

SELECT @sql = @sql + (CASE WHEN CHARINDEX('SELECT ',@sql) > 0
				THEN @newLine + ', D.' + C.[Name]
				ELSE @newLine + ')' + @newLine 
					+ 'SELECT '
					+ @newLine + 'D.' + C.[Name]END)
FROM SYS.Tables T
INNER JOIN SYS.Columns C ON C.object_id = T.object_id
WHERE T.[Name] = @TheTable
AND C.[Name] <> 'Id'
;

SET @sql = @sql + @newLine + 'FROM #Temp' + @TheTable + ' D'
		+ @newLine + 'LEFT JOIN ' + @TheTable + ' T ON T.OrganisationId = D.OrganisationId'
		+ @newLine + 'WHERE T.Id IS NULL;'
		+ @newLine + @newLine;

SET @sql = @sql + @newLine + '--Update Existing'
			+ @newLine + 'UPDATE T'
			+ @newLine + 'SET';
			
SELECT @sql = @sql + (CASE WHEN RIGHT(@sql,3) = 'SET'
				THEN @newLine + 'T.' + C.[Name] + ' = D.' + C.[Name]
				ELSE @newLine + ', T.' + C.[Name] + ' = D.' + C.[Name] 
				END)
FROM SYS.Tables T
INNER JOIN SYS.Columns C ON C.object_id = T.object_id
WHERE T.[Name] = @TheTable
AND C.[Name] <> 'Id'
;

SET @sql = @sql + @newLine + 'FROM #Temp' + @TheTable + ' D'
		+ @newLine + 'INNER JOIN ' + @TheTable + ' T ON T.OrganisationId = D.OrganisationId'
		+ @newLine + ';'
		+ @newLine + @newLine;

SELECT @sql
						