/*
	SCRIPT: Create SystemFeatureGroup Table
	Author: Dan Hough
	Created: 07/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP025_22.01_Create_SystemFeatureGroup.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create SystemFeatureGroup Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'SystemFeatureGroup'
		
		/*
		 *	Create SystemFeatureGroup Table
		 */
		IF OBJECT_ID('dbo.SystemFeatureGroup', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.SystemFeatureGroup;
		END

		CREATE TABLE SystemFeatureGroup(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name VARCHAR(100)
			, [Description]  VARCHAR(100)
			, SystemAdministratorOnly BIT DEFAULT 'FALSE'
			, OrganisationAdministratorOnly BIT DEFAULT 'FALSE'
			, UpdatedByUserId INT
			, DateUpdated DATETIME
			, [Disabled] BIT DEFAULT 'FALSE'
			, CONSTRAINT FK_SystemFeatureGroup_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;