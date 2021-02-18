/*
 * SCRIPT: Amend Column Size to Table TaskAction
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_24.01_AmendTableTaskActionAmendColumn_DropConstraintFirst.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Column Size on Table TaskAction';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		DECLARE @table_name nvarchar(256)  
		DECLARE @col_name nvarchar(256)  
		DECLARE @Command  nvarchar(1000)  

		SET @table_name = N'TaskAction'
		SET @col_name = N'Name'

		SELECT @Command = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + d.[name]
		FROM sys.tables t 
		JOIN sys.indexes d ON d.object_id = t.object_id  
		WHERE t.[name] = @table_name 
		AND d.type=2 
		AND d.is_unique=1;

		--print @Command

		EXEC (@Command)
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;