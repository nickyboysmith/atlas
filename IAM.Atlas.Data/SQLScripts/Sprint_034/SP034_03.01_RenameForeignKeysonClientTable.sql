/*
 * SCRIPT: Rename Foreign Keys on Client Table for User Links
 * Author: Robert Newnham
 * Created: 24/02/2017
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP034_03.01_RenameForeignKeysonClientTable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Rename Foreign Keys on Client Table for User Links';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/


		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_Client_LockedByUser')
		   AND parent_object_id = OBJECT_ID(N'dbo.Client')
		)
		BEGIN
			EXECUTE SP_RENAME 
					@objname = 'FK_Client_LockedByUser',
					@newname = 'FK_Client_User_LockedByUser',
					@objtype = 'object'
					;
		END

		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_Client_User')
		   AND parent_object_id = OBJECT_ID(N'dbo.Client')
		)
		BEGIN
			EXECUTE SP_RENAME 
					@objname = 'FK_Client_User',
					@newname = 'FK_Client_User_User',
					@objtype = 'object'
					;
		END
		
		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_Client_User2')
		   AND parent_object_id = OBJECT_ID(N'dbo.Client')
		)
		BEGIN
			EXECUTE SP_RENAME 
					@objname = 'FK_Client_User2',
					@newname = 'FK_Client_User_CreatedByUser',
					@objtype = 'object'
					;
		END
		
		IF EXISTS (SELECT * 
		  FROM sys.foreign_keys 
		   WHERE object_id = OBJECT_ID(N'dbo.FK_Client_User3')
		   AND parent_object_id = OBJECT_ID(N'dbo.Client')
		)
		BEGIN
			EXECUTE SP_RENAME 
					@objname = 'FK_Client_User3',
					@newname = 'FK_Client_User_UpdatedByUser',
					@objtype = 'object'
					;
		END

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
