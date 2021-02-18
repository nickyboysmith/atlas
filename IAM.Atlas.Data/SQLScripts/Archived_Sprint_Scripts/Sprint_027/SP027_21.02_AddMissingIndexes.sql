
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 09/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_21.02_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_UserLoginId' 
				AND object_id = OBJECT_ID('User'))
		BEGIN
		   DROP INDEX [IX_UserLoginId] ON [dbo].[User];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_UserLoginId] ON [dbo].[User]
		(
			[LoginId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_UserLoginIdPassword' 
				AND object_id = OBJECT_ID('User'))
		BEGIN
		   DROP INDEX [IX_UserLoginIdPassword] ON [dbo].[User];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_UserLoginIdPassword] ON [dbo].[User]
		(
			[LoginId], [Password] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_UserName' 
				AND object_id = OBJECT_ID('User'))
		BEGIN
		   DROP INDEX [IX_UserName] ON [dbo].[User];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_UserName] ON [dbo].[User]
		(
			[Name] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_UserEmail' 
				AND object_id = OBJECT_ID('User'))
		BEGIN
		   DROP INDEX [IX_UserEmail] ON [dbo].[User];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_UserEmail] ON [dbo].[User]
		(
			[Email] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_UserChangeLogUserId' 
				AND object_id = OBJECT_ID('UserChangeLog'))
		BEGIN
		   DROP INDEX [IX_UserChangeLogUserId] ON [dbo].[UserChangeLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_UserChangeLogUserId] ON [dbo].[UserChangeLog]
		(
			[UserId] ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

