


/*
	SCRIPT: Create Missing Foreign Keys and Rename Column
	Author: Robert Newnham
	Created: 18/05/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP003_04.01_AddMissingForeignKeys.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_Report_User')
				   AND parent_object_id = OBJECT_ID(N'dbo.Report')
		)
		BEGIN
			ALTER TABLE Report DROP CONSTRAINT FK_Report_User;
		END
		
		IF EXISTS (SELECT * FROM sys.foreign_keys 
				   WHERE object_id = OBJECT_ID(N'dbo.FK_Report_User2')
				   AND parent_object_id = OBJECT_ID(N'dbo.Report')
		)
		BEGIN
			ALTER TABLE Report DROP CONSTRAINT FK_Report_User2;
		END
		
		ALTER TABLE Report 
		ADD 
			CONSTRAINT FK_Report_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_Report_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
		;

		--Rename Columns
		IF EXISTS(SELECT * 
					FROM sys.columns 
					WHERE Name = N'Email' and Object_ID = Object_ID(N'Email')
					)
		BEGIN
			EXEC sp_RENAME 'Email.Email', 'Address', 'COLUMN'
		END
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

