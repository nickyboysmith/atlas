/*
	SCRIPT: Remove trigger to the Organisation table Which is no Longer Needed
	Author: Robert Newnham
	Created: 01/02/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP032_30.03_RemoveTriggerToOrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_OrganisationRequiredData_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationRequiredData_INSERT];
	END
GO

IF OBJECT_ID('dbo.[TRG_OrganisationToAddOrganisationSystemTaskMessaging_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationToAddOrganisationSystemTaskMessaging_INSERT];
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP032_30.03_RemoveTriggerToOrganisationTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO