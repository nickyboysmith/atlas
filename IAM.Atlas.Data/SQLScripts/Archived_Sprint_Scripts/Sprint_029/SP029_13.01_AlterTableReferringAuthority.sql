/*
 * SCRIPT: Alter Table ReferringAuthority 
 * Author: Robert Newnham
 * Created: 17/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_13.01_AlterTableReferringAuthority.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to ReferringAuthority table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ReferringAuthority
		ADD DORSForceId INT NULL
		, CONSTRAINT FK_ReferringAuthority_DORSForce FOREIGN KEY (DORSForceId) REFERENCES DORSForce(Id)
		;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
