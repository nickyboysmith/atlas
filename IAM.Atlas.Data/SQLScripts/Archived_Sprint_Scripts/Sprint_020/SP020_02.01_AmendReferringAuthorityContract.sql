/*
 * SCRIPT: Alter Table ReferringAuthorityContract
 * Author: Dan Hough
 * Created: 05/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_02.01_AmendReferringAuthorityContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename column in ReferringAuthorityContract table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		EXEC sp_rename 'dbo.ReferringAuthorityContract.OrganisationId', 'ContractedOrganisationId', 'COLUMN';
			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;