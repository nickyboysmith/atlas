/*
 * SCRIPT: Add New Columns to Table CourseClient
 * Author: Robert Newnham
 * Created: 16/05/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP037_29.01_AmendTableCourseClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add New Columns to Table CourseClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseClient
		ADD 
			TotalPaymentMade MONEY NULL
			, PaymentDueDate DATETIME NULL
			, LastPaymentMadeDate DATETIME NULL
			;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;