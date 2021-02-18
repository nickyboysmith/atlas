/*
 * SCRIPT: Alter Table ReferringAuthority
 * Author: Dan Hough
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_01.01_AmendReferringAuthority.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to ReferringAuthority table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		
		ALTER TABLE dbo.ReferringAuthority
			ADD [Disabled] bit DEFAULT 0
		  , AssociatedOrganisationId int
		  , CONSTRAINT FK_ReferringAuthority_Organisation FOREIGN KEY (AssociatedOrganisationId) REFERENCES Organisation(Id)
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;