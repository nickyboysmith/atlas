/*
 * SCRIPT: Alter Table NetcallAgent
 * Author: Robert Newnham
 * Created: 28/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_05.01_AmendTableNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to NetcallAgent Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.NetcallAgent 
		ADD
			OrganisationId INT NULL
			, CONSTRAINT FK_NetcallAgent_Organisation FOREIGN KEY (OrganisationId) REFERENCES Organisation(Id)

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
