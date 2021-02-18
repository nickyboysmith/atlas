/*
 * SCRIPT: Change Defaults on Table CourseVenue
 * Author: Robert Newnham
 * Created: 20/12/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP030_25.01_AmendTableCourseVenue.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Change Defaults on Table CourseVenue';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/

		UPDATE dbo.CourseVenue
		SET ReservedPlaces = 0
		WHERE ReservedPlaces IS NULL;

		ALTER TABLE dbo.CourseVenue
		ALTER COLUMN ReservedPlaces INT NOT NULL;

		ALTER TABLE dbo.CourseVenue
		ADD DEFAULT 0 FOR ReservedPlaces;

		UPDATE dbo.CourseVenue
		SET EmailAvailability = 'False'
		WHERE EmailAvailability IS NULL;

		ALTER TABLE dbo.CourseVenue
		ALTER COLUMN EmailAvailability BIT NOT NULL;
		
		UPDATE dbo.CourseVenue
		SET AvailabilityEmailed = 'False'
		WHERE AvailabilityEmailed IS NULL;

		ALTER TABLE dbo.CourseVenue
		ALTER COLUMN AvailabilityEmailed BIT NOT NULL;
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;