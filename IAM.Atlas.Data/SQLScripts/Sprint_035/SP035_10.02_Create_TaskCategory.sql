/*
	SCRIPT: Create TaskCategory Table 
	Author: Robert Newnham
	Created: 19/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_10.02_Create_TaskCategory.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create TaskCategory Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'TaskCategory'
		
		/*
		 *	Create TaskCategory Table
		 */
		IF OBJECT_ID('dbo.TaskCategory', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.TaskCategory;
		END

		CREATE TABLE TaskCategory(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, [Title] VARCHAR(100) NOT NULL
			, [Description] VARCHAR(400)
			, [Disable] BIT NOT NULL DEFAULT 'False'
			, CreatedByUserId INT NOT NULL
			, DateCreated DATETIME NOT NULL DEFAULT GETDATE()
			, UpdatedByUserId INT
			, DateUpdated DATETIME
			, ColourName VARCHAR(40)
			, CONSTRAINT FK_TaskCategory_User_CreatedByUserId FOREIGN KEY (CreatedByUserId) REFERENCES [User](Id)
			, CONSTRAINT FK_TaskCategory_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;