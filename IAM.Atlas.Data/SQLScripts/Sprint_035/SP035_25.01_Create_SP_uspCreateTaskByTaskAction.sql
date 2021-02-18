/*
	SCRIPT: Create uspCreateTaskByTaskAction
	Author: Robert Newnham
	Created: 27/03/2017
*/

DECLARE @ScriptName VARCHAR(100) = 'SP035_25.01_Create_SP_uspCreateTaskByTaskAction.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Create uspCreateTaskByTaskAction';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateTaskByTaskAction', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateTaskByTaskAction;
END		
GO
	/*
		Create uspCreateTaskByTaskAction
	*/

	CREATE PROCEDURE dbo.uspCreateTaskByTaskAction (
		@OrganisationId INT
		, @TaskActionName VARCHAR(100)
		, @TaskTitle VARCHAR(100)
		, @TaskCategoryId INT
		, @UserId INT
		, @DeadlineDate DATETIME = NULL
		, @TaskRelatedToClientId INT = NULL
		, @TaskRelatedToCourseId INT = NULL
		, @TaskRelatedToTrainerId INT = NULL
		, @TaskNote VARCHAR(1000) = NULL
		)
	AS
	BEGIN
		/* This Stored Procedure will Create a Task and Assign the Task based on the TaskAction */
		DECLARE @TADescription VARCHAR(400)
			, @TAPriorityNumber INT
			, @TAAssignToOrganisation BIT
			, @TAAssignToOrganisationAdminstrators BIT
			, @TAAssignToOrganisationSupportGroup BIT
			, @TAAssignToAtlasSystemAdministrators BIT
			, @TAAssignToAtlasSystemSupportGroup BIT
			;
		/* Get The Task Action Settings. This will let us know who to assign the task to and what Priority it should be set at */
		SELECT @TADescription = TA.[Description]
			, @TAPriorityNumber = (CASE WHEN TAPFO.Id IS NULL THEN TA.PriorityNumber ELSE TAPFO.PriorityNumber END)
			, @TAAssignToOrganisation = (CASE WHEN TAPFO.Id IS NULL THEN TA.AssignToOrganisation ELSE TAPFO.AssignToOrganisation END)
			, @TAAssignToOrganisationAdminstrators = (CASE WHEN TAPFO.Id IS NULL THEN TA.AssignToOrganisationAdminstrators ELSE TAPFO.AssignToOrganisationAdminstrators END)
			, @TAAssignToOrganisationSupportGroup = (CASE WHEN TAPFO.Id IS NULL THEN TA.AssignToOrganisationSupportGroup ELSE TAPFO.AssignToOrganisationSupportGroup END)
			, @TAAssignToAtlasSystemAdministrators = (CASE WHEN TAPFO.Id IS NULL THEN TA.AssignToAtlasSystemAdministrators ELSE TAPFO.AssignToAtlasSystemAdministrators END)
			, @TAAssignToAtlasSystemSupportGroup = (CASE WHEN TAPFO.Id IS NULL THEN TA.AssignToAtlasSystemSupportGroup ELSE TAPFO.AssignToAtlasSystemSupportGroup END)
		FROM dbo.TaskAction TA
		LEFT JOIN [dbo].[TaskActionPriorityForOrganisation] TAPFO ON TAPFO.[TaskActionId] = TA.[Id]
																AND TAPFO.[OrganisationId] = @OrganisationId
		WHERE TA.[Name] = @TaskActionName;

		IF (@TADescription IS NOT NULL) --Valid TackAction Used
		BEGIN
			DECLARE @NewTaskId INT;
			DECLARE @NewNoteId INT;
			INSERT INTO [dbo].[Task] (
				TaskCategoryId
				, Title
				, PriorityNumber
				, DateCreated
				, CreatedByUserId
				, DeadlineDate
				)
			VALUES (
				@TaskCategoryId
				, @TaskTitle
				, @TAPriorityNumber
				, GETDATE()
				, @UserId
				, @DeadlineDate
				);
			
			SET @NewTaskId = SCOPE_IDENTITY();
			
			IF (LEN(ISNULL(@TaskNote,'')) > 0)
			BEGIN
				--Insert a Task Note if Required
				INSERT INTO [dbo].[Note] (
					Note
					, DateCreated
					, CreatedByUserId
					, NoteTypeId
					)
				VALUES (
					@TaskNote
					, GETDATE()
					, @UserId
					, (SELECT Id FROM dbo.NoteType WHERE [Name] = 'General')
					);
			
				SET @NewNoteId = SCOPE_IDENTITY();

				INSERT INTO [dbo].[TaskNote] (TaskId, NoteId)
				SELECT @NewTaskId AS TaskId, @NewNoteId AS NoteId
				WHERE @NewNoteId IS NOT NULL;
			END --IF (LEN(ISNULL(@TaskNote,'')) > 0)

			--Insert Task For Organisation if Required
			INSERT INTO [dbo].[TaskForOrganisation] (OrganisationId, TaskId)
			SELECT @OrganisationId AS OrganisationId, @NewTaskId AS TaskId
			WHERE @TAAssignToOrganisation = 'True'
			AND NOT EXISTS (SELECT * FROM [dbo].[TaskForOrganisation] WHERE OrganisationId = @OrganisationId AND TaskId = @NewTaskId);
			
			--Insert Task For Organisation Adminstrators if Required
			INSERT INTO [dbo].[TaskForUser] (UserId, TaskId, DateAdded, AssignedByUserId)
			SELECT DISTINCT T.UserId, T.TaskId, T.DateAdded, T.AssignedByUserId
			FROM (
				SELECT OAU.UserId AS UserId, @NewTaskId AS TaskId, GETDATE() AS DateAdded, @UserId AS AssignedByUserId
				FROM dbo.OrganisationAdminUser OAU
				WHERE @TAAssignToOrganisationAdminstrators = 'True'
				AND OAU.OrganisationId = @OrganisationId
				UNION --Insert Task For Organisation System Support Users if Required
				SELECT SSU.UserId AS UserId, @NewTaskId AS TaskId, GETDATE() AS DateAdded, @UserId AS AssignedByUserId
				FROM dbo.SystemSupportUser SSU
				WHERE @TAAssignToOrganisationSupportGroup = 'True'
				AND SSU.OrganisationId = @OrganisationId
				UNION --Insert Task For Atlas System Administrator Users if Required
				SELECT SAU.UserId AS UserId, @NewTaskId AS TaskId, GETDATE() AS DateAdded, @UserId AS AssignedByUserId
				FROM [dbo].[SystemAdminUser] SAU
				WHERE @TAAssignToAtlasSystemAdministrators = 'True'
				UNION --Insert Task For Atlas System Administrator Users Who Are Currently Providing Support if Required
				SELECT SAU.UserId AS UserId, @NewTaskId AS TaskId, GETDATE() AS DateAdded, @UserId AS AssignedByUserId
				FROM [dbo].[SystemAdminUser] SAU
				WHERE @TAAssignToAtlasSystemSupportGroup = 'True'
				AND SAU.CurrentlyProvidingSupport = 'True'
				) T
			LEFT JOIN [dbo].[TaskForUser] TFU ON TFU.UserId = T.UserId
											AND TFU.TaskId = T.TaskId
			WHERE TFU.Id IS NULL --Not Already Inserted
			;
			/* NB The Above Query is done as a UNION so that we do not insert duplicates. */
			
			--Insert Task For Client if Required
			INSERT INTO [dbo].[TaskRelatedToClient] (ClientId, TaskId)
			SELECT @TaskRelatedToClientId AS ClientId, @NewTaskId AS TaskId
			WHERE @TaskRelatedToClientId IS NOT NULL
			AND NOT EXISTS (SELECT * FROM [dbo].[TaskRelatedToClient] WHERE ClientId = @TaskRelatedToClientId AND TaskId = @NewTaskId);
			
			--Insert Task For Course if Required
			INSERT INTO [dbo].[TaskRelatedToCourse] (CourseId, TaskId)
			SELECT @TaskRelatedToCourseId AS CourseId, @NewTaskId AS TaskId
			WHERE @TaskRelatedToCourseId IS NOT NULL
			AND NOT EXISTS (SELECT * FROM [dbo].[TaskRelatedToCourse] WHERE CourseId = @TaskRelatedToCourseId AND TaskId = @NewTaskId);
			
			--Insert Task For Trainer if Required
			INSERT INTO [dbo].[TaskRelatedToTrainer] (TrainerId, TaskId)
			SELECT @TaskRelatedToTrainerId AS TrainerId, @NewTaskId AS TaskId
			WHERE @TaskRelatedToTrainerId IS NOT NULL
			AND NOT EXISTS (SELECT * FROM [dbo].[TaskRelatedToTrainer] WHERE TrainerId = @TaskRelatedToTrainerId AND TaskId = @NewTaskId);
			
		END --IF (@TADescription IS NOT NULL)
	END --End SP
GO

DECLARE @ScriptName VARCHAR(100) = 'SP035_25.01_Create_SP_uspCreateTaskByTaskAction.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO