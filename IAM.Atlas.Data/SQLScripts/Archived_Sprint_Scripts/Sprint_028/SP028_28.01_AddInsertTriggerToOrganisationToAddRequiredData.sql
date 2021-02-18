/*
	SCRIPT: Add insert trigger to the Organisation table to insert required data
	Author: Robert Newnham
	Created: 02/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_28.01_AddInsertTriggerToOrganisationToAddRequiredData.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Organisation table to insert required data';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_OrganisationRequiredData_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_OrganisationRequiredData_INSERT];
	END
GO
	CREATE TRIGGER TRG_OrganisationRequiredData_INSERT ON Organisation AFTER INSERT
	AS
		INSERT INTO [dbo].[OrganisationRegion] (OrganisationId, RegionId, Disabled)
		SELECT DISTINCT
			I.Id		AS OrganisationId
			, R.Id		AS RegionId
			, 'False'	AS Disabled
		FROM INSERTED I
		, [dbo].[Region] R
		WHERE NOT EXISTS (SELECT * 
							FROM [dbo].[OrganisationRegion] ORe
							WHERE ORe.OrganisationId = I.Id
							AND ORe.RegionId = R.Id)
		;
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP028_28.01_AddInsertTriggerToOrganisationToAddRequiredData.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

