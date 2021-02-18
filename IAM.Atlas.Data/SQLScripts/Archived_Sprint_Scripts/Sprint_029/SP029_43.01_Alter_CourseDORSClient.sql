/*
 * SCRIPT: Add columns to CourseDORSClient
 * Author: Dan Hough
 * Created: 28/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP029_43.01_Alter_CourseDORSClient.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add columns to CourseDORSClient';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDORSClient
		ADD TransferredToCourseId INT NULL
			, TransferredFromCourseId INT NULL
			, CONSTRAINT FK_CourseDORSClientTransferredToCourseId_Course FOREIGN KEY (TransferredToCourseId) REFERENCES Course(Id) 
			, CONSTRAINT FK_CourseDORSClientTransferredFromCourseId_Course FOREIGN KEY (TransferredFromCourseId) REFERENCES Course(Id) 

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
