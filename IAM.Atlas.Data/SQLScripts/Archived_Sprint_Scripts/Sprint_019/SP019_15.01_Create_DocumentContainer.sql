/*
	SCRIPT: Create DocumentContainer Table
	Author: Dan Hough
	Created: 21/04/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP019_15.01_Create_DocumentContainer.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create DocumentContainer Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DocumentContainer'
		
		/*
		 *	Create DocumentContainer Table
		 */
		IF OBJECT_ID('dbo.DocumentContainer', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DocumentContainer;
		END

		CREATE TABLE DocumentContainer(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, Name varchar(100) NOT NULL
			, [Path] varchar(1000) NOT NULL
			, DateCreated DateTime
			, CreatedByUserId int
			, CONSTRAINT FK_DocumentContainer_User FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)

		);
		

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;