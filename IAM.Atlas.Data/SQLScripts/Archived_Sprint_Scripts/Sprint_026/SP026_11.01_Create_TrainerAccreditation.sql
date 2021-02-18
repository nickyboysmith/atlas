/*
	SCRIPT: Create TrainerAccreditation Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_11.01_Create_TrainerAccreditation.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerAccreditation Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerAccreditation'
		
		/*
		 *	Create TrainerAccreditation Table
		 */
		IF OBJECT_ID('dbo.TrainerAccreditation', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerAccreditation;
		END

		CREATE TABLE TrainerAccreditation(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Title VARCHAR(200)
			, ShortName VARCHAR(40)
			, [Description] VARCHAR(400)
			, DateAdded DATETIME NULL
			, AddedByUserId INT NULL
			, [Disabled] BIT DEFAULT 'False'
			, CONSTRAINT FK_TrainerAccreditation_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;