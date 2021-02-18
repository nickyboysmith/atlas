/*
	SCRIPT: Add update and Insert trigger on the DORSConnection table
	Author: Dan Hough
	Created: 22/03/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP017_22.01_AddUpdateTriggerToDORSConnection.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add update and Insert trigger on the DORSConnection table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_DORSConnection_UPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DORSConnection_UPDATE];
		END
GO
		CREATE TRIGGER TRG_DORSConnection_UPDATE ON DORSConnection AFTER UPDATE
AS

BEGIN

	UPDATE SSS

	SET   Code = 'DORS'
		, [Message] = 'DORS Enabled'
		, SystemStateId = 0
		, DateUpdated = GETDATE()
		, AddedByUserId = i.UpdatedByUserId  
	FROM	SystemStateSummary SSS 
	INNER JOIN Inserted i ON SSS.OrganisationId = i.OrganisationId
	INNER JOIN Deleted d ON i.id = d.id AND i.[enabled] <> d.[enabled] AND i.[enabled] = 'true'
	WHERE SSS.Code = 'DORS'

	UPDATE SSS

	SET   Code = 'DORS'
		, [Message] = 'DORS disabled'
		, SystemStateId = 4
		, DateUpdated = GETDATE()
		, AddedByUserId = i.UpdatedByUserId  
	FROM	SystemStateSummary SSS 
	INNER JOIN Inserted i ON SSS.OrganisationId = i.OrganisationId
	INNER JOIN Deleted d ON i.id = d.id AND i.[enabled] <> d.[enabled] AND i.[enabled] = 'false'
	WHERE SSS.Code = 'DORS'


	INSERT INTO  SystemStateSummary
					 (OrganisationId
					, Code
					, [Message]
					, SystemStateId
					, DateUpdated
					, AddedByUserId)
				
				 
	SELECT		 i.OrganisationId
				, 'DORS' as Code
				, CASE WHEN i.[Enabled] = 1 THEN 'DORS Enabled' WHEN i.[Enabled] = 0 THEN 'DORS Disabled' ELSE NULL END AS [Message]
				, CASE WHEN i.[Enabled] = 1 THEN 0 WHEN i.[Enabled] = 0 THEN 4 ELSE NULL END AS SystemStateId
				, DateUpdated = GETDATE()
				, i.UpdatedByUserId as AddedByUserId
	FROM		Inserted i 
	INNER JOIN Deleted d
	ON i.id = d.id 
	WHERE NOT EXISTS (Select * From SystemStateSummary SSS WHERE SSS.OrganisationId = i.OrganisationId AND SSS.Code = 'DORS')
END

GO


/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP017_22.01_AddUpdateTriggerToDORSConnection.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO