/*
	SCRIPT: Amend Table DashboardMeter, Add Column
	Author: Robert Newnham
	Created: 06/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP034_10.02_AmendDashboardMeter.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Table DashboardMeter, Add Column';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		ALTER TABLE dbo.DashboardMeter 
		ADD
			DashboardMeterCategoryId INT NULL
			, CONSTRAINT FK_DashboardMeter_DashboardMeterCategory FOREIGN KEY (DashboardMeterCategoryId) REFERENCES DashboardMeterCategory(Id)


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END