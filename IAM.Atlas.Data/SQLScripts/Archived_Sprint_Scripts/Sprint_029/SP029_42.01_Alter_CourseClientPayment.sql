/*
 * SCRIPT: Add column to CourseClientPayment
 * Author: Dan Hough
 * Created: 28/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_42.01_Alter_CourseClientPayment.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to CourseClientPayment';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClientPayment
		ADD TransferredFromCourseId INT NULL
			, CONSTRAINT FK_CourseClientPaymentTransferredFromCourseId_Course FOREIGN KEY (TransferredFromCourseId) REFERENCES Course(Id) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
