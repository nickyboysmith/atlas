

/*
	SCRIPT: Add update trigger to the SystemStateSummary table
	Author: Dan Hough
	Created: 21/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_20.01_AddUpdateTriggerToSystemStateSummaryTable.sql';
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
				 (OrganisationId
			    , Code
				, [Message]
				, SystemStateId
				, DateUpdated
				, AddedByUserId
				)
	SELECT		
				i.OrganisationId
			    , i.Code
				, i.[Message]
				, i.SystemStateId
				, i.DateUpdated
				, i.AddedByUserId

	FROM		Inserted i 
	INNER JOIN Deleted d
	ON i.id = d.id AND (i.OrganisationId <> d.OrganisationId 
						OR i.Code <> d.Code
						OR i.[Message] <> d.[Message]
						OR i.SystemStateId <> d.SystemStateId)

GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP017_20.01_AddUpdateTriggerToSystemStateSummaryTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO