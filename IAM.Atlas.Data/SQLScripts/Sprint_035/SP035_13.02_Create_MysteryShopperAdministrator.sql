/*
	SCRIPT: Create MysteryShopperAdministrator Table 
	Author: Dan Hough
	Created: 21/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_13.02_Create_MysteryShopperAdministrator.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create MysteryShopperAdministrator Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'MysteryShopperAdministrator'
		
		/*
		 *	Create MysteryShopperAdministrator Table
		 */
		IF OBJECT_ID('dbo.MysteryShopperAdministrator', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.MysteryShopperAdministrator;
		END

		CREATE TABLE MysteryShopperAdministrator(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, UserId INT NOT NULL
			, AddedByUserId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_MysteryShopperAdministrator_User FOREIGN KEY (UserId) REFERENCES [User](Id)	
			, CONSTRAINT FK_MysteryShopperAdministrator_AddedByUser FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			, INDEX UX_MysteryShopperAdministratorUserId UNIQUE NONCLUSTERED (UserId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;