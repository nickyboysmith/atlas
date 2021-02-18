/*
 * SCRIPT: Alter insert trigger to the ClientMysteryShopper table
 * Author: Robert Newnham
 * Created: 26/05/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP038_11.04_AlterInsertTriggerToClientMysteryShopper.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter insert trigger to the ClientMysteryShopper table';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_ClientMysteryShopper_INSERT]', 'TR') IS NOT NULL
	BEGIN
		DROP TRIGGER dbo.[TRG_ClientMysteryShopper_INSERT];
	END
GO

	CREATE TRIGGER TRG_ClientMysteryShopper_INSERT ON ClientMysteryShopper FOR INSERT
	AS
		DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
		DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
		IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
		BEGIN                 
			EXEC uspLogTriggerRunning 'ClientMysteryShopper', 'TRG_ClientMysteryShopper_INSERT', @insertedRows, @deletedRows;
			-------------------------------------------------------------------------------------------
			
			UPDATE CDC
			SET CDC.IsMysteryShopper = 'True'
			FROM INSERTED I
			INNER JOIN dbo.CourseDORSClient CDC ON CDC.ClientId = I.ClientId
			WHERE CDC.IsMysteryShopper = 'False'
			;

			UPDATE CDCR
			SET CDCR.IsMysteryShopper = 'True'
			FROM INSERTED I
			INNER JOIN dbo.CourseDORSClientRemoved CDCR ON CDCR.ClientId = I.ClientId
			WHERE CDCR.IsMysteryShopper = 'False'
			;
			
			UPDATE CDD
			SET CDD.IsMysteryShopper = 'True'
			FROM INSERTED I
			INNER JOIN dbo.ClientDORSData CDD ON CDD.ClientId = I.ClientId
			WHERE CDD.IsMysteryShopper = 'False'
			;

		END --END PROCESS

	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP038_11.04_AlterInsertTriggerToClientMysteryShopper.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

