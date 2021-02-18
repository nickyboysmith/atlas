
/*
	SCRIPT: Create UserLogin and Logging Stored Procedures
	Author: Dan Murray
	Created: 23/04/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP002_02.01_RepairConstraints.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (1 = 1)--(dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 * Robert to fix script
		 */

		/*
		Repair Lost Constraints
		*/
		--ALTER TABLE OrganisationUser ADD CONSTRAINT FK_OrganisationUser_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id);
		--ALTER TABLE OrganisationUser ADD CONSTRAINT FK_OrganisationUser_User FOREIGN KEY (UserId) REFERENCES [User](Id);
		--ALTER TABLE OrganisationUser ADD CONSTRAINT UC_OrganisationUser UNIQUE (OrganisationId, UserId);
		
		--ALTER TABLE DataViewColumns ADD CONSTRAINT FK_DataViewColumns_DataViews FOREIGN KEY (DataViewId) REFERENCES DataViews(Id);
		--ALTER TABLE DataViewLog ADD CONSTRAINT FK_DataViewLog_DataView FOREIGN KEY (DataViewId) REFERENCES DataViews(Id);
		
		--ALTER TABLE ReportsReportCategory ADD CONSTRAINT FK_ReportsReportCategory_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		--ALTER TABLE ReportsReportCategory ADD CONSTRAINT FK_ReportsReportCategory_ReportCategory FOREIGN KEY (ReportCategoryId) REFERENCES ReportCategory(Id);
		
		--ALTER TABLE ReportDataGrid ADD CONSTRAINT FK_ReportDataGrid_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		--ALTER TABLE ReportDataGrid ADD CONSTRAINT FK_ReportDataGrid_DataViews FOREIGN KEY (DataViewId) REFERENCES DataViews(Id);
		
		--ALTER TABLE ReportDataGridColumns ADD CONSTRAINT FK_ReportDataGridColumns_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id);
		
		--ALTER TABLE ReportExportOption ADD CONSTRAINT FK_ReportExportOption_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		
		--ALTER TABLE ReportChart ADD CONSTRAINT FK_ReportChart_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		
		--ALTER TABLE ReportChartColumn ADD CONSTRAINT FK_ReportChartColumn_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id);
		
		--ALTER TABLE DashboardReport ADD CONSTRAINT FK_DashboardReport_Dashboard FOREIGN KEY (DashboardId) REFERENCES Dashboard(Id);
		--ALTER TABLE DashboardReport ADD CONSTRAINT FK_DashboardReport_Report FOREIGN KEY (ReportId) REFERENCES Report(Id);
		--ALTER TABLE DashboardColumn ADD CONSTRAINT FK_DashboardColumn_DataViewColumns FOREIGN KEY (DataViewColumnId) REFERENCES DataViewColumns(Id);
		--ALTER TABLE DashboardGroupItem ADD CONSTRAINT FK_DashboardGroupItem_DashboardGroup FOREIGN KEY (DashboardGroupId) REFERENCES DashboardGroup(Id);
		--ALTER TABLE DashboardGroupItem ADD CONSTRAINT FK_DashboardGroupItem_Dashboard FOREIGN KEY (DashboardId) REFERENCES Dashboard(Id);
		--ALTER TABLE DashboardGroupUser ADD CONSTRAINT FK_DashboardGroupUser_DashboardGroup FOREIGN KEY (DashboardGroupId) REFERENCES DashboardGroup(Id);
		--ALTER TABLE DashboardGroupUser ADD CONSTRAINT FK_DashboardGroupUser_User FOREIGN KEY (UserId) REFERENCES [User](Id);
		
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;




