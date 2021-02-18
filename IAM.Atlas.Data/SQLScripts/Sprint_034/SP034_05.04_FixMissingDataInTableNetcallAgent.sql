/*
 * SCRIPT: Fix Missing Data In Table NetcallAgent
 * Author: Robert Newnham
 * Created: 28/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_05.04_FixMissingDataInTableNetcallAgent.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Fix Missing Data In NetcallAgent Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		UPDATE NA
		SET NA.OrganisationId = OU.OrganisationId
		FROM dbo.NetcallAgent NA
		INNER JOIN dbo.OrganisationUser OU ON OU.UserId = NA.UserId
		WHERE NA.OrganisationId IS NULL;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
