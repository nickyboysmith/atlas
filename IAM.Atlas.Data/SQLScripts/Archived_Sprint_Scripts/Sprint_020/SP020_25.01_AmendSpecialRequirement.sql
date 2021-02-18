/*
 * SCRIPT: Alter Table SpecialRequirement
 * Author: Dan Hough
 * Created: 13/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_25.01_AmendSpecialRequirement.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to SpecialRequirement table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		ALTER TABLE dbo.SpecialRequirement
			ADD [Description] VARCHAR(400) NULL
			, OrganisationId INT NOT NULL
			, CONSTRAINT FK_SpecialRequirement_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;