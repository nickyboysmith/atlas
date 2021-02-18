/*
	SCRIPT: Create CourseDORSClient Table
	Author: Dan Murray
	Created: 05/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_13.01_Create_CourseDORSClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDORSClient Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDORSClient'
		
		/*
		 *	Create CourseDORSClient Table
		 */
		IF OBJECT_ID('dbo.CourseDORSClient', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDORSClient;
		END

		CREATE TABLE CourseDORSClient(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT 
			, ClientId INT
			, DateAdded DATETIME
			, DORSNotified  BIT DEFAULT 'False'
			, DateDORSNotified DATETIME
			, DORSAttendanceRef INT
			, DORSAttendanceStateIdentifier INT
			, CONSTRAINT FK_CourseDORSClient_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CourseDORSClient_Client FOREIGN KEY (ClientId) REFERENCES Client(Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;