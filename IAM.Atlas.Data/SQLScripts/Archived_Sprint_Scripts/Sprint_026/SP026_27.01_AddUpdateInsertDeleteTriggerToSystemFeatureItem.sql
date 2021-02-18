/*
	SCRIPT: Amend update, insert, delete trigger on the SystemFeatureItem table
	Author: Robert Newnham
	Created: 18/09/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP026_27.01_AddUpdateInsertDeleteTriggerToSystemFeatureItem.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend update, insert, delete trigger on the SystemFeatureItem table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_SystemFeatureItem_InsertUpdateDelete]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_SystemFeatureItem_InsertUpdateDelete];
	END
GO
		CREATE TRIGGER TRG_SystemFeatureItem_InsertUpdateDelete ON SystemFeatureItem AFTER INSERT, UPDATE, DELETE
		AS

		BEGIN

			DECLARE @deletedId INT
			DECLARE @insertedId INT

			SELECT @insertedId = i.id, @deletedId = d.id
			FROM inserted i 
			FULL OUTER JOIN deleted d ON i.Id = d.Id

			IF
				(@insertedId IS NULL)
					EXEC dbo.uspUpdateSystemInformation @deletedId

			ELSE
					EXEC dbo.uspUpdateSystemInformation @insertedId

		END

		GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP026_27.01_AddUpdateInsertDeleteTriggerToSystemFeatureItem.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO