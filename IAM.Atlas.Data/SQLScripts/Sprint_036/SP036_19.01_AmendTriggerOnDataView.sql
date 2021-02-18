/*
	SCRIPT: Amend trigger on DataView
	Author: Dan Hough
	Created: 27/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP036_19.01_AmendTriggerOnDataView.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Amend trigger on DataView';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.TRG_DataView_INSERTUPDATE', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_DataView_INSERTUPDATE;
END

GO

IF OBJECT_ID('dbo.TRG_DataView_InsertUpdate', 'TR') IS NOT NULL
BEGIN
	DROP TRIGGER dbo.TRG_DataView_InsertUpdate;
END

GO

CREATE TRIGGER TRG_DataView_InsertUpdate ON dbo.DataView AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @insertedRows int = 0; SELECT @insertedRows = COUNT(*) FROM INSERTED;
	DECLARE @deletedRows int = 0; SELECT @deletedRows = COUNT(*) FROM DELETED;
         
	IF ((@insertedRows + @deletedRows) > 0) --Only Run if there have been a successful event
	BEGIN                 
		EXEC uspLogTriggerRunning 'DataView', 'TRG_DataView_InsertUpdate', @insertedRows, @deletedRows;
		-------------------------------------------------------------------------------------------
	
		DECLARE @DataViewName varchar(100);
	
		/* This will just capture single rows. 
		Won't work if multirows are inserted. */
	
		SELECT @DataViewName = I.[Name]
		FROM INSERTED I;
	
		EXEC dbo.uspUpdateDataViewColumn @DataViewName;

		END
	END
GO

/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP036_19.01_AmendTriggerOnDataView.sql';
EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
GO

