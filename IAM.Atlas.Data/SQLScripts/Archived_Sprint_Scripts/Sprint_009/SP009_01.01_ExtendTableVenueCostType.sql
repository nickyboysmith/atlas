

/*
	SCRIPT: Add a 'disabled' boolean column and an 'OrganisationId' int column (with FK to Organisation Table) to the VenueCostType table
	Author: Dan Murray
	Created: 21/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_01.01_ExtendTableVenueCostType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add a disabled boolean column and an OrganisationId int column (with FK to Organisation Table) to the VenueCostType table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table PaymentProvider
		*/
		DELETE FROM dbo.VenueCostType

		ALTER TABLE dbo.VenueCostType	
		ADD [Disabled] bit DEFAULT 'false'
		, OrganisationId int NOT NULL
		, CONSTRAINT FK_VenueCostType_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id);
		
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

