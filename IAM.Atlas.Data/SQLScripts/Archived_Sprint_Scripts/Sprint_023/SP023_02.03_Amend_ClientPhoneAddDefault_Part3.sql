/*
 * SCRIPT: Alter Table ClientPhone - Part 3
 * Author: Robert Newnham
 * Created: 08/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_02.03_Amend_ClientPhoneAddDefault_Part3.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to table ClientPhone';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientIdDefaultNumber' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone]
		(
			[ClientId], [DefaultNumber] ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientIdDateAdded' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientIdDateAdded] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientIdDateAdded] ON [dbo].[ClientPhone]
		(
			[ClientId], [DateAdded] ASC
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneDateAdded' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneDateAdded] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneDateAdded] ON [dbo].[ClientPhone]
		(
			[DateAdded] ASC
		);
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;