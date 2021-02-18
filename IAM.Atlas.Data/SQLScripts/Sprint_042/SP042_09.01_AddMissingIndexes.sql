
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 22/08/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP042_09.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_EmailServiceEmailsSentDateSent' 
				AND object_id = OBJECT_ID('EmailServiceEmailsSent'))
		BEGIN
		   DROP INDEX [IX_EmailServiceEmailsSentDateSent] ON [dbo].[EmailServiceEmailsSent];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_EmailServiceEmailsSentDateSent] ON [dbo].[EmailServiceEmailsSent]
		(
			[DateSent] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LoginSessionAuthTokenExpiresOn' 
				AND object_id = OBJECT_ID('LoginSession'))
		BEGIN
		   DROP INDEX [IX_LoginSessionAuthTokenExpiresOn] ON [dbo].[LoginSession];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LoginSessionAuthTokenExpiresOn] ON [dbo].[LoginSession]
		(
			[AuthToken], [ExpiresOn] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientScheduledEmailClientId' 
				AND object_id = OBJECT_ID('ClientScheduledEmail'))
		BEGIN
		   DROP INDEX [IX_ClientScheduledEmailClientId] ON [dbo].[ClientScheduledEmail];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientScheduledEmailClientId] ON [dbo].[ClientScheduledEmail]
		(
			[ClientId] ASC
		) WITH (ONLINE = ON) ;
		/************************************************************************************/



		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

