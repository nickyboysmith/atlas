

/*
	Data Migration Script :- Migrate DORS Data.
	Author: Robert Newnham
	Created: 25/07/2016
	NB: This Script can be run multiple times. It will only insert missing Data.

	NB. CourseTypes Migration should be done before this.

*/



/******************* Migrate Tables into New Atlas *******************************************************************/

PRINT('');PRINT('******************************************************************************************')
PRINT('');PRINT('**Running Script: "Migration_200.001_DORSDataMigration.sql" ' + CAST(GETDATE() AS VARCHAR));

/**************************************************************************************************/

	PRINT('');PRINT('*Populate DORS Tables ' + CAST(GETDATE() AS VARCHAR));
	
	PRINT('');PRINT('*****************************************************************************');
	PRINT('');PRINT('**DISABLE SOME TRIGGERS');
	DISABLE TRIGGER dbo.[TRG_DORSLicenceCheckCompleted_INSERT] ON dbo.DORSLicenceCheckCompleted;
	GO


	DECLARE @LiveMigration BIT = 'True';
	DECLARE @MigrateDataFor VARCHAR(200) = 'Cleveland Driver Improvement Group';
	DECLARE @MigrateDataForRegion VARCHAR(200) = 'Cleveland';
	DECLARE @MigrateDataForOldId INT = (SELECT TOP 1 [org_id] FROM migration.[tbl_LU_Organisation] WHERE [org_name] = @MigrateDataFor);
	DECLARE @MigrateDataForOldRgnId INT = (SELECT TOP 1 rgn_id FROM migration.tbl_LU_Region WHERE [rgn_description] = @MigrateDataForRegion);
	DECLARE @MigrateDataForNewId INT = (SELECT TOP 1 Id FROM [dbo].[Organisation] WHERE [Name] = @MigrateDataFor);
	
	PRINT('');PRINT('*Migrating Data For: ' + @MigrateDataFor 
					+ ' .... OldSystemID: ' + CAST(@MigrateDataForOldId AS VARCHAR)
					+ ' .... NewSystemID: ' + CAST(@MigrateDataForNewId AS VARCHAR)
					);

	--*Get System User Ids
	BEGIN
		PRINT('');PRINT('*Get System User Ids ' + CAST(GETDATE() AS VARCHAR));
		DECLARE @SysUserId int;
		DECLARE @MigrationUserId int
		DECLARE @UnknownUserId int;
		SELECT @SysUserId=Id FROM [User] WHERE Name = 'Atlas System';
		SELECT @MigrationUserId=Id FROM [User] WHERE Name = 'Migration';
		SELECT @UnknownUserId=Id FROM [User] WHERE Name = 'Unknown User';
	END

	--*Populate DORS Connection Details
	BEGIN
		PRINT('');PRINT('*Populate DORS Tables ' + CAST(GETDATE() AS VARCHAR));
		DECLARE @NewDorsStateId int;
		SELECT @NewDorsStateId=Id FROM [dbo].[DORSState] NewDS WHERE NewDS.Name = 'Normal';
		
		--INSERT INTO [DORSConnection] Table
		PRINT('');PRINT('-INSERT INTO [DORSConnection] Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSConnection] (
											LoginName
											, Password
											, OrganisationId
											, Enabled
											, PasswordLastChanged
											, NotificationEmail
											, UpdatedByUserId
											, LastNotificationSent
											, DORSStateId
											)
		SELECT OldDL.[lg_username] AS LoginName
			, OldDL.[lg_password] AS Password
			, NewOrg.Id AS OrganisationId
			, OldDL.[lg_disable_dors] AS Enabled
			, OldDL.[lg_lastDateChanged] AS PasswordLastChanged
			, OldDL.[lg_notificationAddress] AS NotificationEmail
			, @MigrationUserId AS UpdatedByUserId
			, CAST('01/01/01' AS Datetime) AS LastNotificationSent
			, @NewDorsStateId AS DORSStateId
		FROM [migration].tbl_DORS_Logins OldDL
		INNER JOIN [migration].tbl_LU_Organisation OldOrg ON OldOrg.org_id = OldDL.lg_owner_org_id
		INNER JOIN [dbo].Organisation NewOrg ON NewOrg.Name = OldOrg.org_name
		LEFT JOIN [dbo].[DORSState] NewDS ON NewDS.Name = 'Normal'
		WHERE NOT EXISTS (SELECT * 
							FROM [dbo].[DORSConnection] DC 
							WHERE DC.[LoginName] = OldDL.lg_username
							AND DC.[OrganisationId] = NewOrg.Id)


	END

	BEGIN		
		--INSERT INTO DORSLicenceCheckCompleted Table
		PRINT('');PRINT('-INSERT INTO DORSLicenceCheckCompleted Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSLicenceCheckCompleted] (
			ClientId
			, LicenceNumber
			, RequestByUserId
			, Requested
			, Completed
			, DORSAttendanceStateIdentifier
			, DORSAttendanceIdentifier
			, DORSSessionIdentifier
			, DORSLicenceCheckRequestId
			)
		SELECT 
			CPI.[ClientId]						AS ClientId
			, Old_LL.dl_licenceNumber			AS LicenceNumber
			, NULL								AS RequestByUserId
			, Old_LL.dl_date					AS Requested
			, Old_LL.dl_date					AS Completed
			, Old_LL.dl_dorsAttendanceID		AS DORSAttendanceStateIdentifier
			, Old_LL.dl_dorsAttendanceStatusId	AS DORSAttendanceIdentifier
			, Old_LL.dl_sessionId				AS DORSSessionIdentifier
			, NULL								AS DORSLicenceCheckRequestId
		FROM [migration].[tbl_DORS_LicenceLookups] Old_LL
		LEFT JOIN [dbo].[ClientPreviousId] CPI ON CPI.[PreviousClientId] = Old_LL.dl_dr_id
		LEFT JOIN [dbo].[DORSLicenceCheckCompleted] DLCC ON DLCC.ClientId = CPI.[ClientId]
														AND DLCC.LicenceNumber = Old_LL.dl_licenceNumber
														AND DLCC.Requested = Old_LL.dl_date
		WHERE DLCC.Id IS NULL; /* IE NOT INSERTED YET */

	END
	
	BEGIN		
		--INSERT INTO DORSScheme Table
		PRINT('');PRINT('-INSERT INTO DORSScheme Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSScheme] (DORSSchemeIdentifier, [Name])
		SELECT 
			Old_DS.[sch_id] AS DORSSchemeIdentifier
			, Old_DS.[sch_name] AS [Name]
		FROM [migration].[tbl_DORS_Schemes] Old_DS
		LEFT JOIN [dbo].[DORSScheme] DS ON DS.DORSSchemeIdentifier = Old_DS.[sch_id]
										AND DS.[Name] = Old_DS.[sch_name]
		WHERE DS.Id IS NULL; /* IE NOT INSERTED YET */

	END
	
	BEGIN		
		--INSERT INTO DORSForce Table
		PRINT('');PRINT('-INSERT INTO DORSForce Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSForce] ([Name], DORSForceIdentifier, PNCCode)
		SELECT 
			Old_DF.[for_name] AS [Name]
			, Old_DF.[for_id] AS DORSForceIdentifier
			, NULL AS PNCCode
		FROM [migration].[tbl_DORS_Forces] Old_DF
		LEFT JOIN [dbo].[DORSForce] DF ON DF.[Name] = Old_DF.[for_name]
										AND DF.DORSForceIdentifier = Old_DF.[for_id]
		WHERE DF.Id IS NULL; /* IE NOT INSERTED YET */

	END
	
	BEGIN		
		--INSERT INTO DORSForceContract Table
		PRINT('');PRINT('-INSERT INTO DORSForceContract Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSForceContract] (
			DORSForceContractIdentifier
			, DORSForceIdentifier
			, DORSSchemeIdentifier
			, StartDate
			, EndDate
			, CourseAdminFee
			, DORSAccreditationIdentifier
			)
		SELECT DISTINCT
			DFC.[fc_id]												AS DORSForceContractIdentifier
			, DFC.[fc_for_id]										AS DORSForceIdentifier
			, DFC.[fc_sch_id]										AS DORSSchemeIdentifier
			, (CASE WHEN DFC_ORCT.[fcorc_startDate] IS NULL
					THEN CAST('01/01/01' AS DATETIME)
					ELSE DFC_ORCT.[fcorc_startDate]
					END)											AS ForceContractStartDate
			, (CASE WHEN DFC_ORCT.[fcorc_startDate] IS NULL
					THEN NULL
					ELSE DFC_ORCT.[fcorc_endDate]
					END)											AS ForceContractEndDate
			, (CASE WHEN DFC_ORCT.[fcorc_startDate] IS NULL
					THEN NULL
					ELSE DFC_ORCT.[fcorc_courseFee]
					END)											AS ForceContractCourseFee
			, NULL													AS DORSAccreditationIdentifier
		FROM [migration].[tbl_DORS_ForceContracts] DFC
		INNER JOIN [migration].[tbl_DORS_Forces] DF											ON DF.[for_id] = DFC.[fc_for_id]
		INNER JOIN [migration].[tbl_DORS_Schemes] DS										ON DS.[sch_id] = DFC.[fc_sch_id]
		LEFT JOIN [migration].[tbl_DORS_ForceContracts_Organisation_RegCrseType] DFC_ORCT	ON DFC_ORCT.[fcorc_fc_id] =  DFC.[fc_id]
		LEFT JOIN [dbo].[DORSForceContract] DFC_New											ON DFC_New.DORSForceContractIdentifier = DFC.[fc_id]
																							AND DFC_New.DORSForceIdentifier = DFC.[fc_for_id]
																							AND DFC_New.DORSSchemeIdentifier = DFC.[fc_sch_id]
		WHERE DFC_New.Id IS NULL
		OR DFC_New.StartDate != (CASE WHEN DFC_ORCT.[fcorc_startDate] IS NULL
									THEN CAST('01/01/01' AS DATETIME)
									ELSE DFC_ORCT.[fcorc_startDate]
									END)
		; 

	END

	BEGIN
			INSERT INTO dbo.OrganisationDORSForceContract (OrganisationId, DORSForceContractId)
			SELECT 
				NewO.Id			AS OrganisationId
				, NewDFC.Id		AS DORSForceContractId
			FROM [migration].[tbl_WebServiceUsers] WSU
			INNER JOIN migration.tbl_region_CourseType RCT			ON RCT.rct_id = WSU.[web_rct_id]
			INNER JOIN [migration].[tbl_DORS_ForceContracts] DFC	ON DFC.[fc_id] = WSU.[web_dors_fc_id]
			INNER JOIN migration.tbl_Organisation_RegCrseType ORCT	ON ORCT.[orc_rct_id] = WSU.[web_rct_id]
			INNER JOIN migration.tbl_LU_Organisation OldO			ON OldO.org_id = ORCT.orc_org_id
			INNER JOIN dbo.Organisation NewO						ON NewO.Name = OldO.org_name	
			INNER JOIN [dbo].[DORSForceContract] NewDFC				ON NewDFC.DORSForceContractIdentifier = DFC.[fc_id]
			LEFT JOIN dbo.OrganisationDORSForceContract ODFC		ON ODFC.OrganisationId = NewO.Id
																	AND ODFC.DORSForceContractId = NewDFC.Id
			WHERE ODFC.Id IS NULL; /* Only Insert if Missing */				
	END
	
	BEGIN		
		--INSERT INTO DORSSchemeCourseType Table
		PRINT('');PRINT('-INSERT INTO DORSSchemeCourseType Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSSchemeCourseType] (CourseTypeId, DORSSchemeId, DateCreated)
		SELECT DISTINCT
			NewCT.Id		AS CourseTypeId
			, DS.Id			AS DORSSchemeId
			, GETDATE()		AS DateCreated
		FROM [migration].[tbl_DORS_Schemes] Old_DS
		INNER JOIN [dbo].[DORSScheme] DS ON DS.[DORSSchemeIdentifier] = Old_DS.[sch_id]
		INNER JOIN [migration].[tbl_LU_CourseType] Old_CT ON Old_CT.[ct_ID] = Old_DS.[sch_ct_id]
		INNER JOIN dbo.CourseType NewCT ON NewCT.Title = Old_CT.ct_LongDescription
										AND NewCT.Code = Old_CT.ct_Description
		LEFT JOIN DORSSchemeCourseType DSCT ON DSCT.CourseTypeId = NewCT.Id
											AND DSCT.DORSSchemeId = DS.Id
		WHERE DSCT.Id IS NULL /* IE NOT INSERTED YET */
		AND NewCT.Id IS NOT NULL
		AND DS.Id IS NOT NULL
		;
	END

	BEGIN
		PRINT('');PRINT('-INSERT INTO ClientDORSData Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[ClientDORSData] (
			ClientId, ReferringAuthorityId, DateReferred, DORSAttendanceRef
			, DateCreated, DateUpdated, ExpiryDate, DORSSchemeId, DataValidatedAgainstDORS
			, DORSAttendanceStateId, IsMysteryShopper
			)
		SELECT DISTINCT
				CPI.ClientId				AS [ClientId]
			  , RA.Id						AS [ReferringAuthorityId]
			  , NULL						AS [DateReferred]
			  , DDD.[dd_dorsAttendanceID]	AS [DORSAttendanceRef]
			  , DDD.dd_dateStatusChange		AS [DateCreated]
			  , DDD.dd_dateStatusChange		AS [DateUpdated]
			  , DR.dr_date_critical			AS [ExpiryDate]
			  , DSCT.[DORSSchemeId]			AS [DORSSchemeId]
			  , NULL						AS [DataValidatedAgainstDORS]
			  , DAS.Id						AS [DORSAttendanceStateId]
			  , 'False'						AS [IsMysteryShopper]
		FROM dbo.ClientPreviousId CPI
		INNER JOIN [migration].[tbl_Driver] DR ON DR.dr_ID = CPI.PreviousClientId
		INNER JOIN [migration].[tbl_Driver_DorsData] DDD ON DDD.[dd_dr_id] = CPI.PreviousClientId
		INNER JOIN dbo.CoursePreviousId COPI ON COPI.PreviousCourseId = DR.[dr_crs_ID]
		INNER JOIN dbo.Course C ON C.Id = COPI.CourseId
		INNER JOIN [dbo].[DORSSchemeCourseType] DSCT ON DSCT.CourseTypeId = C.CourseTypeId
		INNER JOIN [dbo].[DORSAttendanceState] DAS ON DAS.DORSAttendanceStateIdentifier = DDD.[dd_dorsStatus]
		--LEFT JOIN [migration].[tbl_DORS_CourseCompletions] DCC ON DCC.[cc_dr_id] = CPI.PreviousClientId
		LEFT JOIN [migration].[tbl_LU_Organisation] O ON O.org_id = DR.dr_referrer_org_ID
		LEFT JOIN dbo.ReferringAuthority RA ON RA.Name = O.org_name
		LEFT JOIN [dbo].[ClientDORSData] CDD ON CDD.ClientId = CPI.ClientId
		WHERE CDD.Id IS NULL;
	END

	BEGIN
		PRINT('');PRINT('-INSERT INTO DORSCourse Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSCourse] ([CourseId],[DORSCourseIdentifier])
		SELECT DISTINCT COPI.CourseId, CDD.[cd_CourseID] AS [DORSCourseIdentifier]
		FROM dbo.CoursePreviousId COPI
		INNER JOIN [migration].[tbl_Course_DorsData] CDD ON CDD.[cd_crs_id] = COPI.PreviousCourseId
		LEFT JOIN dbo.[DORSCourse] DC ON DC.[CourseId] = COPI.CourseId
		WHERE DC.Id IS NULL;

		
		PRINT('');PRINT('-INSERT INTO CourseDORSForceContract Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.CourseDORSForceContract (CourseId, DORSForceContractId)
		SELECT DISTINCT 
			C.id		AS CourseId
			, DFC.id	AS DORSForceContractId
		FROM dbo.Course C
		INNER JOIN [dbo].[DORSSchemeCourseType] DSCT			ON DSCT.CourseTypeId = C.CourseTypeId
		INNER JOIN [dbo].[DORSScheme] DS						ON DS.id = DSCT.dorsSchemeid
		INNER JOIN [dbo].[DORSForceContract] DFC				ON DFC.[DORSSchemeIdentifier] = DS.[DORSSchemeIdentifier]
		INNER JOIN [dbo].[OrganisationDORSForceContract] ODFC	ON ODFC.[DORSForceContractId] = DFC.id
		LEFT JOIN dbo.CourseDORSForceContract CDFC				ON CDFC.CourseId = C.id
																AND CDFC.DORSForceContractId = DFC.id
		WHERE CDFC.Id IS NULL;

	END

	BEGIN	
		PRINT('');PRINT('-INSERT INTO DORSTrainerLicence Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO dbo.DORSTrainerLicence (
			DORSSchemeIdentifier
			, DORSTrainerIdentifier
			, DORSTrainerLicenceTypeName
			, LicenceCode
			, ExpiryDate
			, DORSTrainerLicenceStateName
			, DateAdded
			)
		SELECT DISTINCT
			 SCH.sch_id							AS DORSSchemeIdentifier
			 , IDD.idd_dorsTrainerId			AS DORSTrainerIdentifier
			 , DTLT.dtlt_name					AS DORSTrainerLicenceTypeName
			 , IDD.idd_licenseCode				AS LicenceCode
			 , IDD.idd_dorsLicenceExpiryDate	AS ExpiryDate
			 , DTLS.dtls_name					AS DORSTrainerLicenceStateName
			 , GETDATE()						AS DateAdded
		FROM [migration].[tbl_Instructor_DorsData] IDD
		INNER JOIN [migration].[tbl_DORS_TrainerLicenceStatuses] DTLS			ON DTLS.dtls_id = IDD.idd_dtls_id
		INNER JOIN [migration].[tbl_DORS_TrainerLicenceTypes] DTLT				ON IDD.idd_dtlt_id = DTLT.dtlt_id
		INNER JOIN [migration].[tbl_DORS_Schemes] SCH							ON SCH.sch_ct_id = IDD.idd_ct_id
		LEFT JOIN dbo.DORSTrainerLicence DTL									ON DTL.DORSSchemeIdentifier = SCH.sch_id
																				AND DTL.DORSTrainerIdentifier = IDD.idd_dorsTrainerId
																				AND DTL.LicenceCode = IDD.idd_licenseCode
																				AND DTL.ExpiryDate = IDD.idd_dorsLicenceExpiryDate
		WHERE DTL.ID IS NULL
		;

		/*************************************************************************************************************************************/
		PRINT('');PRINT('-INSERT INTO DORSTrainerLicenceType Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSTrainerLicenceType] (Identifier, [Name], Notes, DateAdded, UpdatedByUserId, DateUpdated)
		SELECT DISTINCT
			DTLT.[dtlt_id]			AS Identifier
			, DTLT.[dtlt_name]		AS [Name]
			, ''					AS Notes
			, GETDATE()				AS DateAdded
			, @MigrationUserId		AS UpdatedByUserId
			, GETDATE()				AS DateUpdated
		FROM [migration].[tbl_DORS_TrainerLicenceTypes] DTLT
		LEFT JOIN [dbo].[DORSTrainerLicenceType] DTLT2 ON DTLT2.[Name] = DTLT.[dtlt_name]
		WHERE DTLT2.Id IS NULL;
		
		/*************************************************************************************************************************************/
		PRINT('');PRINT('-INSERT INTO DORSTrainer Table ' + CAST(GETDATE() AS VARCHAR));
		INSERT INTO [dbo].[DORSTrainer] (TrainerId, DateUpdated, UpdatedByUserId, DORSTrainerIdentifier, LicenceCode, DORSLicenceExpiry)
		SELECT DISTINCT
			TRPI.TrainerId						AS TrainerId
			, GETDATE()							AS DateUpdated
			, @MigrationUserId					AS UpdatedByUserId
			, IDD.[idd_dorsTrainerID]			AS DORSTrainerIdentifier
			, IDD.[idd_LicenseCode]				AS LicenceCode
			, IDD.[idd_dorsLicenceExpiryDate]	AS DORSLicenceExpiry
		FROM dbo.TrainerPreviousId TRPI
		INNER JOIN [migration].[tbl_Instructor_DorsData] IDD	ON IDD.[idd_ins_id] = TRPI.PreviousTrainerId
		LEFT JOIN [dbo].[DORSTrainer] DT						ON DT.TrainerId = TRPI.TrainerId
		WHERE DT.Id IS NULL;
		
		/*************************************************************************************************************************************/

	END

	

/**************************************************************************************************************************/

	
	PRINT('');PRINT('*****************************************************************************');
	PRINT('');PRINT('**ENABLE DISABLED TRIGGERS');
	ENABLE TRIGGER dbo.[TRG_DORSLicenceCheckCompleted_INSERT] ON dbo.DORSLicenceCheckCompleted;
	GO


	
PRINT('');PRINT('**Completed Script: "Migration_200.001_DORSDataMigration.sql" ' + CAST(GETDATE() AS VARCHAR));
PRINT('');PRINT('******************************************************************************************')

/**************************************************************************************************************************/
