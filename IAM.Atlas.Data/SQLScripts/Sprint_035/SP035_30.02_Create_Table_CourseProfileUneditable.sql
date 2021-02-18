/*
	SCRIPT: Create CourseProfileUneditable Table 
	Author: Robert Newnham
	Created: 02/04/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_30.02_Create_Table_CourseProfileUneditable.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseProfileUneditable Table ';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseProfileUneditable'
		
		/*
		 *	Create CourseProfileUneditable Table
		 */
		IF OBJECT_ID('dbo.CourseProfileUneditable', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseProfileUneditable;
		END

		CREATE TABLE CourseProfileUneditable(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, AfterDate DateTime NOT NULL DEFAULT GETDATE()
			, Reason VARCHAR(200) NULL
			, UpdatedByUserId INT NOT NULL
			, CONSTRAINT FK_CourseProfileUneditable_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseProfileUneditable_User_UpdatedByUserId FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)
			);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;