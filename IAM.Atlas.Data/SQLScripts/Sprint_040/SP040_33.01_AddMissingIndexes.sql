
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 14/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_33.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientViewClientIdViewedByUserIdDateTimeViewed' 
				AND object_id = OBJECT_ID('ClientView'))
		BEGIN
		   DROP INDEX [IX_ClientViewClientIdViewedByUserIdDateTimeViewed] ON [dbo].[ClientView];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientViewClientIdViewedByUserIdDateTimeViewed] ON [dbo].[ClientView]
		(
			ClientId, ViewedByUserId, DateTimeViewed
		) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReferringAuthorityClientClientIdReferringAuthorityId' 
				AND object_id = OBJECT_ID('ReferringAuthorityClient'))
		BEGIN
		   DROP INDEX [IX_ReferringAuthorityClientClientIdReferringAuthorityId] ON [dbo].[ReferringAuthorityClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReferringAuthorityClientClientIdReferringAuthorityId] ON [dbo].[ReferringAuthorityClient]
		(
			[ClientId], [ReferringAuthorityId]
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

