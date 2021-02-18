
/*
 * SCRIPT: Add Missing Indexes to table CourseClientPayment.
 * Author: Robert Newnham
 * Created: 08/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_14.03_AddMissingIndexesCourseClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table CourseClientPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
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
			[PaymentId] ASC
		);
		
		/*******************************************************************************************/

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
			[ClientId] ASC
		);
		
		/*******************************************************************************************/

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
			[CourseId] ASC
		);
		
		/*******************************************************************************************/

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
			[CourseId], [ClientId] ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

