/*
 * SCRIPT: Alter Table CourseVenue, Add EmailAvailability, AvailabilityEmailed and DateAvailabilityEmailed Columns
 * Author: Nick Smith
 * Created: 18/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_40.01_Alter_CourseVenueTableAddEmailAvailabilityAvailabilityEmailedDateAvailabilityEmailedColumns.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Alter Table Course Table Add EmailAvailability, AvailabilityEmailed and DateAvailabilityEmailed Columns';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		

		ALTER TABLE dbo.CourseVenue
		ADD
			EmailAvailability BIT DEFAULT 'False',
			AvailabilityEmailed BIT DEFAULT 'False',
			DateAvailabilityEmailed DATETIME
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

