/*
 * SCRIPT: Create Table CourseClientTransferred 
 * Author: Paul Tuck
 * Created: 14/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_13.01_CreateTableCourseClientTransferred.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table CourseClientTransferred';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseClientTransferred'
		
		/*
		 *	Create CourseClientTransferred Table
		 */
		IF OBJECT_ID('dbo.CourseClientTransferred', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseClientTransferred;
		END

		CREATE TABLE CourseClientTransferred(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TransferFromCourseId INT NOT NULL
			, TransferToCourseId INT NOT NULL
			, ClientId INT NOT NULL
			, DateTransferred DATETIME DEFAULT GETDATE() NOT NULL
			, TransferredByUserId INT NOT NULL
			, CONSTRAINT FK_CourseClientTransferred_FromCourse FOREIGN KEY (TransferFromCourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientTransferred_ToCourse FOREIGN KEY (TransferToCourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_CourseClientTransferred_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
			, CONSTRAINT FK_CourseClientTransferred_User FOREIGN KEY (TransferredByUserId) REFERENCES [User](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;