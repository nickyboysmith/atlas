/*
 * SCRIPT: Add insert trigger to the LetterTemplate table
 * Author: Robert Newnham
 * Created: 19/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_05.02_CreateInsertTriggerToLetterTemplate.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the LetterTemplate table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_LetterTemplate_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_LetterTemplate_INSERT];
	END
GO

	CREATE TRIGGER TRG_LetterTemplate_INSERT ON LetterTemplate FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'LetterTemplate', 'TRG_LetterTemplate_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			--Disable The Previous Versions of Template
			UPDATE ET
			SET ET.[Enabled] = 'False'
			FROM INSERTED I
			INNER JOIN dbo.LetterTemplate ET		ON ET.OrganisationId = I.OrganisationId
													AND ET.LetterCategoryId = I.LetterCategoryId
			WHERE I.Id <> ET.Id
			AND ET.[Enabled] = 'True';

			--Set the Version Number of This One
			UPDATE ET
			SET ET.VersionNumber = ISNULL((SELECT MAX(ET2.VersionNumber)
									FROM dbo.LetterTemplate ET2
									WHERE ET2.OrganisationId = ET.OrganisationId
									AND ET2.LetterCategoryId = ET.LetterCategoryId
									AND ET2.Id <> ET.Id), 0) + 1
			FROM INSERTED I
			INNER JOIN dbo.LetterTemplate ET		ON ET.Id = I.Id
			;


		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_05.02_CreateInsertTriggerToLetterTemplate.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

