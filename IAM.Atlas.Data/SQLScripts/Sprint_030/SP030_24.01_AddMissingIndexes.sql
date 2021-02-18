
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 20/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_24.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_PaymentCreatedByUserIdDateCreated' 
				AND object_id = OBJECT_ID('Payment'))
		BEGIN
		   DROP INDEX [IX_PaymentCreatedByUserIdDateCreated] ON [dbo].[Payment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_PaymentCreatedByUserIdDateCreated] ON [dbo].[Payment]
		(
			[CreatedByUserId], [DateCreated]  ASC
		) INCLUDE ([Amount], [Refund]) WITH (ONLINE = ON);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseOrganisationId' 
				AND object_id = OBJECT_ID('Course'))
		BEGIN
		   DROP INDEX [IX_CourseOrganisationId] ON [dbo].[Course];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseOrganisationId] ON [dbo].[Course]
		(
			[OrganisationId]  ASC
		) INCLUDE ([CourseTypeCategoryId], [CourseTypeId]) WITH (ONLINE = ON);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

