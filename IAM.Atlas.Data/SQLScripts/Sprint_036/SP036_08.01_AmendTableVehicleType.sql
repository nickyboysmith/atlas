/*
 * SCRIPT: Add New Columns to Table VehicleType
 * Author: Dan Hough
 * Created: 13/04/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP036_08.01_AmendTableVehicleType.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table VehicleType';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.VehicleType
		ADD [Description] VARCHAR(400)
			, [Disabled] BIT NOT NULL DEFAULT 'False'
			, [Automatic] BIT NOT NULL DEFAULT 'False'
			, OrganisationId INT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, CreatedByUserId INT NULL
			, UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_VehicleType_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			, CONSTRAINT FK_VehicleType_CreatedByUser FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_VehicleType_UpdatedByUser FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
				
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;