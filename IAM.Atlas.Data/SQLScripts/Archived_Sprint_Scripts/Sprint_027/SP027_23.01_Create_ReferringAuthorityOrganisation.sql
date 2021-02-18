/*
	SCRIPT: Create ReferringAuthorityOrganisation Table
	Author: Robert Newnham
	Created: 10/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_23.01_Create_ReferringAuthorityOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReferringAuthorityOrganisation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReferringAuthorityOrganisation'
		
		/*
		 *	Create ReferringAuthorityOrganisation Table
		 */
		IF OBJECT_ID('dbo.ReferringAuthorityOrganisation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReferringAuthorityOrganisation;
		END

		CREATE TABLE ReferringAuthorityOrganisation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		  , ReferringAuthorityId INT NOT NULL
		  , OrganisationId INT NOT NULL
		  , CONSTRAINT FK_ReferringAuthorityOrganisation_ReferringAuthority FOREIGN KEY (ReferringAuthorityId) REFERENCES [ReferringAuthority](Id)
		  , CONSTRAINT FK_ReferringAuthorityOrganisation_Organisation FOREIGN KEY (OrganisationId) REFERENCES [Organisation](Id)
		  
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;