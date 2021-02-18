
/*
	SCRIPT: Add Insert and Update trigger to the ReferringAuthority table
	Author: Robert Newnham
	Created: 10/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_23.03_AddInsertAndUpdateTriggerReferringAuthorityTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Insert and Update trigger to the ReferringAuthority table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

	IF OBJECT_ID('dbo.TRG_ReferringAuthority_INSERTUPDATE', 'TR') IS NOT NULL
	BEGIN
		-- Delete if Already Exists
		DROP TRIGGER dbo.[TRG_ReferringAuthority_INSERTUPDATE];
	END
	GO

	CREATE TRIGGER TRG_ReferringAuthority_INSERTUPDATE ON [ReferringAuthority] FOR INSERT, UPDATE
	AS	
		-- If an Organisation has been assigned ensure that it is also in the [ReferringAuthorityOrganisation] table
		INSERT INTO [dbo].[ReferringAuthorityOrganisation] (ReferringAuthorityId, OrganisationId)
		SELECT I.Id AS ReferringAuthorityId
			, I.[AssociatedOrganisationId] AS OrganisationId
		FROM INSERTED I
		LEFT JOIN [dbo].[ReferringAuthorityOrganisation] RAO ON RAO.[ReferringAuthorityId] = I.Id
															AND RAO.[OrganisationId] = I.[AssociatedOrganisationId]
		WHERE I.AssociatedOrganisationId IS NOT NULL
		AND RAO.Id IS NULL -- Not Already on Database Table
		; 
	GO

/***END OF SCRIPT***/

DECLARE @ScriptName VARCHAR(100) = 'SP027_23.03_AddInsertAndUpdateTriggerReferringAuthorityTable.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO