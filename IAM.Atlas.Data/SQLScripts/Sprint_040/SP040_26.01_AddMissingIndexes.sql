
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 11/07/2017
 */

DECLARE @ScriptName VARCHAR(100) = 'SP040_26.01_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexes to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientOrganisationClientId' 
				AND object_id = OBJECT_ID('ClientOrganisation'))
		BEGIN
		   DROP INDEX [IX_ClientOrganisationClientId] ON [dbo].[ClientOrganisation];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientOrganisationClientId] ON [dbo].[ClientOrganisation]
		(
			[ClientId] ASC
		) INCLUDE ([DateAdded], [OrganisationId]) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseDORSClientDORSAttendanceStateIdentifier' 
				AND object_id = OBJECT_ID('CourseDORSClient'))
		BEGIN
		   DROP INDEX [IX_CourseDORSClientDORSAttendanceStateIdentifier] ON [dbo].[CourseDORSClient];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseDORSClientDORSAttendanceStateIdentifier] ON [dbo].[CourseDORSClient]
		(
			[DORSAttendanceStateIdentifier] ASC
		) INCLUDE (
					[ClientId], [CourseId], [DateAdded]
					, [DateDORSNotificationAttempted], [DateDORSNotified], [DatePaidInFull]
					, [DORSAttendanceRef], [DORSNotified], [IsMysteryShopper]
					, [NumberOfDORSNotificationAttempts], [OnlyPartPaymentMade], [PaidInFull]
					, [TransferredFromCourseId], [TransferredToCourseId]
					) WITH (ONLINE = ON) ;
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSTrainerLicenceStateName' 
				AND object_id = OBJECT_ID('DORSTrainerLicenceState'))
		BEGIN
			--Unwanted Index
			DROP INDEX [IX_DORSTrainerLicenceStateName] ON [dbo].[DORSTrainerLicenceState];
		END
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

