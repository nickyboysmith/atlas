/*
	SCRIPT: Create CourseDORSNotification Table
	Author: Dan Hough
	Created: 08/11/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP028_39.01_Create_CourseDORSNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseDORSNotification Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseDORSNotification'
		
		/*
		 *	Create CourseDORSNotification Table
		 */
		IF OBJECT_ID('dbo.CourseDORSNotification', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseDORSNotification;
		END

		CREATE TABLE CourseDORSNotification(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT
			, DateTimeNotified DATETIME
			, NotificationReason VARCHAR(20)
			, CONSTRAINT FK_CourseDORSNotification_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;