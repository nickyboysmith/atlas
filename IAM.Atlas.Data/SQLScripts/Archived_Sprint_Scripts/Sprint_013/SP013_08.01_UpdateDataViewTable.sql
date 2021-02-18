/*
	SCRIPT:  Alter DataView Table
	Author:  Dan Murray
	Created: 16/12/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP013_08.01_UpdateDataViewTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to DataView Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update DataView Table
		*/
		ALTER TABLE dbo.[DataView] 
		 ADD AddedByUserId int 		
		,DateUpdated DateTime DEFAULT GETDATE()
		,UpdatedByUserId int
		,CONSTRAINT FK_DataView_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)
		,CONSTRAINT FK_DataView_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id);
		

		--Add Columns, "Added By User Id", "Date Updated", "Updated By User Id" and the associated foreign keys.
			
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;