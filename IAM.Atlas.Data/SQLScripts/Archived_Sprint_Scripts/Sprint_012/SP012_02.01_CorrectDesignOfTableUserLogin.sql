

/*
	SCRIPT: Correct Design of Table UserLogin
	Author: Robert Newnham
	Created: 04/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP012_02.01_CorrectDesignOfTableUserLogin.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		/*
		 * Check if Table exists
		 */
		IF OBJECT_ID('dbo.UserLogin', 'U') IS NOT NULL
		BEGIN
			DECLARE @TableName Varchar(50)
				, @ColumnName Varchar(50);
				
			--Remove Column called "DateTime"
			IF EXISTS(SELECT * FROM sys.columns 
            WHERE Name = N'DateTime' AND Object_ID = Object_ID(N'UserLogin'))
			BEGIN
			
				SET @TableName = 'UserLogin';
				SET @ColumnName = 'DateTime';
				EXEC dbo.uspDropColumnConstraints @TableName,@ColumnName;
				
				-- Column Exists Drop It
				ALTER TABLE dbo.UserLogin DROP COLUMN [DateTime];
			END
		
			SET @TableName = 'UserLogin';
			SET @ColumnName = 'DateCreated';
			
			EXEC dbo.uspDropColumnConstraints @TableName,@ColumnName;
			
			-- Now Set the default value of the DateCreated
			ALTER TABLE dbo.UserLogin 
			ADD CONSTRAINT DF_UserLogin_DateCreated DEFAULT GetDate() FOR DateCreated;
		END 
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

