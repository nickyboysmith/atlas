/*
	SCRIPT: Create ReconciliationConfiguration Table
	Author: Dan Hough
	Created: 26/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_10.01_CreateTable_ReconciliationConfiguration.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReconciliationConfiguration Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReconciliationConfiguration'
		
		/*
		 *	Create ReconciliationConfiguration Table
		 */
		IF OBJECT_ID('dbo.ReconciliationConfiguration', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReconciliationConfiguration;
		END

		CREATE TABLE ReconciliationConfiguration(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, OrganisationId INT NOT NULL
			, [Name] VARCHAR(100) NOT NULL
			, DateCreated DATETIME NOT NULL
			, CreatedByUserId INT NOT NULL
			, TransactionDateColumnNumber INT
			, TransactionAmountColumnNumber INT
			, Reference1ColumnNumber INT
			, Reference2ColumnNumber INT
			, Reference3ColumnNumber INT
			, CONSTRAINT FK_ReconciliationConfiguration_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_ReconciliationConfiguration_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END