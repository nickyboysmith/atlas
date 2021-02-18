
	
	IF OBJECT_ID('dbo.uspGetSelectedColumnsFromViewForKey', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetSelectedColumnsFromViewForKey;
	END		
	GO
	
	/*
		Create uspGetSelectedColumnsFromViewForKey
	*/

	CREATE PROCEDURE uspGetSelectedColumnsFromViewForKey (@ViewName VARCHAR(100), @SelectedColumnNames VARCHAR(1000), @KeyName VARCHAR(100), @keyValue INT)
	AS
	BEGIN
		DECLARE @SQL NVARCHAR(4000);
		SET @SQL = 'SELECT [' + REPLACE(@SelectedColumnNames, ',', '],[') + '] '
					+ ' FROM [' + @ViewName + '] '
					+ ' WHERE [' + @KeyName + '] = ' + CAST(@keyValue AS VARCHAR)

		EXECUTE sp_executesql @SQL

	END
	GO
	
	

	EXEC uspGetSelectedColumnsFromViewForKey 'vwClientDetail', 'ClientId,Title,FirstName,Surname,OtherNames,DisplayName,DateOfBirth', 'ClientId', 4508468
	
	EXEC uspGetSelectedColumnsFromViewForKey 'vwCourseDetail', 'CourseId,CourseType,CourseReference,StartDate', 'CourseId', 33694



		
	IF OBJECT_ID('dbo.uspGetSelectedColumnsFromViewForKey', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetSelectedColumnsFromViewForKey;
	END		
	GO
