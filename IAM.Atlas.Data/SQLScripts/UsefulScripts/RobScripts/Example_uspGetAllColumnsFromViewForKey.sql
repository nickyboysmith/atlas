
	
	IF OBJECT_ID('dbo.uspGetAllColumnsFromViewForKey', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetAllColumnsFromViewForKey;
	END		
	GO

	/*
		Create uspGetAllColumnsFromViewForKey
	*/

	CREATE PROCEDURE uspGetAllColumnsFromViewForKey (@ViewName VARCHAR(100), @KeyName VARCHAR(100), @keyValue INT)
	AS
	BEGIN
		DECLARE @SQL NVARCHAR(4000);
		SET @SQL = 'SELECT * '
					+ ' FROM [' + @ViewName + '] '
					+ ' WHERE [' + @KeyName + '] = ' + CAST(@keyValue AS VARCHAR)

		EXECUTE sp_executesql @SQL

	END
	GO
	

	EXEC uspGetAllColumnsFromViewForKey 'vwClientDetail', 'ClientId', 4508468
	
	EXEC uspGetAllColumnsFromViewForKey 'vwCourseDetail', 'CourseId', 33694



		
	IF OBJECT_ID('dbo.uspGetAllColumnsFromViewForKey', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspGetAllColumnsFromViewForKey;
	END		
	GO
