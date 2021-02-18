/*
 * SCRIPT: Alter Table Client
 * Author: Dan Hough
 * Created: 19/05/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP020_38.01_Amend_Client.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to Client table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.Client
			ADD CreatedByUserId INT
		    , UpdatedByUserId INT NULL
			, DateUpdated DATETIME NULL
			, CONSTRAINT FK_Client_User2 FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Client_User3 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id) 

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;