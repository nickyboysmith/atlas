
/*
 * SCRIPT: Add Missing Indexes.
 * Author: Robert Newnham
 * Created: 07/10/2016
 */

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.05_AddMissingIndexes.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add Missing Indexs to tables';
IF (dbo.udfAllScriptsCompletedExcept(@ScriptName) = 'True')
	BEGIN
		EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
		/***START OF SCRIPT***/
			
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_CourseOverBookingNotificationCourseId' 
				AND object_id = OBJECT_ID('CourseOverBookingNotification'))
		BEGIN
		   DROP INDEX [IX_CourseOverBookingNotificationCourseId] ON [dbo].[CourseOverBookingNotification];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_CourseOverBookingNotificationCourseId] ON [dbo].[CourseOverBookingNotification]
		(
			[CourseId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientId' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientId] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientId] ON [dbo].[ClientPhone]
		(
			[ClientId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientIdPhoneTypeId' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientIdPhoneTypeId] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientIdPhoneTypeId] ON [dbo].[ClientPhone]
		(
			[ClientId], [PhoneTypeId] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientIdDefaultNumber' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone]
		(
			[ClientId], [DefaultNumber] ASC
		);
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_ClientPhoneClientIdDefaultNumber' 
				AND object_id = OBJECT_ID('ClientPhone'))
		BEGIN
		   DROP INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone];
		END
		
		--Now Create Index
		CREATE NONCLUSTERED INDEX [IX_ClientPhoneClientIdDefaultNumber] ON [dbo].[ClientPhone]
		(
			[ClientId], [DefaultNumber] ASC
		);

		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_MessageRecipientUserId_INC_MessageId' 
				AND object_id = OBJECT_ID('MessageRecipient'))
		BEGIN
		   DROP INDEX [IX_MessageRecipientUserId_INC_MessageId] ON [dbo].[MessageRecipient];
		END
		
		CREATE NONCLUSTERED INDEX [IX_MessageRecipientUserId_INC_MessageId] ON [dbo].[MessageRecipient] 
		(
			[UserId]
		) INCLUDE ([MessageId]) WITH (ONLINE = ON)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSLicenceCheckCompletedDORSAttendanceStateIdentifier' 
				AND object_id = OBJECT_ID('DORSLicenceCheckCompleted'))
		BEGIN
		   DROP INDEX [IX_DORSLicenceCheckCompletedDORSAttendanceStateIdentifier] ON [dbo].[DORSLicenceCheckCompleted];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSLicenceCheckCompletedDORSAttendanceStateIdentifier] ON [dbo].[DORSLicenceCheckCompleted] 
		(
			[DORSAttendanceStateIdentifier]
		)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSLicenceCheckCompletedDORSAttendanceRef' 
				AND object_id = OBJECT_ID('DORSLicenceCheckCompleted'))
		BEGIN
		   DROP INDEX [IX_DORSLicenceCheckCompletedDORSAttendanceRef] ON [dbo].[DORSLicenceCheckCompleted];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSLicenceCheckCompletedDORSAttendanceRef] ON [dbo].[DORSLicenceCheckCompleted] 
		(
			[DORSAttendanceRef]
		)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSLicenceCheckCompletedClientId' 
				AND object_id = OBJECT_ID('DORSLicenceCheckCompleted'))
		BEGIN
		   DROP INDEX [IX_DORSLicenceCheckCompletedClientId] ON [dbo].[DORSLicenceCheckCompleted];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSLicenceCheckCompletedClientId] ON [dbo].[DORSLicenceCheckCompleted] 
		(
			[ClientId]
		)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSClientCourseAttendanceDORSAttendanceStateIdentifier' 
				AND object_id = OBJECT_ID('DORSClientCourseAttendance'))
		BEGIN
		   DROP INDEX [IX_DORSClientCourseAttendanceDORSAttendanceStateIdentifier] ON [dbo].[DORSClientCourseAttendance];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSClientCourseAttendanceDORSAttendanceStateIdentifier] ON [dbo].[DORSClientCourseAttendance] 
		(
			[DORSAttendanceStateIdentifier]
		)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSClientCourseAttendanceDORSAttendanceRef' 
				AND object_id = OBJECT_ID('DORSClientCourseAttendance'))
		BEGIN
		   DROP INDEX [IX_DORSClientCourseAttendanceDORSAttendanceRef] ON [dbo].[DORSClientCourseAttendance];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSClientCourseAttendanceDORSAttendanceRef] ON [dbo].[DORSClientCourseAttendance] 
		(
			[DORSAttendanceRef]
		)
		
		/************************************************************************************/
		
		--Drop Index if Exists
		IF EXISTS(SELECT * 
				FROM sys.indexes 
				WHERE name='IX_DORSClientCourseAttendanceClientId' 
				AND object_id = OBJECT_ID('DORSClientCourseAttendance'))
		BEGIN
		   DROP INDEX [IX_DORSClientCourseAttendanceClientId] ON [dbo].[DORSClientCourseAttendance];
		END
		
		CREATE NONCLUSTERED INDEX [IX_DORSClientCourseAttendanceClientId] ON [dbo].[DORSClientCourseAttendance] 
		(
			[ClientId]
		)
		
		/************************************************************************************/
		
		/***END OF SCRIPT***/
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
	END
ELSE
	BEGIN
		PRINT '******Script "' + @ScriptName + '" Not Run******';
	END
;

