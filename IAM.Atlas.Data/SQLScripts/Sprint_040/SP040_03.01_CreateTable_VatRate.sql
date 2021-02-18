/*
	SCRIPT: Create VatRate Table
	Author: Dan Hough
	Created: 30/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP040_03.01_CreateTable_VatRate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create VatRate Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VatRate'
		
		/*
		 *	Create VatRate Table
		 */
		IF OBJECT_ID('dbo.VatRate', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VatRate;
		END

		CREATE TABLE VatRate(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, VATRate FLOAT NOT NULL
			, EffectiveFromDate DATETIME
			, AddedByUserId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_VatRate_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END