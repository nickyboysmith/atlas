/*
	SCRIPT: Create TrainerSetting Table
	Author: Dan Hough
	Created: 31/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP018_13.01_Create_TrainerSetting.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create the TrainerSetting Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerSetting'
		
		/*
		 *	Create TrainerSetting Table
		 */
		IF OBJECT_ID('dbo.TrainerSetting', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerSetting;
		END

		CREATE TABLE TrainerSetting(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
		    , TrainerId int NOT NULL
			, ProfileEditing bit DEFAULT 'True'
			, CourseTypeEditing bit DEFAULT 'False'
			CONSTRAINT FK_TrainerSetting_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;