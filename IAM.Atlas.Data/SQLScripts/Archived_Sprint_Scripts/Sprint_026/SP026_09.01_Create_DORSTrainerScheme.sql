/*
	SCRIPT: Create DORSTrainerScheme Table
	Author: Dan Hough
	Created: 09/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_09.01_Create_DORSTrainerScheme.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DORSTrainerScheme Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerScheme'
		
		/*
		 *	Create DORSTrainerScheme Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerScheme', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerScheme;
		END

		CREATE TABLE DORSTrainerScheme(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSTrainerId INT
			, DORSTrainerStatusId INT NULL
			, DORSSchemeId INT
			, CONSTRAINT FK_DORSTrainerScheme_DORSTrainer FOREIGN KEY (DORSTrainerId) REFERENCES DORSTrainer(Id)
			, CONSTRAINT FK_DORSTrainerScheme_DORSTrainerStatus FOREIGN KEY (DORSTrainerStatusId) REFERENCES DORSTrainerStatus(Id)
			, CONSTRAINT FK_DORSTrainerScheme_DORSScheme FOREIGN KEY (DORSSchemeId) REFERENCES DORSScheme(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;