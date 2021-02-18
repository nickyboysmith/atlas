/*
 * SCRIPT: Create Table DORSClientCourseRemoval 
 * Author: Paul Tuck
 * Created: 11/07/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP023_05.01_CreateTableDORSClientCourseRemoval.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create Table DORSClientCourseRemoval';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/

		/***START OF SCRIPT***/
		
		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'DORSClientCourseRemoval'
		
		/*
		 *	Create DORSClientCourseRemoval Table
		 */
		IF OBJECT_ID('dbo.DORSClientCourseRemoval', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.DORSClientCourseRemoval;
		END

		CREATE TABLE DORSClientCourseRemoval(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, ClientId INT NOT NULL
			, DateRequested DATETIME DEFAULT GETDATE() NOT NULL
			, Notes VARCHAR(400) DEFAULT ''
			, DORSNotified BIT DEFAULT 0 NOT NULL
			, DateTimeDORSNotified DATETIME NULL
			, CONSTRAINT FK_DORSClientCourseRemoval_Course FOREIGN KEY (CourseId) REFERENCES [Course](Id)
			, CONSTRAINT FK_DORSClientCourseRemoval_Client FOREIGN KEY (ClientId) REFERENCES [Client](Id)
		);

		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;