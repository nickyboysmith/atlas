/*
	SCRIPT: Add Columns To Table ClientPreviousId
	Author: Robert Newnham
	Created: 20/06/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP039_14.01_AddColumnToTableClientPreviousId.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Column To Table ClientPreviousId';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.ClientPreviousId 
		ADD DateAdded DateTime NOT NULL DEFAULT GETDATE()
		, PreviousOrgId INT NULL
		, PreviousReferrerOrgId INT NULL
		, PreviousReferrerRgnId INT NULL
		, PreviousProviderRgnId INT NULL
		/************************************************************************************************************************/

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END