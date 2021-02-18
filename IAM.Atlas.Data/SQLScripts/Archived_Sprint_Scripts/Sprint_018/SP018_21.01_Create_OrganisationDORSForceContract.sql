/*
	SCRIPT: Create OrganisationDORSForceContract Table
	Author: Dan Hough
	Created: 04/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_21.01_Create_OrganisationDORSForceContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the OrganisationDORSForceContract Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'OrganisationDORSForceContract'
		
		/*
		 *	Create OrganisationDORSForceContract Table
		 */
		IF OBJECT_ID('dbo.OrganisationDORSForceContract', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.OrganisationDORSForceContract;
		END

		CREATE TABLE OrganisationDORSForceContract(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId int NOT NULL
			, DORSForceContractId int NOT NULL
			, CONSTRAINT FK_DOrganisationDORSForceContract_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_DOrganisationDORSForceContract_DORSForceContract FOREIGN KEY (DORSForceContractId) REFERENCES DORSForceContract(Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;