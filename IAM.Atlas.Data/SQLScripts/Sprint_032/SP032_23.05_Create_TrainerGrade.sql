/*
 * SCRIPT:  Create TrainerGrade Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_23.05_Create_TrainerGrade.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerGrade Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerGrade'
		
		/*
		 *	Create TrainerGrade Table
		 */
		IF OBJECT_ID('dbo.TrainerGrade', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerGrade;
		END

		CREATE TABLE TrainerGrade(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, Grade INT NOT NULL
			, ADINumber VARCHAR(40) NULL
			, FleetNumber VARCHAR(40) NULL
			, FleetRenewalDate DATETIME NULL
			, LastCheckTestDate DATETIME NULL
			, CONSTRAINT FK_TrainerGrade_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, INDEX IX_TrainerGradeTrainerId NONCLUSTERED (TrainerId)
			, INDEX IX_TrainerGradeGrade NONCLUSTERED (Grade)
			, INDEX IX_TrainerGradeADINumber NONCLUSTERED (ADINumber)
			, INDEX IX_TrainerGradeFleetNumber NONCLUSTERED (FleetNumber)
			, INDEX IX_TrainerGradeFleetRenewalDate NONCLUSTERED (FleetRenewalDate)
			, INDEX IX_TrainerGradeLastCheckTestDate NONCLUSTERED (LastCheckTestDate)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;