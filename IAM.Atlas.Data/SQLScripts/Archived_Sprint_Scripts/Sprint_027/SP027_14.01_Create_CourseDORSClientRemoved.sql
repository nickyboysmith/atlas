/*
	SCRIPT: Create CourseDORSClientRemoved Table
	Author: Dan Murray
	Created: 05/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_14.01_Create_CourseDORSClientRemoved.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDORSClientRemoved Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDORSClientRemoved'
		
		/*
		 *	Create CourseDORSClientRemoved Table
		 */
		IF OBJECT_ID('dbo.CourseDORSClientRemoved', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDORSClientRemoved;
		END

		CREATE TABLE CourseDORSClientRemoved(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT 
			, ClientId INT
			, DateRemoved DATETIME
			, DORSNotified  BIT DEFAULT 'False'
			, DateDORSNotified DATETIME
			, CONSTRAINT FK_CourseDORSClientRemoved_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDORSClientRemoved_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;