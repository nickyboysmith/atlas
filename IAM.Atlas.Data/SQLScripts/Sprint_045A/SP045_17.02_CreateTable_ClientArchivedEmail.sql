/*
	SCRIPT: Create ClientArchivedEmail Table
	Author: Dan Hough
	Created: 10/11/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP045_17.02_CreateTable_ClientArchivedEmail.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientArchivedEmail Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientArchivedEmail'
		
		/*
		 *	Create ClientArchivedEmail Table
		 */
		IF OBJECT_ID('dbo.ClientArchivedEmail', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientArchivedEmail;
		END

		CREATE TABLE ClientArchivedEmail(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, DateTimeArchived DATETIME NOT NULL DEFAULT GETDATE() 
			, EmailCreationDate DATETIME  NULL
			, EmailSentDate DATETIME NULL
			, EmailSubject VARCHAR(320) NOT NULL
			, SendToAddress VARCHAR(320) NULL

		);
		/**************************************************************************************************************************/
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END