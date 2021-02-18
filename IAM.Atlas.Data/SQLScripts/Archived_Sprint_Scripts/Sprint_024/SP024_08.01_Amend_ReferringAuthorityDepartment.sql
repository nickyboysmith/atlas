/*
	SCRIPT: Amend ReferringAuthorityDepartment Table
	Author: Dan Murray	
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_08.01_Amend_ReferringAuthorityDepartment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend ReferringAuthorityDepartment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReferringAuthorityDepartment
			ALTER COLUMN [Description] VARCHAR(400);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;