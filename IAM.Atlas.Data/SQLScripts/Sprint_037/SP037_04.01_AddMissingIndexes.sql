
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 26/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_04.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportRequestReportId' 
				AND object_id = OBJECT_ID('ReportRequest'))
		BEGIN
		   DROP INDEX [IX_ReportRequestReportId] ON [dbo].[ReportRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportRequestReportId] ON [dbo].[ReportRequest]
		(
			[ReportId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportRequestOrganisationId' 
				AND object_id = OBJECT_ID('ReportRequest'))
		BEGIN
		   DROP INDEX [IX_ReportRequestOrganisationId] ON [dbo].[ReportRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportRequestOrganisationId] ON [dbo].[ReportRequest]
		(
			[OrganisationId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportRequestOrganisationIdReportId' 
				AND object_id = OBJECT_ID('ReportRequest'))
		BEGIN
		   DROP INDEX [IX_ReportRequestOrganisationIdReportId] ON [dbo].[ReportRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportRequestOrganisationIdReportId] ON [dbo].[ReportRequest]
		(
			[OrganisationId], [ReportId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportRequestDateCreated' 
				AND object_id = OBJECT_ID('ReportRequest'))
		BEGIN
		   DROP INDEX [IX_ReportRequestDateCreated] ON [dbo].[ReportRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportRequestDateCreated] ON [dbo].[ReportRequest]
		(
			[DateCreated] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportRequestParameterReportRequestId' 
				AND object_id = OBJECT_ID('ReportRequestParameter'))
		BEGIN
		   DROP INDEX [IX_ReportRequestParameterReportRequestId] ON [dbo].[ReportRequestParameter];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportRequestParameterReportRequestId] ON [dbo].[ReportRequestParameter]
		(
			[ReportRequestId] ASC
		) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ReportDataGridReportId' 
				AND object_id = OBJECT_ID('ReportDataGrid'))
		BEGIN
		   DROP INDEX [IX_ReportDataGridReportId] ON [dbo].[ReportDataGrid];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ReportDataGridReportId] ON [dbo].[ReportDataGrid]
		(
			[ReportId] ASC
		) ;
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

