/*
	SCRIPT:  Create TrainerVehicleRemove Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.04_Create_TrainerVehicleRemove.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerVehicleRemove Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVehicleRemove'
		
		/*
		 *	Create TrainerVehicleRemove Table
		 */
		IF OBJECT_ID('dbo.TrainerVehicleRemove', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVehicleRemove;
		END

		CREATE TABLE TrainerVehicleRemove(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerVehicleId INT NOT NULL
			, DateRemoved DATETIME NOT NULL DEFAULT GETDATE()
			, RemovedByUserId INT NOT NULL
			, CONSTRAINT FK_TrainerVehicleRemove_TrainerVehicle FOREIGN KEY (TrainerVehicleId) REFERENCES TrainerVehicle(Id)
			, CONSTRAINT FK_TrainerVehicleRemove_User FOREIGN KEY (RemovedByUserId) REFERENCES [User](Id)
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;