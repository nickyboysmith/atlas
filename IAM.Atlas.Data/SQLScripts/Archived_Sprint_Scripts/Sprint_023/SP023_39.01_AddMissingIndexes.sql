
/*
 * SCRIPT: Add Missing Indexes to tables CourseClientRemoved.
 * Author: Robert Newnham
 * Created: 27/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_39.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to table CourseClientRemoved';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientRemovedCourseId' 
				AND object_id = OBJECT_ID('CourseClientRemoved'))
		BEGIN
		   DROP INDEX [IX_CourseClientRemovedCourseId] ON [dbo].[CourseClientRemoved];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientRemovedCourseId] ON [dbo].[CourseClientRemoved]
		(
			[CourseId]  ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientRemovedClientId' 
				AND object_id = OBJECT_ID('CourseClientRemoved'))
		BEGIN
		   DROP INDEX [IX_CourseClientRemovedClientId] ON [dbo].[CourseClientRemoved];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientRemovedClientId] ON [dbo].[CourseClientRemoved]
		(
			[ClientId]  ASC
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientRemovedCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseClientRemoved'))
		BEGIN
		   DROP INDEX [IX_CourseClientRemovedCourseIdClientId] ON [dbo].[CourseClientRemoved];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientRemovedCourseIdClientId] ON [dbo].[CourseClientRemoved]
		(
			[CourseId], [ClientId]  ASC
		);
		/******************************************************************************************************/

		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientPaymentPaymentId' 
				AND object_id = OBJECT_ID('CourseClientPayment'))
		BEGIN
		   DROP INDEX [IX_CourseClientPaymentPaymentId] ON [dbo].[CourseClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientPaymentPaymentId] ON [dbo].[CourseClientPayment]
		(
			PaymentId  ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientPaymentCourseId' 
				AND object_id = OBJECT_ID('CourseClientPayment'))
		BEGIN
		   DROP INDEX [IX_CourseClientPaymentCourseId] ON [dbo].[CourseClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientPaymentCourseId] ON [dbo].[CourseClientPayment]
		(
			[CourseId]  ASC
		);
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientPaymentClientId' 
				AND object_id = OBJECT_ID('CourseClientPayment'))
		BEGIN
		   DROP INDEX [IX_CourseClientPaymentClientId] ON [dbo].[CourseClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientPaymentClientId] ON [dbo].[CourseClientPayment]
		(
			[ClientId]  ASC
		);

		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseClientPaymentCourseIdClientId' 
				AND object_id = OBJECT_ID('CourseClientPayment'))
		BEGIN
		   DROP INDEX [IX_CourseClientPaymentCourseIdClientId] ON [dbo].[CourseClientPayment];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseClientPaymentCourseIdClientId] ON [dbo].[CourseClientPayment]
		(
			[CourseId], [ClientId]  ASC
		);
		/******************************************************************************************************/


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

