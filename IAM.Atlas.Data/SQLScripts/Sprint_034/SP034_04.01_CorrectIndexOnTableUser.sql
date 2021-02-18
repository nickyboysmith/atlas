
/*
 * SCRIPT: Correct LoginId Index on Table User
 * Author: Robert Newnham
 * Created: 24/02/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP034_04.01_CorrectIndexOnTableUser.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Correct LoginId Index on Table User';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='UX_User_LoginId' 
				AND object_id = OBJECT_ID('User'))
		BEGIN
		   DROP INDEX [UX_User_LoginId] ON [dbo].[User];
		END
		
		--Now Create Index
		CREATE UNIQUE INDEX [UX_User_LoginId] ON [dbo].[User]
		(
			[LoginId] ASC
		) 
		WHERE [LoginId] IS NOT NULL; --IE UNIQUE INDEX WITH NULLS
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

