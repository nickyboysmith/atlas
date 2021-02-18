

/*
	SCRIPT: Add additional columns to the CourseVenue table
	Author: Dan Murray
	Created: 23/09/2015
*/

DECLARE @ScriptName VARCHAR(100) = 'SP009_06.01_ExtendTableCourseVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = '';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		/*
			Update Table CourseVenue
		*/
		

		ALTER TABLE dbo.CourseVenue	
		ADD ReservedPlaces int
       
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

