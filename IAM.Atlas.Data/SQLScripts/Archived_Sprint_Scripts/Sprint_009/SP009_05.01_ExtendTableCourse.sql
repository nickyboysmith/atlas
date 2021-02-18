

/*
	SCRIPT: Add additional columns to the Course table
	Author: Dan Murray
	Created: 23/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_05.01_ExtendTableCourse.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table Course
		*/
		

		ALTER TABLE dbo.Course	
		ADD TrainersRequired int
		, SendAttendanceDORS bit 
		, TrainerUpdatedAttendance bit 
		, ManualCarsOnly bit 
		, OnlineManualCarsOnly bit 
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

