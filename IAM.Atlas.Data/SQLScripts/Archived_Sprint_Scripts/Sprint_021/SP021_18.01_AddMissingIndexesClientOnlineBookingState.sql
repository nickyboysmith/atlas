
/*
 * SCRIPT: Add Missing Indexes to table ClientOnlineBookingState.
 * Author: Nick Smith
 * Created: 06/06/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP021_18.01_AddMissingIndexesClientOnlineBookingState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Index to table ClientOnlineBookingState';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientOnlineBookingStateCourseBookedDateTimeCourseBooked' 
				AND object_id = OBJECT_ID('ClientOnlineBookingState'))
		BEGIN
		   DROP INDEX [IX_ClientOnlineBookingStateCourseBookedDateTimeCourseBooked] ON [dbo].[ClientOnlineBookingState];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientOnlineBookingStateCourseBookedDateTimeCourseBooked] ON [dbo].[ClientOnlineBookingState]
		(
			[CourseBooked], [DateTimeCourseBooked]  ASC
		);

		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

