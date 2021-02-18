/*
 * SCRIPT: Create Table OrganisationDORSSite
 * Author: Robert Newnham
 * Created: 23/03/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP035_21.02_CreateTableOrganisationDORSSite.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table OrganisationDORSSite';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationDORSSite'
		
		/*
		 *	Create TaskAction Table
		 */
		IF OBJECT_ID('dbo.OrganisationDORSSite', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationDORSSite;
		END

		CREATE TABLE OrganisationDORSSite(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, DORSSiteId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_OrganisationDORSSite_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_OrganisationDORSSite_DORSSite FOREIGN KEY (DORSSiteId) REFERENCES DORSSite(Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;