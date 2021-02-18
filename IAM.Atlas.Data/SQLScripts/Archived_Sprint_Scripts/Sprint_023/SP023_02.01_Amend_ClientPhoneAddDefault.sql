/*
 * SCRIPT: Alter Table ClientPhone 
 * Author: Robert Newnham
 * Created: 08/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_02.01_Amend_ClientPhoneAddDefault.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to table ClientPhone';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhonePhoneNumber' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhonePhoneNumber] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhonePhoneNumber] ON [dbo].[ClientPhone]
		(
			[PhoneNumber] ASC
		);

		--Update Table. Sort Out Crap Data
		DELETE dbo.ClientPhone
		WHERE [PhoneNumber] = '(anonymised)';
						 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;