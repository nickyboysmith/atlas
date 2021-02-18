/*
 * SCRIPT: Create CourseOverBookingNotification Table
 * Author: Robert Newnham
 * Created: 10/08/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP024_25.04_CreateCourseOverBookingNotification.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create CourseOverBookingNotification Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CourseOverBookingNotification'
		
		/*
		 *	Create CourseOverBookingNotification Table
		 */
		IF OBJECT_ID('dbo.CourseOverBookingNotification', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CourseOverBookingNotification;
		END

		CREATE TABLE CourseOverBookingNotification(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId INT NOT NULL
			, DateTimeNotified DATETIME
			, CONSTRAINT FK_CourseOverBookingNotification_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
		);
		
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

