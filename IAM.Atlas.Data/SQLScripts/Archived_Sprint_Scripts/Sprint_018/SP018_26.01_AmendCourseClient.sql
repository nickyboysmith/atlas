/*
 * SCRIPT: Alter Table CourseClient - add in TotalPaymentDue and UpdatedByUserId  
 * Author: Dan Hough
 * Created: 04/04/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP018_26.01_AmendCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add column to CourseClient table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.CourseClient
		 ADD TotalPaymentDue money
		, UpdatedByUserId int NULL
		, CONSTRAINT FK_CourseClient_User FOREIGN KEY (UpdatedByUserId) REFERENCES [User](Id)


		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;