/*
 * SCRIPT: Create Table DORSClientCourseTransferred 
 * Author: Paul Tuck
 * Created: 14/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_14.01_CreateTableDORSClientCourseTransferred.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSClientCourseTransferred';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSClientCourseTransferred'
		
		/*
		 *	Create DORSClientCourseRemoval Table
		 */
		IF OBJECT_ID('dbo.DORSClientCourseTransferred', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSClientCourseTransferred;
		END

		CREATE TABLE DORSClientCourseTransferred(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, TransferFromCourseId INT NOT NULL
			, TransferToCourseId INT NOT NULL
			, ClientId INT NOT NULL
			, DateRequested DATETIME DEFAULT GETDATE() NOT NULL
			, Notes VARCHAR(400) NULL
			, DORSNotified BIT DEFAULT 0
			, DateTimeDORSNotified DATETIME NULL
			, CONSTRAINT FK_DORSClientCourseTransferred_FromCourse FOREIGN KEY (TransferFromCourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_DORSClientCourseTransferred_ToCourse FOREIGN KEY (TransferToCourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_DORSClientCourseTransferred_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;