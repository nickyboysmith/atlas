/*
	SCRIPT: Create SystemInformation Table
	Author: Dan Hough
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_25.01_Create_SystemInformation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemInformation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemInformation'
		
		/*
		 *	Create SystemInformation Table
		 */
		IF OBJECT_ID('dbo.SystemInformation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemInformation;
		END

		CREATE TABLE SystemInformation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, SearchContent VARCHAR(400)
			, TitleContent VARCHAR(200)
			, DisplayContent VARCHAR(2000)
			, OrganisationId INT NULL
			, SystemFeatureItemId INT NULL
			, CONSTRAINT FK_SystemInformation_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_SystemInformation_SystemFeatureItem FOREIGN KEY (SystemFeatureItemId) REFERENCES SystemFeatureItem(Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;