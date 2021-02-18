/*
	SCRIPT: Create ClientSpecialRequirement Table
	Author: Dan Hough
	Created: 05/05/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP020_06.01_Create_ClientSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientSpecialRequirement Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientSpecialRequirement'
		
		/*
		 *	Create ClientSpecialRequirement Table
		 */
		IF OBJECT_ID('dbo.ClientSpecialRequirement', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientSpecialRequirement;
		END

		CREATE TABLE ClientSpecialRequirement(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ClientId int
			, SpecialRequirementId int
			, DateAdded DateTime
			, AddByUserId int NULL
			, CONSTRAINT FK_ClientSpecialRequirement_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
			, CONSTRAINT FK_ClientSpecialRequirement_SpecialRequirement FOREIGN KEY (SpecialRequirementId) REFERENCES SpecialRequirement(Id)
			, CONSTRAINT FK_ClientSpecialRequirement_User FOREIGN KEY (AddByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;