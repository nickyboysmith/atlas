/*
	SCRIPT: Fix bug in update trigger to the SystemStateSummary table
	Author: Robert Newnham
	Created: 06/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP022_40.01_FixUpdateTriggerToSystemStateSummaryTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

	IF OBJECT_ID('dbo.[TRG_SystemStateSummary_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_SystemStateSummary_UPDATE];
		END
	GO

	CREATE TRIGGER TRG_SystemStateSummary_UPDATE ON SystemStateSummary FOR UPDATE
	AS

		INSERT INTO SystemStateSummaryHistory
					(
					SystemStateSummaryId
					, OrganisationId
					, Code
					, [Message]
					, SystemStateId
					, DateUpdated
					, AddedByUserId
					)
		SELECT		
					i.id
					,i.OrganisationId
					, i.Code
					, i.[Message]
					, i.SystemStateId
					, i.DateUpdated
					, i.AddedByUserId

		FROM Inserted i 
		INNER JOIN Deleted d ON i.id = d.id
		WHERE (i.OrganisationId <> d.OrganisationId 
				OR i.Code <> d.Code
				OR i.[Message] <> d.[Message]
				OR i.SystemStateId <> d.SystemStateId
				OR i.AddedByUserId <> d.AddedByUserId
				OR i.DateUpdated <> d.DateUpdated
				)
		;
	GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP022_40.01_FixUpdateTriggerToSystemStateSummaryTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO