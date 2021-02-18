/*
 * SCRIPT:  Create VehicleCategory Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_23.03_Create_VehicleCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create VehicleCategory Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'VehicleCategory'
		
		/*
		 *	Create VehicleCategory Table
		 */
		IF OBJECT_ID('dbo.VehicleCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.VehicleCategory;
		END

		CREATE TABLE VehicleCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Name] VARCHAR(100)
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, AddedByUserId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_VehicleCategory_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;