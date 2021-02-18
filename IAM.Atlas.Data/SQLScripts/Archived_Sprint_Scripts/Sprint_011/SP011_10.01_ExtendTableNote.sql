/*THIS SCRIPT WAS CREATED DURING SPRINT 9 BUT RUN AT THE START OF SPRINT 10, HENCE THE DIFFERENCE IN FILE NAME TO SCRIPT NAME: USE THE SCRIPT NAME WHEN COMPARING TO THE SCRIPT LOG ENTRY*/

/*
	SCRIPT: Add Foreign Key to the CreatedByUserId field of the Note table
	Author: Dan Murray
	Created: 03/11/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP011_10.01_ExtendTableNote.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Note
		*/	

		ALTER TABLE dbo.Note	
		ADD CONSTRAINT FK_Note_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)					
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

