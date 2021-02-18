/*
 * SCRIPT: Alter Table ClientPhone - Part 2
 * Author: Robert Newnham
 * Created: 08/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_02.02_Amend_ClientPhoneAddDefault_Part2.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new columns to table ClientPhone';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		--Add New Columns
		IF NOT EXISTS(
			SELECT *
			FROM sys.columns 
			WHERE Name      = N'DefaultNumber'
			  AND Object_ID = Object_ID(N'ClientPhone'))
		BEGIN
			PRINT 'CREATING NEW COLUMNS ON TABLE dbo.ClientPhone';
			ALTER TABLE dbo.ClientPhone
				ADD 
					DefaultNumber BIT DEFAULT 'False'
					, DateAdded DATETIME DEFAULT Getdate();
		END
						 
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;