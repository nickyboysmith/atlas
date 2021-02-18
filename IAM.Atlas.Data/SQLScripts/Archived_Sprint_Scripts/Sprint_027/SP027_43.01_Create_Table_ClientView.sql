/*
	SCRIPT: Create Client View Table
	Author: John Cocklin
	Created: 19/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_43.01_Create_Table_ClientView';
DECLARE @ScriptComments VARCHAR(800) = 'Create ClientView Table';

IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'ClientView'
		
		/*
		 *	Create ClientView Table
		 */
		IF OBJECT_ID('dbo.ClientView', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.ClientView;
		END


		CREATE TABLE ClientView
		(
			Id				INT			NOT NULL IDENTITY (1, 1),
			ClientId		INT			NOT NULL,
			ViewedByUserId 	INT			NOT NULL,
			DateTimeViewed	DATETIME	NOT NULL
		)
		;

		ALTER TABLE dbo.ClientView
			ADD CONSTRAINT PK_ClientView PRIMARY KEY(Id)
		;

		ALTER TABLE dbo.ClientView 
			ADD CONSTRAINT FK_ClientView_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
		;

		ALTER TABLE dbo.ClientView 
			ADD CONSTRAINT FK_ClientView_ViewedByUser FOREIGN KEY (ViewedByUserId) REFERENCES [User](Id)
		;

		ALTER TABLE dbo.ClientView ADD CONSTRAINT
			DF_ClientView_DateTimeViewed DEFAULT GETDATE() FOR DateTimeViewed
		;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;