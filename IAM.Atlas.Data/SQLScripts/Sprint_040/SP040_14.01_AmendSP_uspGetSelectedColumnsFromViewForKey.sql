/*
	SCRIPT: Amend uspGetSelectedColumnsFromViewForKey
	Author: Dan Hough
	Created: 03/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_14.01_AmendSP_uspGetSelectedColumnsFromViewForKey.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend uspGetSelectedColumnsFromViewForKey';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspGetSelectedColumnsFromViewForKey', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetSelectedColumnsFromViewForKey;
	END		
	GO

	/*
		Create uspGetAllColumnsFromViewForKey
	*/

	CREATE PROCEDURE uspGetSelectedColumnsFromViewForKey (@viewName VARCHAR(100)
															, @selectedColumnNames VARCHAR(1000)
															, @keyName VARCHAR(100)
															, @keyValue INT
															, @processRequestId BIGINT
															, @processRequestDateTime DATETIME)
	AS
	BEGIN
		DECLARE @sql NVARCHAR(4000)
				, @count INT = 1
				, @column NVARCHAR(100)
				, @result NVARCHAR(1000)
				, @rowCount INT
				, @return BIT = 'False';


		/*
			Drop temp table if it already exists
		*/	

		IF OBJECT_ID('tempdb..#StringSplitter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #StringSplitter;
		END		

		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS TempId, Item
		INTO #StringSplitter
		FROM dbo.udfSplitStringUsingCustomSeparator(@selectedColumnNames, ',');

		SELECT @rowCount = COUNT(*) FROM #StringSplitter;

		WHILE @count <= @rowCount
		BEGIN
			SELECT @column = CAST(Item AS NVARCHAR)
			FROM #StringSplitter 
			WHERE TempId = @count;

			SET @sql = 'SELECT @result = ' + @column + ' FROM ' + @viewName + ' WHERE ' + @keyName + ' = ' + CAST(@keyValue AS NVARCHAR);

			EXECUTE sp_executesql @SQL, N'@result NVARCHAR(1000) OUTPUT', @result OUTPUT;

			INSERT INTO dbo.LetterTemplateDocumentProcessRequest (ProcessRequestId
																, ProcessRequestDateTime
																, ProcessFieldName
																, ProcessFieldValue)
														VALUES (@processRequestId
																, @processRequestDateTime
																, @column
																, CAST(@result AS VARCHAR(1000)))

			SET @count = @count + 1;
		END

		IF OBJECT_ID('tempdb..#StringSplitter', 'U') IS NOT NULL
		BEGIN
			DROP TABLE #StringSplitter;
		END		
		
		RETURN @rowCount;
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP040_14.01_AmendSP_uspGetSelectedColumnsFromViewForKey.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO