/*
	SCRIPT: AMEND SP: Notify the system administrators of a new DORS Attendance State
	Author: Robert Newnham
	Created: 07/10/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP027_19.04_CreateStoredProcedureUspNewDORSAttendanceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'AMEND SP: Notify the system administrators of a new DORS Attendance State';
		
/* LOG SCRIPT STARTED */
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

	/*
		Drop the Procedure if it already exists
	*/		
	IF OBJECT_ID('dbo.uspNewDORSAttendanceState', 'P') IS NOT NULL
	BEGIN
		DROP PROCEDURE dbo.uspNewDORSAttendanceState;
	END		
	GO

	/*
		Create uspNewDORSAttendanceState
	*/
	CREATE PROCEDURE uspNewDORSAttendanceState
	(
		@NewDORSAttendanceStateIdentifier INT,
		@TableName varchar(100),
		@ClientId int,
		@CourseId int = null
	)
	AS
	BEGIN	
		DECLARE @attendanceStateIdentifier INT;

		SELECT @attendanceStateIdentifier = DORSAttendanceStateIdentifier 
		FROM [dbo].[DORSAttendanceState] 
		WHERE id = @NewDORSAttendanceStateIdentifier;
	
		IF @attendanceStateIdentifier IS NULL		-- this is a new attendance state notify the system admins
			BEGIN
				DECLARE @notificationUserId INT;
				DECLARE @notificationUserEmail varchar(400);
				DECLARE @SystemUserId INT = [dbo].[udfGetSystemUserId]();
				DECLARE @NewLine VARCHAR(2) = CHAR(13) + CHAR(10);
				DECLARE @messageTitle varchar(400) = 'New DORS Attendance State has been created.';
				DECLARE @messageBody varchar(400);
				DECLARE @unknownMessage varchar(100) = '*UNKNOWN* DORS Attendance State Id: ' + CAST(@NewDORSAttendanceStateIdentifier AS VARCHAR(20));
				
				SET @messageBody = 'New DORS Attendance State has been created.' 
									+ @NewLine
									+ 'New DORS Attendance State has been created. The Id is ' 
									+ CAST(@NewDORSAttendanceStateIdentifier AS VARCHAR(20)) 
									+ '. It has been entered on Table ' + @TableName 
									+ ' for Client Id: ' + CAST(@ClientId AS VARCHAR(20)) 
									;
				IF @CourseId IS NULL
				BEGIN
					SET @messageBody = @messageBody + ' and Course Id: NULL';
				END

				IF @CourseId IS NOT NULL
				BEGIN
					SET @messageBody = @messageBody + ' and Course Id: ' + CAST(@CourseId AS VARCHAR(20));
				END

				INSERT INTO DORSAttendanceState ([DORSAttendanceStateIdentifier], [Name], [Description], UpdatedByUserId, DateUpdated)
					VALUES (@NewDORSAttendanceStateIdentifier
							, @unknownMessage
							, @unknownMessage
							, @SystemUserId
							, GETDATE());

				-- Send an email to the system administrators
				DECLARE @fromAddress varchar(400) = '';
				DECLARE @fromName varchar(400) = '';

				SELECT @fromAddress = [AtlasSystemFromEmail]
					, @fromName = [AtlasSystemFromName] 
				FROM [SystemControl]
				WHERE Id = 1;

				SELECT * 
				INTO #tempNotificationUsers
				FROM (SELECT [User].Id UserId, [user].Email
					FROM systemAdminUser SAU
					INNER JOIN [user] ON userid = [user].id
					) NotificationUsersQuery;
		
				SELECT @notificationUserId = min(userId) FROM #tempNotificationUsers;

				WHILE @notificationUserId IS NOT NULL
				BEGIN
					SELECT  @notificationUserEmail = Email
					FROM #tempNotificationUsers
					WHERE UserId = @notificationUserId;

					-- send an email to the organisation administrators
					EXEC [dbo].[uspSendEmail]
						@requestedByUserId = @notificationUserId /* TODO: This bit needs to change to a General System User Id */
						, @fromName = @fromName
						, @fromEmailAddresses  = @fromAddress
						, @toEmailAddresses = @notificationUserEmail
						, @ccEmailAddresses = null
						, @bccEmailAddresses = null
						, @emailSubject = @MessageTitle
						, @emailContent = @MessageBody
						, @asapFlag = NULL
						, @sendAfterDateTime = NULL
						, @emailServiceId = NULL
						, @organisationId = NULL;

					-- get the next notification user's Id
					SELECT @notificationUserId = min(UserId) 
					FROM #tempNotificationUsers 
					WHERE UserId > @notificationUserId;
				END

				DROP TABLE #tempNotificationUsers;
			END

	END
	GO
	
DECLARE @ScriptName VARCHAR(100) = 'SP027_19.04_CreateStoredProcedureUspNewDORSAttendanceState.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

