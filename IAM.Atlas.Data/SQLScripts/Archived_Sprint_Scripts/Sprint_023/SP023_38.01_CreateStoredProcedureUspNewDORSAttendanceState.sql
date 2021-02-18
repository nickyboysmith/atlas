/*
	SCRIPT: Notify the system administrators of a new DORS Attendance State
	Author: Paul Tuck
	Created: 26/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_38.01_CreateStoredProcedureUspNewDORSAttendanceState.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Notify the system administrators of a new DORS Attendance State';
		
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
	@NewDORSAttendanceStateId INT,
	@TableName varchar(100),
	@ClientId int,
	@CourseId int = null
)
AS
BEGIN
	
	DECLARE @attendanceStateId INT

	SELECT @attendanceStateId = Id FROM [dbo].[DORSAttendanceState] WHERE id = @NewDORSAttendanceStateId
	
	IF @attendanceStateId IS NULL		-- this is a new attendance state notify the system admins
		BEGIN
			DECLARE @notificationUserId INT;
			DECLARE @notificationUserEmail varchar(400);
			DECLARE @SystemUserId INT;
			SELECT @SystemUserId = Id FROM [User] WHERE name = 'Atlas System';
			DECLARE @messageTitle varchar(400) = 'New DORS Attendance State has been created.';
			DECLARE @messageBody varchar(400);
			IF @CourseId IS NULL
				BEGIN
					SET @messageBody = 'New DORS Attendance State has been created.' 
												+ CHAR(13) + CHAR(10) 
												+ 'New DORS Attendance State has been created. The Id is ' + CAST(@NewDORSAttendanceStateId AS VARCHAR(20)) 
												+ '. It has been entered on Table ' + @TableName 
												+ ' for Client Id: ' + CAST(@ClientId AS VARCHAR(20)) + ' and Course Id: NULL';
				END
			IF @CourseId IS NOT NULL
				BEGIN
					SET @messageBody = 'New DORS Attendance State has been created.' 
												+ CHAR(13) + CHAR(10) 
												+ 'New DORS Attendance State has been created. The Id is ' + CAST(@NewDORSAttendanceStateId AS VARCHAR(20)) 
												+ '. It has been entered on Table ' + @TableName 
												+ ' for Client Id: ' + CAST(@ClientId AS VARCHAR(20)) + ' and Course Id: ' + CAST(@CourseId AS VARCHAR(20));
				END
			INSERT INTO DORSAttendanceState (Id, Name, [Description], UpdatedByUserId, DateUpdated)
				VALUES (@NewDORSAttendanceStateId, 
						'*UNKNOWN* DORS Attendance State Id: ' + CAST(@NewDORSAttendanceStateId AS VARCHAR(20)),
						'*UNKNOWN* DORS Attendance State Id: ' + CAST(@NewDORSAttendanceStateId AS VARCHAR(20)), 
						@SystemUserId,
						GETDATE());

			-- Send an email to the system administrators
			DECLARE @fromAddress varchar(400) = '';
			DECLARE @fromName varchar(400) = '';

			SELECT TOP 1 @fromAddress = [AtlasSystemFromEmail], @fromName = [AtlasSystemFromName] FROM [SystemControl];

			SELECT * INTO #tempNotificationUsers
				FROM
					(
						SELECT 
							[User].Id UserId, 
							[user].Email

						FROM systemAdminUser SAU

						INNER JOIN [user] ON userid = [user].id
					) NotificationUsersQuery;
		
			SELECT @notificationUserId = min(userId) from #tempNotificationUsers;

			WHILE @notificationUserId IS NOT NULL
				BEGIN

					SELECT  @notificationUserEmail = Email
							FROM #tempNotificationUsers
							WHERE UserId = @notificationUserId;


					-- send an email to the organisation administrators
					EXEC	[dbo].[uspSendEmail]
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
				SELECT @notificationUserId = min(UserId) FROM #tempNotificationUsers WHERE UserId > @notificationUserId;
			END

			DROP TABLE #tempNotificationUsers
		END

END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_38.01_CreateStoredProcedureUspNewDORSAttendanceState.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

