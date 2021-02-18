
/*
	SCRIPT: Alter Table Column Sizes
	Author: Robert Newnham
	Created: 28/10/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP010_26.01_AlterTableColumnSizes.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ArchivedEmail
		ALTER COLUMN FromName Varchar(320);
		
		ALTER TABLE dbo.ArchivedEmailTo
		ALTER COLUMN Name Varchar(320);
		
		ALTER TABLE dbo.Client
		ALTER COLUMN FirstName Varchar(320);
		ALTER TABLE dbo.Client
		ALTER COLUMN Surname Varchar(320);
		ALTER TABLE dbo.Client
		ALTER COLUMN OtherNames Varchar(320);
		ALTER TABLE dbo.Client
		ALTER COLUMN DisplayName Varchar(640);
		
		ALTER TABLE dbo.Email
		ALTER COLUMN [Address] Varchar(320);
		
		ALTER TABLE dbo.Organisation
		ALTER COLUMN Name Varchar(320);
		
		ALTER TABLE dbo.OrganisationDisplay
		ALTER COLUMN Name Varchar(320);
		ALTER TABLE dbo.OrganisationDisplay
		ALTER COLUMN DisplayName Varchar(320);
		
		ALTER TABLE dbo.ScheduledEmail
		ALTER COLUMN FromName Varchar(320);
				
		ALTER TABLE dbo.ScheduledEmailTo
		ALTER COLUMN Name Varchar(320);
		
		ALTER TABLE dbo.ScheduledReportEmailTo
		ALTER COLUMN Name Varchar(320);
		
		ALTER TABLE dbo.Trainer
		ALTER COLUMN FirstName Varchar(320);
		ALTER TABLE dbo.Trainer
		ALTER COLUMN Surname Varchar(320);
		ALTER TABLE dbo.Trainer
		ALTER COLUMN OtherNames Varchar(320);
		ALTER TABLE dbo.Trainer
		ALTER COLUMN DisplayName Varchar(640);
		
		ALTER TABLE dbo.[User]
		ALTER COLUMN LoginId Varchar(320);
		ALTER TABLE dbo.[User]
		ALTER COLUMN Name Varchar(320);
		ALTER TABLE dbo.[User]
		ALTER COLUMN Email Varchar(320);
		
		ALTER TABLE dbo.UserFeedback
		ALTER COLUMN Email Varchar(320);
		
		ALTER TABLE dbo.UserLogin
		ALTER COLUMN LoginId Varchar(320);		
		ALTER TABLE dbo.UserLogin
		ALTER COLUMN Browser Varchar(200);		
		ALTER TABLE dbo.UserLogin
		ALTER COLUMN Os Varchar(200);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

