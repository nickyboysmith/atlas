/*
	SCRIPT: Amend insert trigger on the Organisation table: uspEnsureTaskActionForOrganisation
	Author: Paul Tuck
	Created: 24/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_19.01_AmendInsertTriggerOnOrganisation.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_Organisation_EnsureData_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_Organisation_EnsureData_INSERT];
	END
GO
	/*******************************************************************************************************************/
	CREATE TRIGGER TRG_Organisation_EnsureData_INSERT ON Organisation FOR INSERT
	AS	
	BEGIN
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN
			EXEC dbo.uspEnsureOrganisationalData;
			EXEC dbo.uspEnsureTaskActionForOrganisation;	
		END --END PROCESS

	END
	GO
	/*******************************************************************************************************************/

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP035_19.01_AmendInsertTriggerOnOrganisation.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO