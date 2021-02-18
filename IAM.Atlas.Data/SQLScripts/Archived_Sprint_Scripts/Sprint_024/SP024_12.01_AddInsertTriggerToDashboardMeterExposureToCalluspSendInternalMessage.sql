/*
	SCRIPT: Add insert trigger to the DashboardMeterExposure table
	Author: Nick Smith
	Created: 01/08/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP024_12.01_AddInsertTriggerToDashboardMeterExposureToCalluspSendInternalMessage.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Add insert trigger to the DashboardMeterExposure table. 
										Call uspSendInternalMessage for every row Inserted';

EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; /*LOG SCRIPT STARTED*/
GO

IF OBJECT_ID('dbo.[TRG_DashboardMeterExposure_INSERT]', 'TR') IS NOT NULL
		BEGIN
			DROP TRIGGER dbo.[TRG_DashboardMeterExposure_INSERT];
		END
GO
		CREATE TRIGGER TRG_DashboardMeterExposure_INSERT ON DashboardMeterExposure FOR INSERT
AS

		BEGIN

	DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10);
	DECLARE @MessageTitle VARCHAR(250) = 'New Dashboard Meter Available';
	DECLARE @MessageContent VARCHAR(1000) = '';
	DECLARE @DashboardMeterTitle VARCHAR(100) = '';

	DECLARE @NumberOfDashboards INT ;
	DECLARE @DashboardCount INT;
	DECLARE @NumberOfOrgAdmins INT;
	DECLARE @OrgAdminCount INT;

	DECLARE @OrganisationId INT;
	DECLARE @UserId INT;

	/* Drop #OrganisationAdminUserTemp */
	IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects
					WHERE ID = OBJECT_ID(N'tempdb..#OrganisationAdminUserTemp') AND [Type] ='U')
					BEGIN
						DROP TABLE #OrganisationAdminUserTemp
					END

	/* Drop #DashboardMeterExposureTemp */
	IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects
					WHERE ID = OBJECT_ID(N'tempdb..#DashboardMeterExposureTemp') AND [Type] ='U')
					BEGIN
						DROP TABLE #DashboardMeterExposureTemp
			
					END

	/* Create temporary DashboardMeterExposureTemp and Insert */	
	CREATE TABLE #DashboardMeterExposureTemp (
		ID INT IDENTITY(1, 1), 
		DashboardID INT,
		OrgID INT
	)

	INSERT INTO #DashboardMeterExposureTemp
		SELECT DashboardMeterId
			   ,OrganisationId
		FROM Inserted

	SET @NumberOfDashboards = @@ROWCOUNT
	SET @DashboardCount = 1

	/* Create temporary OrgAdminUserTable */	
	CREATE TABLE #OrganisationAdminUserTemp (
		ID INT IDENTITY(1, 1), 
		OrgID INT,
		UserID INT
	)

	-- loop through all records in the dashboardmeterexposuretemp table, design for more than one insert

		WHILE @DashboardCount <= @NumberOfDashboards
		BEGIN

			INSERT INTO #OrganisationAdminUserTemp
				SELECT  oau.OrganisationId
						, oau.UserId
				FROM OrganisationAdminUser oau
				INNER JOIN #DashboardMeterExposureTemp dmet ON dmet.OrgID = oau.OrganisationId
				WHERE dmet.ID = @DashboardCount

				SET @NumberOfOrgAdmins = @@ROWCOUNT
				SET @OrgAdminCount = 1

				SELECT @DashboardMeterTitle = dbm.Title
						FROM DashboardMeter dbm
						INNER JOIN #DashboardMeterExposureTemp dbmt
						ON dbm.Id = dbmt.DashboardId
						
				SET @MessageContent = '';
				SET @MessageContent = 'The Dashboard Meter ' + @DashboardMeterTitle
				SET @MessageContent = @MessageContent + ' is now avaliable. Please use the Dashboard Meter Administration to set who has access.'
				SET @MessageContent = @MessageContent + @NewLineChar + @NewLineChar + 'Atlas Administration.'

				WHILE @OrgAdminCount <= @NumberOfOrgAdmins
					BEGIN
	
						SELECT @OrganisationId = OrgID, @UserId = UserId 
						FROM #OrganisationAdminUserTemp
						WHERE ID = @OrgAdminCount

						--EXEC dbo.uspSendInternalMessage 
						--		@MessageCategoryId
						--		,@MessageTitle
						--		,@MessageContent
						--		,@SendToOrganisationId
						--		,@SendToUserId
						--		,@CreatedByUserId
						--		,@Disabled
						--		,@AllUsers

						EXEC dbo.uspSendInternalMessage 
								1
								,@MessageTitle
								,@MessageContent
								,NULL
								,@UserId
								,3386
								,'false'
								,'false'

						SET @OrgAdminCount = @OrgAdminCount + 1 
					END

					TRUNCATE TABLE #DashboardMeterExposureTemp
				
			SET @DashboardCount = @DashboardCount + 1
		END


		DROP TABLE #DashboardMeterExposureTemp
		DROP TABLE #OrganisationAdminUserTemp

	END


GO
/***END OF SCRIPT***/
DECLARE @ScriptName VARCHAR(100) = 'SP024_12.01_AddInsertTriggerToDashboardMeterExposureToCalluspSendInternalMessage.sql';
		EXEC dbo.uspScriptCompleted @ScriptName; /*LOG SCRIPT COMPLETED*/
		GO