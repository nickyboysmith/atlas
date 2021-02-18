
/*
 * SCRIPT: Add Missing Indexes.
 * Author:Robert Newnham
 * Created: 02/11/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP028_29.05_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerBookingRequestTrainerId' 
				AND object_id = OBJECT_ID('TrainerBookingRequest'))
		BEGIN
		   DROP INDEX [IX_TrainerBookingRequestTrainerId] ON [dbo].[TrainerBookingRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerBookingRequestTrainerId] ON [dbo].[TrainerBookingRequest]
		(
			[TrainerId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerBookingRequestTrainerIdDate' 
				AND object_id = OBJECT_ID('TrainerBookingRequest'))
		BEGIN
		   DROP INDEX [IX_TrainerBookingRequestTrainerIdDate] ON [dbo].[TrainerBookingRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerBookingRequestTrainerIdDate] ON [dbo].[TrainerBookingRequest]
		(
			[TrainerId], [Date] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerBookingRequestCourseId' 
				AND object_id = OBJECT_ID('TrainerBookingRequest'))
		BEGIN
		   DROP INDEX [IX_TrainerBookingRequestCourseId] ON [dbo].[TrainerBookingRequest];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerBookingRequestCourseId] ON [dbo].[TrainerBookingRequest]
		(
			[CourseId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerAvailabilityDateTrainerId' 
				AND object_id = OBJECT_ID('TrainerAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_TrainerAvailabilityDateTrainerId] ON [dbo].[TrainerAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerAvailabilityDateTrainerId] ON [dbo].[TrainerAvailabilityDate]
		(
			[TrainerId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerAvailabilityDateTrainerIdDate' 
				AND object_id = OBJECT_ID('TrainerAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_TrainerAvailabilityDateTrainerIdDate] ON [dbo].[TrainerAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerAvailabilityDateTrainerIdDate] ON [dbo].[TrainerAvailabilityDate]
		(
			[TrainerId], [Date] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_TrainerAvailabilityDateDate' 
				AND object_id = OBJECT_ID('TrainerAvailabilityDate'))
		BEGIN
		   DROP INDEX [IX_TrainerAvailabilityDateDate] ON [dbo].[TrainerAvailabilityDate];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_TrainerAvailabilityDateDate] ON [dbo].[TrainerAvailabilityDate]
		(
			[Date] ASC
		);
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

