/*
	SCRIPT: Create ClientMysteryShopper Table 
	Author: Dan Hough
	Created: 21/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_13.01_Create_ClientMysteryShopper.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientMysteryShopper Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientMysteryShopper'
		
		/*
		 *	Create ClientMysteryShopper Table
		 */
		IF OBJECT_ID('dbo.ClientMysteryShopper', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientMysteryShopper;
		END

		CREATE TABLE ClientMysteryShopper(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId INT NOT NULL
			, AddedByUserId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, CONSTRAINT FK_ClientMysteryShopper_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientMysteryShopper_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			, INDEX UX_ClientMysteryShopperClientId UNIQUE NONCLUSTERED (ClientId)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;