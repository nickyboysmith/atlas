/*
	SCRIPT:  Create TrainerInstructorRole Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.06_Create_TrainerInstructorRole.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerInstructorRole Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerInstructorRole'
		
		/*
		 *	Create TrainerInstructorRole Table
		 */
		IF OBJECT_ID('dbo.TrainerInstructorRole', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerInstructorRole;
		END

		CREATE TABLE TrainerInstructorRole(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, InstructorRoleId INT NOT NULL
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, AddedByUserId INT NOT NULL
			, CONSTRAINT FK_TrainerInstructorRole_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_TrainerInstructorRole_InstructorRole FOREIGN KEY (InstructorRoleId) REFERENCES InstructorRole(Id)
			, CONSTRAINT FK_TrainerInstructorRole_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;