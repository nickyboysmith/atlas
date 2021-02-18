/*
 * SCRIPT: Alter ReferringAuthority and ReferringAuthorityContract tables
 * Author: Dan Murray
 * Created: 01/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP022_31.01_Amend_ReferringAuthority_ReferringAuthorityContract.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter ReferringAuthority and ReferringAuthorityContract tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		ALTER TABLE dbo.ReferringAuthority
			ADD CreatedByUserId INT NULL,
				DateCreated DATETIME NULL DEFAULT GETDATE(),
				UpdatedByUserId INT NULL,
				DateUpdated DATETIME NULL,
				CONSTRAINT FK_ReferringAuthority_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id),
				CONSTRAINT FK_ReferringAuthority_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)

		ALTER TABLE dbo.ReferringAuthorityContract
			ADD CreatedByUserId INT NULL,
				DateCreated DATETIME NULL DEFAULT GETDATE(),
				CONSTRAINT FK_ReferringAuthorityContract_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)

			 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;