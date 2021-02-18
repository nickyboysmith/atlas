

/*
	SCRIPT: Create Stored Procedure to Drop Constraints against a Column
	Author: Robert Newnham
	Created: 04/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP012_01.01_CreateDropColumnConstraintStoredProcedure.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
	END
ELSE
	BEGIN
		PRINT '******Script Start "' + @ScriptName + '" Failed******';
	END
GO
	/***START OF SCRIPT***/
				
	CREATE PROCEDURE uspDropColumnConstraints 
		@TableName Varchar(50)
		, @ColumnName Varchar(50)
	AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE @ConstraintName nvarchar(200);
		
		SELECT @ConstraintName = Name 
		FROM SYS.DEFAULT_CONSTRAINTS
		WHERE PARENT_OBJECT_ID = OBJECT_ID(@TableName)
		AND PARENT_COLUMN_ID = (SELECT column_id FROM sys.columns
								WHERE NAME = @ColumnName
								AND object_id = OBJECT_ID(@TableName));
								
		IF (@ConstraintName IS NOT NULL)
		BEGIN			
			DECLARE @SQL NVARCHAR(MAX) = N'';
			SELECT @SQL += N'ALTER TABLE ' + @TableName + ' DROP CONSTRAINT ' + @ConstraintName;
			EXECUTE(@SQL);
		END
	END

	GO
			
	/***END OF SCRIPT***/
				
DECLARE @ScriptName VARCHAR(100) = 'SP012_01.01_CreateDropColumnConstraintStoredProcedure.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script End "' + @ScriptName + '" Failed******';
	END
;

