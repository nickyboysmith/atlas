/*
	SCRIPT: Create ReconciliationDataComment Table
	Author: Paul Tuck
	Created: 03/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_10.02_CreateTable_ReconciliationDataComment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ReconciliationDataComment Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ReconciliationDataComment'
		
		/*
		 *	Create OrganisationNotificationLog Table
		 */
		IF OBJECT_ID('dbo.ReconciliationDataComment', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ReconciliationDataComment;
		END

		CREATE TABLE ReconciliationDataComment(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, ReconciliationDataId INT 
			, DateAdded DATETIME NOT NULL DEFAULT GETDATE()
			, AddedByUserId INT NOT NULL
			, Comment VARCHAR(100) NOT NULL
			, CONSTRAINT FK_ReconciliationDataComment_ReconciliationData FOREIGN KEY (ReconciliationDataId) REFERENCES ReconciliationData(Id)
			, CONSTRAINT FK_ReconciliationDataComment_User FOREIGN KEY (AddedByUserId) REFERENCES [User](Id)

		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END