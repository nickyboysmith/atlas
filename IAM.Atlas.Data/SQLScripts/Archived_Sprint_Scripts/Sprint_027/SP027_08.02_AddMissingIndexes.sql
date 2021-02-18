
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 04/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_08.02_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSOffersWithdrawnLogDORSAttendanceRefLicenceNumberDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSOffersWithdrawnLog'))
		BEGIN
		   DROP INDEX [IX_DORSOffersWithdrawnLogDORSAttendanceRefLicenceNumberDORSSchemeId] ON [dbo].[DORSOffersWithdrawnLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSOffersWithdrawnLogDORSAttendanceRefLicenceNumberDORSSchemeId] ON [dbo].[DORSOffersWithdrawnLog]
		(
			[DORSAttendanceRef], [LicenceNumber], [DORSSchemeId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSOffersWithdrawnLogLicenceNumber' 
				AND object_id = OBJECT_ID('DORSOffersWithdrawnLog'))
		BEGIN
		   DROP INDEX [IX_DORSOffersWithdrawnLogLicenceNumber] ON [dbo].[DORSOffersWithdrawnLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSOffersWithdrawnLogLicenceNumber] ON [dbo].[DORSOffersWithdrawnLog]
		(
			[LicenceNumber] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSOffersWithdrawnLogDORSSchemeId' 
				AND object_id = OBJECT_ID('DORSOffersWithdrawnLog'))
		BEGIN
		   DROP INDEX [IX_DORSOffersWithdrawnLogDORSSchemeId] ON [dbo].[DORSOffersWithdrawnLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_DORSOffersWithdrawnLogDORSSchemeId] ON [dbo].[DORSOffersWithdrawnLog]
		(
			[DORSSchemeId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_LastRunLogItemName' 
				AND object_id = OBJECT_ID('LastRunLog'))
		BEGIN
		   DROP INDEX [IX_LastRunLogItemName] ON [dbo].[LastRunLog];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_LastRunLogItemName] ON [dbo].[LastRunLog]
		(
			[ItemName] ASC
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

