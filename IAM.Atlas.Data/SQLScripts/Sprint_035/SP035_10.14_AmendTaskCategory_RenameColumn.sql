/*
 * SCRIPT: Alter Table TaskCategory, Rename Column
 * Author: Robert Newnham
 * Created: 29/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP035_10.14_AmendTaskCategory_RenameColumn.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Column on TaskCategory Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		-- ClientDORSData
		IF EXISTS(SELECT * 
						FROM sys.columns 
						WHERE Name = N'Disable' 
						and Object_ID = Object_ID(N'TaskCategory')
						)
		BEGIN
			EXECUTE sp_rename N'dbo.TaskCategory.Disable', N'Disabled', 'COLUMN' 
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
