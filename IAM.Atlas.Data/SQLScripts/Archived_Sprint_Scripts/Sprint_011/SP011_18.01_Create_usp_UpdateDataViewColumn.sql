/*
	SCRIPT: Create a stored procedure to update dataview column
	Author: Nick Smith
	Created: 14/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_18.01_Create_usp_UpdateDataViewColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create a stored procedure to update dataview column';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.usp_UpdateDataViewColumn', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.usp_UpdateDataViewColumn;
END		
GO

/*
	Create usp_UpdateDataViewColumn
*/

CREATE PROCEDURE usp_UpdateDataViewColumn (@DataViewId int, @DataViewName varchar(100))
AS
BEGIN
	BEGIN TRAN

-- Does views or tables

MERGE INTO dbo.DataViewColumn AS TGT
USING (SELECT @DataViewId AS DataViewId, isc.Column_Name AS ColumnName, isc.Data_Type AS DataType 
FROM   information_schema.columns isc
	INNER JOIN information_schema.tables ist ON
	ist.TABLE_NAME = isc.TABLE_NAME
	AND (ist.Table_Type = 'VIEW' OR ist.Table_Type = 'BASE TABLE')
WHERE  
	ist.Table_Name = @DataViewName) AS SRC
	ON TGT.DataViewId = SRC.DataViewId
		AND TGT.Name = SRC.ColumnName
	WHEN MATCHED
		THEN UPDATE SET TGT.Removed = 'false' 
	WHEN NOT MATCHED BY SOURCE AND TGT.DataViewId = @DataViewId
		THEN UPDATE SET TGT.Removed = 'true' 
	WHEN NOT MATCHED BY TARGET
		THEN INSERT (
			[DataViewId]
           ,[Name]
           ,[Title]
           ,[Description]
           ,[DataType]
           ,[Removed])
           VALUES
           (@DataViewId
           ,SRC.ColumnName
           ,SRC.ColumnName
           ,SRC.ColumnName
           ,CASE SRC.DataType WHEN 'bit' THEN 'Boolean'
								WHEN 'date' THEN 'DateTime'
								WHEN 'datetime' THEN 'DateTime'
								WHEN 'time'	THEN 'DateTime'
								WHEN 'int' THEN 'Number'
								WHEN 'money' THEN 'Currency'
								WHEN 'nvarchar' THEN 'Text'
								WHEN 'varchar' THEN 'Text'
								END
           ,'false');
   
     
      
	IF @@ERROR <> 0 
				BEGIN 
					ROLLBACK TRAN 
				END	
	COMMIT TRAN
END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP011_18.01_Create_usp_UpdateDataViewColumn.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO