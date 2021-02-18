/*
 * SCRIPT:  Create TrainerVehicleCategory Table 
 * Author: Robert Newnham
 * Created: 29/01/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_23.04_Create_TrainerVehicleCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TrainerVehicleCategory Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TrainerVehicleCategory'
		
		/*
		 *	Create TrainerVehicleCategory Table
		 */
		IF OBJECT_ID('dbo.TrainerVehicleCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TrainerVehicleCategory;
		END

		CREATE TABLE TrainerVehicleCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TrainerVehicleId INT NOT NULL
			, VehicleCategoryId INT NOT NULL
			, CONSTRAINT FK_TrainerVehicleCategory_TrainerVehicle FOREIGN KEY (TrainerVehicleId) REFERENCES TrainerVehicle(Id)
			, CONSTRAINT FK_TrainerVehicleCategory_VehicleCategory FOREIGN KEY (VehicleCategoryId) REFERENCES VehicleCategory(Id)
			, INDEX IX_TrainerVehicleCategoryTrainerVehicleId NONCLUSTERED (TrainerVehicleId)
			, INDEX IX_TrainerVehicleCategoryVehicleCategoryId NONCLUSTERED (VehicleCategoryId)
			, INDEX UX_TrainerVehicleCategoryTrainerVehicleIdVehicleCategoryId UNIQUE NONCLUSTERED (TrainerVehicleId, VehicleCategoryId)
			);


		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;