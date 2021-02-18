/*
	SCRIPT: Create ClientOtherRequirement Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_07.01_Create_ClientOtherRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientOtherRequirement Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientOtherRequirement'
		
		/*
		 *	Create ClientOtherRequirement Table
		 */
		IF OBJECT_ID('dbo.ClientOtherRequirement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientOtherRequirement;
		END

		CREATE TABLE ClientOtherRequirement(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, Name varchar(100)
			, DateAdded DateTime
			, AddByUserId int NULL
			, CONSTRAINT FK_ClientOtherRequirement_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientOtherRequirement_User FOREIGN KEY (AddByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;