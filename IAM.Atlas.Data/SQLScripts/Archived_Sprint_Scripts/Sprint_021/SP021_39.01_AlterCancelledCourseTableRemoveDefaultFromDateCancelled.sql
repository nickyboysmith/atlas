/*
	SCRIPT: Recreate CancelledCourse Table Drop Default from DateCancelled
	Author: Nick Smith
	Created: 07/06/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP021_39.01_AlterCancelledCourseTableRemoveDefaultFromDateCancelled.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter CancelledCourse Table. Drop Default from DateCancelled';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
		 *	Drop Constraints if they Exist
		 */		
		EXEC dbo.uspDropTableContraints 'CancelledCourse'
		
		/*
		 *	Create CancelledCourse Table
		 */
		IF OBJECT_ID('dbo.CancelledCourse', 'U') IS NOT NULL
		BEGIN
			DROP TABLE dbo.CancelledCourse;
		END

		CREATE TABLE CancelledCourse(
			Id INT IDENTITY (1,1) PRIMARY KEY NOT NULL
			, CourseId int NOT NULL
			, DateCancelled DateTime NOT NULL
			, CancelledByUserId int NOT NULL
			, DORSCourse bit NOT NULL DEFAULT 'False'
			, CONSTRAINT FK_CancelledCourse_Course FOREIGN KEY (CourseId) REFERENCES Course(Id)
			, CONSTRAINT FK_CancelledCourse_User FOREIGN KEY (CancelledByUserId) REFERENCES [User](Id)
		);
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;