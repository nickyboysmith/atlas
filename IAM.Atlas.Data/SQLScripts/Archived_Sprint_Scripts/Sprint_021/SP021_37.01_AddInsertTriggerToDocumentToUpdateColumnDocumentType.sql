/*
	SCRIPT: Add insert trigger to the Document table. 
	Author: Nick Smith
	Created: 08/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_37.01_AddInsertTriggerToDocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the Document table. If DocumentType empty, check OriginalFileName and extract extension and update DocumentType';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT];
		END
GO
		CREATE TRIGGER TRG_DocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty_INSERT ON Document FOR INSERT
AS

	
		DECLARE @OriginalFileName VARCHAR(100); 
		DECLARE @Extension VARCHAR(10);
		
		SET @OriginalFileName = (SELECT TOP 1 i.OriginalFileName FROM inserted i);
		
		-- need to check for existence of a period else the extension extraction will fail.
		IF CHARINDEX('.', @OriginalFileName) > 0
		BEGIN
			
			SET @Extension = REVERSE(LEFT(REVERSE(@OriginalFileName),CHARINDEX('.',REVERSE(@OriginalFileName))-1));
			
			UPDATE Document
				SET [Type] = @Extension
				FROM inserted i
					WHERE i.Id = Document.Id AND
					(i.[Type] IS NULL OR i.[Type] = '') 

			INSERT INTO [dbo].[DocumentType]
				([Type]
				,[Description])
			SELECT
				@Extension
				,'<file type> Documents' --This needs the actual file type in DOH!!!
			WHERE 
				NOT EXISTS 
				(SELECT *
					FROM DocumentType dt
					WHERE (dt.[Type] = @Extension))
		END
			
GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP021_37.01_AddInsertTriggerToDocumentToUpdateColumnDocumentTypeIfOriginalFileNameEmpty.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO