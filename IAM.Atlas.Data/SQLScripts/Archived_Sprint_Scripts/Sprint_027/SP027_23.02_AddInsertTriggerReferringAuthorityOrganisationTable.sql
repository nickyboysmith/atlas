
/*
	SCRIPT: Add Insert trigger to the ReferringAuthorityOrganisation table
	Author: Robert Newnham
	Created: 10/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_23.02_AddInsertTriggerReferringAuthorityOrganisationTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert Update trigger to the ReferringAuthorityOrganisation table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.TRG_ReferringAuthorityOrganisation_INSERT', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_ReferringAuthorityOrganisation_INSERT];
	END
	GO

	CREATE TRIGGER TRG_ReferringAuthorityOrganisation_INSERT ON [ReferringAuthorityOrganisation] FOR INSERT
	AS	
		UPDATE RA
		SET RA.AssociatedOrganisationId = I.[OrganisationId]
		FROM [dbo].[ReferringAuthority] RA
		INNER JOIN INSERTED I ON I.[ReferringAuthorityId] = RA.Id
		WHERE RA.AssociatedOrganisationId IS NULL; --Set Default Organisation if missing
	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP027_23.02_AddInsertTriggerReferringAuthorityOrganisationTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO