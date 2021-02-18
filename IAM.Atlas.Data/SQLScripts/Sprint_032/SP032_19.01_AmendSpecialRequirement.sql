/*
 * SCRIPT: Alter Table SpecialRequirement 
 * Author: John Cocklin
 * Created: 23/01/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP032_19.01_AmendSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to SpecialRequirement Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.SpecialRequirement ADD
			DateCreated		DATETIME NULL,
			CreatedByUserID INT NULL,
			DateUpdated		DATETIME NULL,
			UpdatedByUserId INT NULL

		ALTER TABLE dbo.SpecialRequirement ADD CONSTRAINT
			FK_SpecialRequirement_User FOREIGN KEY (CreatedByUserID) REFERENCES dbo.[User] (Id)
	
		ALTER TABLE dbo.SpecialRequirement ADD CONSTRAINT
			FK_SpecialRequirement_User1 FOREIGN KEY	(UpdatedByUserId) REFERENCES dbo.[User]	(Id)	

		/***END OF SCRIPT***/

		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
