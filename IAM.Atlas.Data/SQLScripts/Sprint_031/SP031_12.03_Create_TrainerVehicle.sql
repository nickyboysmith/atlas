/*
	SCRIPT:  Create TrainerVehicle Table 
	Author: Dan Hough
	Created: 29/12/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP031_12.03_Create_TrainerVehicle.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerVehicle Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVehicle'
		
		/*
		 *	Create TrainerVehicle Table
		 */
		IF OBJECT_ID('dbo.TrainerVehicle', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVehicle;
		END

		CREATE TABLE TrainerVehicle(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerId INT NOT NULL
			, VehicleTypeId INT NOT NULL
			, NumberPlate VARCHAR(20)
			, [Description] VARCHAR(200)
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, AddedByUserId INT NOT NULL
			, CONSTRAINT FK_TrainerVehicle_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id)
			, CONSTRAINT FK_TrainerVehicle_VehicleType FOREIGN KEY (VehicleTypeId) REFERENCES VehicleType(Id)
			, CONSTRAINT FK_TrainerVehicle_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
			);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;