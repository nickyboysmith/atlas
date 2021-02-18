/*
	SCRIPT: Amend Stored Procedure for Data View Columns
	Author: Robert Newnham
	Created: 26/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_18.01_Create_usp_UpdateDataViewColumn.sql';
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
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspUpdateDataViewColumn', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspUpdateDataViewColumn;
END		
GO

/*
	Create uspUpdateDataViewColumn
*/

CREATE PROCEDURE uspUpdateDataViewColumn (@DataViewName VARCHAR(100))
AS
BEGIN

	DECLARE @DataViewId AS INT;
	DECLARE @DataViewTitle AS VARCHAR(100) = dbo.udfSplitSingleWordIntoMultiple( CASE WHEN LEFT(@DataViewName, 2) = 'vw' 
																					THEN RIGHT(@DataViewName, LEN(@DataViewName) - 2)
																					ELSE @DataViewName END
																				);

	--Create Data View if it does not exist
	INSERT INTO [dbo].[DataView] ([Name], Title, [Description], DateAdded, Enabled, AddedByUserId)
	SELECT 
		IS_T.TABLE_NAME							AS [Name]
		, @DataViewTitle						AS Title
		, (CASE WHEN IS_T.Table_Type = 'VIEW'
				THEN 'Date View for ' + @DataViewTitle
				ELSE 'Data Table for ' + @DataViewTitle
				END)							AS [Description]
		, GETDATE()								AS DateAdded
		, 'True'								AS [Enabled]
		, dbo.udfGetSystemUserId()				AS AddedByUserId
	FROM INFORMATION_SCHEMA.TABLES IS_T
	LEFT JOIN dbo.DataView DV ON DV.[Name] = IS_T.TABLE_NAME
	WHERE IS_T.TABLE_NAME = @DataViewName
	AND DV.Id IS NULL;

	SELECT @DataViewId = Id FROM dbo.DataView WHERE [Name] = @DataViewName;

	INSERT INTO [dbo].[DataViewColumn] (DataViewId, [Name], Title, [Description], DataType, Removed)
	SELECT 
		@DataViewId																AS DataViewId
		, IS_C.Column_Name														AS [Name]
		, dbo.udfSplitSingleWordIntoMultiple(IS_C.Column_Name)					AS Title
		, 'Column: ' + dbo.udfSplitSingleWordIntoMultiple(IS_C.Column_Name)		AS [Description]
		, (CASE IS_C.DATA_TYPE WHEN 'bit' THEN 'Boolean'
								WHEN 'date' THEN 'DateTime'
								WHEN 'datetime' THEN 'DateTime'
								WHEN 'time'	THEN 'DateTime'
								WHEN 'int' THEN 'Number'
								WHEN 'money' THEN 'Currency'
								WHEN 'nvarchar' THEN 'Text'
								WHEN 'varchar' THEN 'Text'
								ELSE IS_C.DATA_TYPE
								END)											AS DataType 
		, 'False'																AS Removed
	FROM INFORMATION_SCHEMA.TABLES IS_T
	INNER JOIN INFORMATION_SCHEMA.COLUMNS IS_C ON IS_C.TABLE_NAME = IS_T.TABLE_NAME
	LEFT JOIN [dbo].[DataViewColumn] DVC ON DVC.DataViewId = @DataViewId
										AND DVC.[Name] = IS_C.Column_Name
	WHERE IS_T.TABLE_NAME = @DataViewName
	AND DVC.Id IS NULL;
     
      
	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP036_18.01_Create_usp_UpdateDataViewColumn.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO