/*
	SCRIPT: Fix Table DORSTrainerScheme Table
	Author: Robert Newnham
	Created: 20/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_03.02_Fix_DORSTrainerScheme.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Fix Table DORSTrainerScheme Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSTrainerScheme'
		
		/*
		 *	Remove DORSTrainerScheme Table
		 */
		IF OBJECT_ID('dbo.DORSTrainerScheme', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSTrainerScheme;
		END
		
		CREATE TABLE DORSTrainerScheme(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DORSTrainerId INT NOT NULL
			, DORSSchemeId INT NOT NULL
			, DORSTrainerLicenceStateId INT
			, DORSLicenceExpiryDate DATETIME
			, CONSTRAINT FK_DORSTrainerScheme_DORSTrainer FOREIGN KEY (DORSTrainerId) REFERENCES DORSTrainer(Id)
			, CONSTRAINT FK_DORSTrainerScheme_DORSScheme FOREIGN KEY (DORSSchemeId) REFERENCES DORSScheme(Id)
			, CONSTRAINT FK_DORSTrainerScheme_DORSTrainerLicenceState FOREIGN KEY (DORSTrainerLicenceStateId) REFERENCES DORSTrainerLicenceState(Id)
		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;