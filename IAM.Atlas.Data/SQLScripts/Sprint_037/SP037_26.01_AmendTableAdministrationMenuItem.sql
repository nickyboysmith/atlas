/*
 * SCRIPT: Add New Columns to Table AdministrationMenuItem
 * Author: Robert Newnham
 * Created: 15/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_26.01_AmendTableAdministrationMenuItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table AdministrationMenuItem';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.AdministrationMenuItem
		ADD AssignToAllSystemsAdmins BIT NOT NULL DEFAULT 'True'
		, AssignAllOrganisationAdmin BIT NOT NULL DEFAULT 'True'
		, AssignWholeOrganisation BIT NOT NULL DEFAULT 'False'
		, ExcludeReferringAuthorityOrganisation BIT NOT NULL DEFAULT 'True';
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;