/*
	SCRIPT: Create Reconciliation Table
	Author: Dan Hough
	Created: 26/07/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP041_10.02_CreateTable_Reconciliation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Reconciliation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'Reconciliation'
		
		/*
		 *	Create Reconciliation Table
		 */
		IF OBJECT_ID('dbo.Reconciliation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.Reconciliation;
		END

		CREATE TABLE Reconciliation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateCreated DATETIME NOT NULL
			, CreatedByUserId INT NOT NULL
			, [Reference] VARCHAR(100) NULL
			, ReconciliationConfigurationId INT NOT NULL
			, ImportedFileName VARCHAR(200) 
			, PaymentStartDate DATETIME NOT NULL
			, PaymentEndDate DATETIME NOT NULL
			, CONSTRAINT FK_Reconciliation_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Reconciliation_ReconciliationConfiguration FOREIGN KEY (ReconciliationConfigurationId) REFERENCES ReconciliationConfiguration(Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END