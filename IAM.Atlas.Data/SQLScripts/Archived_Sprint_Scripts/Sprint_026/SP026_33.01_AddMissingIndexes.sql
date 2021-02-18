
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 23/09/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP026_33.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueAddressVenueId' 
				AND object_id = OBJECT_ID('VenueAddress'))
		BEGIN
		   DROP INDEX [IX_VenueAddressVenueId] ON [dbo].[VenueAddress];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueAddressVenueId] ON [dbo].[VenueAddress]
		(
			[VenueId]  ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueAddressVenueIdLocationId' 
				AND object_id = OBJECT_ID('VenueAddress'))
		BEGIN
		   DROP INDEX [IX_VenueAddressVenueIdLocationId] ON [dbo].[VenueAddress];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueAddressVenueIdLocationId] ON [dbo].[VenueAddress]
		(
			[VenueId], [LocationId]  ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_VenueAddressLocationId' 
				AND object_id = OBJECT_ID('VenueAddress'))
		BEGIN
		   DROP INDEX [IX_VenueAddressLocationId] ON [dbo].[VenueAddress];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_VenueAddressLocationId] ON [dbo].[VenueAddress]
		(
			[LocationId]  ASC
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

