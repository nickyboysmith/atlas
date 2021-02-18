/*
 * SCRIPT:  Create TrainerInsurance Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_23.02_Create_TrainerInsurance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerInsurance Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerInsurance'
		
		/*
		 *	Create TrainerInsurance Table
		 */
		IF OBJECT_ID('dbo.TrainerInsurance', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerInsurance;
		END

		CREATE TABLE TrainerInsurance(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, RenewalDate DATE NULL
			, Verified BIT NOT NULL DEFAULT 'False'
			, VerifiedByUserId INT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NOT NULL
			, CONSTRAINT FK_TrainerInsurance_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_TrainerInsurance_User FOREIGN KEY (VerifiedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TrainerInsurance_User2 FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;