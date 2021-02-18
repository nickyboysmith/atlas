/*
 * SCRIPT: Alter Table Course 
 * Author: Dan Hough
 * Created: 08/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_38.01_Amend_Course.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to SystemControl';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.Course
		ADD UpdatedByUserId INT
		, DORSNotificationReason VARCHAR(20)
		, PracticalCourse BIT DEFAULT 'False'
		, TheoryCourse BIT DEFAULT 'False'
		, CONSTRAINT FK_Course_User2 FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id) ;

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
