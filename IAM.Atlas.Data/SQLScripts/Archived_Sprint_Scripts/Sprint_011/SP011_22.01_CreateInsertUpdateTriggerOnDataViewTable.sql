

/*
	SCRIPT: Add trigger to the DataView table
	Author: Nick Smith
	Created: 17/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_22.01_CreateInsertUpdateTriggerOnDataViewTable.sql';
DECLARE @ScriptComments VARCHAR(800) = '';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO 

IF OBJECT_ID('dbo.[TRG_DataView_INSERTUPDATE]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DataView_INSERTUPDATE];
		END
GO
		--CREATE TRIGGER TRG_DataView_INSERTUPDATE ON DataView FOR INSERT, UPDATE
		CREATE TRIGGER TRG_DataView_INSERTUPDATE ON DataView AFTER INSERT, UPDATE
AS
	DECLARE @DataViewId int;
	DECLARE @DataViewName varchar(100);
	
	/* This will just capture single rows. 
	Won't work if multirows are inserted. */
	
	SELECT @DataViewId = i.Id, @DataViewName = i.Name FROM inserted i;
	
	EXEC dbo.usp_UpdateDataViewColumn @DataViewId, @DataViewName;
	GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP011_22.01_CreateInsertUpdateTriggerOnDataViewTable.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO