/*
 * SCRIPT: Add New Columns to Table VehicleType
 * Author: Dan Hough
 * Created: 13/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP036_09.01_AmendTableVehicleCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table VehicleCategory';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.VehicleCategory
		ADD [Description] VARCHAR(400)
			, OrganisationId INT NULL
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_VehicleCategory_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_VehicleCategory_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;