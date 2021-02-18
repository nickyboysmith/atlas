/*
 * SCRIPT: Amend Columns on Table Report
 * Author: Robert Newnham
 * Created:09/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP036_04.01_AmendTableReport.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend Columns on Table Report';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE [dbo].[Report]
		ALTER COLUMN [Description] VARCHAR(800) NULL;
		
		ALTER TABLE [dbo].[Report]
		ALTER COLUMN [Title] VARCHAR(200) NOT NULL;
		
		UPDATE dbo.Report
		SET DateCreated = GETDATE() - 20
		WHERE DateCreated IS NULL;

		ALTER TABLE [dbo].[Report]
		ALTER COLUMN DateCreated DATETIME NOT NULL;
		
		IF OBJECT_ID('DF_Report_DateCreated', 'D') IS NULL
		BEGIN
			ALTER TABLE [dbo].[Report]
			ADD CONSTRAINT DF_Report_DateCreated DEFAULT GETDATE() FOR DateCreated;
		END
		UPDATE dbo.Report
		SET AtlasSystemReport = 'False'
		WHERE AtlasSystemReport IS NULL;

		ALTER TABLE [dbo].[Report]
		ALTER COLUMN AtlasSystemReport BIT NOT NULL;
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;