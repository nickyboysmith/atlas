/*
 * SCRIPT: Alter Table CourseDateClientAttendance
 * Author: Robert Newnham
 * Created: 19/08/2016
 */
 
DECLARE @ScriptName VARCHAR(100) = 'SP025_02.02_AmendCourseDateClientAttendance.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add new Columns to CourseDateClientAttendance Table';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		ALTER TABLE dbo.CourseDateClientAttendance
			ADD TrainerId INT NULL
			, CONSTRAINT FK_CourseDateClientAttendance_Trainer FOREIGN KEY (TrainerId) REFERENCES Trainer(Id);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;
