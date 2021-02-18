
/*
	SCRIPT: Update the stored procedure to Create the Migration External Tables Linked to Old Atlas
	Author: Robert Newnham
	Created: 18/07/2016
*/

DECLARE @ScriptName VARCHAR(100) = 'SP023_22.01_Update_uspCreateMigrationExternalTables.sql';
DECLARE @ScriptComments VARCHAR(800) = 'Update the stored procedure to Create the Migration External Tables Linked to Old Atlas';
		
/*LOG SCRIPT STARTED*/
EXEC dbo.uspScriptStarted @ScriptName, @ScriptComments; 
GO

/*
	Drop the Procedure if it already exists
*/		
IF OBJECT_ID('dbo.uspCreateMigrationExternalTables', 'P') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.uspCreateMigrationExternalTables;
END		
GO

/*
	Create uspCreateMigrationExternalTables
*/
CREATE PROCEDURE uspCreateMigrationExternalTables
AS
BEGIN
	
	
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_AdminLevels_Groups](
		[alg_id] [int] NOT NULL,
		[alg_name] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_BulkDeletions](
		[bd_id] [int] NOT NULL,
		[bd_sessionId] [uniqueidentifier] NOT NULL,
		[bd_entered_dr_id] [varchar](50) NOT NULL,
		[bd_dr_id] [int] NULL,
		[bd_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Calendars](
		[cal_id] [int] NOT NULL,
		[cal_usr_id] [int] NOT NULL,
		[cal_date_start] [datetime] NOT NULL,
		[cal_length_minutes] [int] NOT NULL,
		[cal_text] [varchar](4000) NOT NULL,
		[cal_colourIndex] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course](
		[crs_ID] [int] NOT NULL,
		[crs_vnu_ID] [int] NULL,
		[crs_ct_id] [int] NULL,
		[crs_lng_id] [int] NULL,
		[crs_mod_id] [int] NULL,
		[crs_org_id] [int] NULL,
		[crs_old_trn_id] [int] NULL,
		[crs_old_rat_id] [int] NULL,
		[crs_old_fvt_id] [int] NULL,
		[crs_refNo] [varchar](50) NULL,
		[crs_venueIsInvoice] [bit] NOT NULL,
		[crs_rgn_id] [int] NULL,
		[crs_isTwoDay] [bit] NOT NULL,
		[crs_date_Course] [datetime] NULL,
		[crs_date_Course2] [datetime] NULL,
		[crs_time_Start] [varchar](5) NULL,
		[crs_time_End] [varchar](5) NULL,
		[crs_time_Start2] [varchar](5) NULL,
		[crs_time_End2] [varchar](5) NULL,
		[crs_status] [int] NULL,
		[crs_notes] [varchar](8000) NULL,
		[crs_notes_register] [varchar](8000) NULL,
		[crs_notes_instructor] [varchar](8000) NULL,
		[crs_places] [int] NULL,
		[crs_placesReservedOffline] [int] NOT NULL,
		[crs_old_fleet_dr_id] [int] NULL,
		[crs_old_fleet_cost] [money] NULL,
		[crs_old_fleet_additionalExpense] [money] NULL,
		[crs_old_fleet_attendees] [varchar](8000) NULL,
		[crs_old_fleet_attendeeCount] [int] NULL,
		[crs_old_fleet_specialRqts] [varchar](8000) NULL,
		[crs_old_fleet_lunchProvided] [bit] NOT NULL,
		[crs_old_fleet_dateBooked] [datetime] NULL,
		[crs_old_fleet_orderNumber1] [varchar](50) NULL,
		[crs_old_fleet_orderNumber2] [varchar](50) NULL,
		[crs_old_fleet_JobSheetRaised] [bit] NOT NULL,
		[crs_old_fleet_TrainingNoticeOutput] [bit] NOT NULL,
		[crs_old_fleet_wasAttended] [bit] NOT NULL,
		[crs_old_fleet_venueContact] [varchar](50) NULL,
		[crs_old_fleet_venueTelephone] [varchar](50) NULL,
		[crs_old_fleet_clientNotes] [varchar](8000) NULL,
		[crs_old_fleet_MiscData] [varchar](200) NULL,
		[crs_old_fleet_CertificateOutput] [bit] NOT NULL,
		[crs_old_fleet_certificate_fl_id] [int] NULL,
		[crs_old_fleet_noticeSent] [datetime] NULL,
		[crs_attendanceSet] [bit] NOT NULL,
		[crs_attendanceSetByInstructor] [bit] NOT NULL,
		[crs_manualDriversOnly] [bit] NOT NULL,
		[crs_venueEmailDate] [datetime] NULL,
		[crs_d4c_meetingPoints] [varchar](200) NULL,
		[crs_placesAuto] [int] NULL,
		[crs_placesAutoReserved] [int] NULL,
		[crs_released] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_DeletedReferences](
		[cdr_id] [int] NOT NULL,
		[cdr_refNo] [varchar](50) NOT NULL,
		[cdr_ct_id] [int] NOT NULL,
		[cdr_rgn_id] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_Documents](
		[cd_id] [int] NOT NULL,
		[cd_original_cd_id] [int] NULL,
		[cd_crs_id] [int] NOT NULL,
		[cd_usr_id] [int] NOT NULL,
		[cd_originalFilename] [varchar](150) NOT NULL,
		[cd_documentName] [varchar](150) NOT NULL,
		[cd_uploadDate] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_DorsData](
		[cd_id] [int] NOT NULL,
		[cd_crs_id] [int] NOT NULL,
		[cd_lg_id] [int] NULL,
		[cd_CourseID] [varchar](50) NOT NULL,
		[cd_dors_startDate] [datetime] NULL,
		[cd_dors_startTime] [varchar](5) NULL,
		[cd_dors_spaces] [int] NULL,
		[cd_dors_SiteID] [varchar](50) NULL,
		[cd_dors_courseTitle] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_Fleet](
		[fc_id] [int] NOT NULL,
		[fc_dr_id] [int] NULL,
		[fc_crs_id] [int] NULL,
		[fc_fvt_id] [int] NULL,
		[fc_trn_id] [int] NULL,
		[fc_rat_id] [int] NULL,
		[fc_venueIsInvoice] [bit] NOT NULL,
		[fc_venueIsDepartment] [bit] NOT NULL,
		[fc_cost] [money] NULL,
		[fc_additionalExpense] [money] NULL,
		[fc_attendees] [varchar](8000) NULL,
		[fc_attendeeCount] [int] NULL,
		[fc_specialRqts] [varchar](8000) NULL,
		[fc_isLunchProvided] [bit] NOT NULL,
		[fc_orderNumber1] [varchar](50) NULL,
		[fc_orderNumber2] [varchar](50) NULL,
		[fc_venueContact] [varchar](50) NULL,
		[fc_venueTelephone] [varchar](50) NULL,
		[fc_clientNotes] [varchar](8000) NULL,
		[fc_miscData] [varchar](200) NULL,
		[fc_JobSheetRaised] [bit] NOT NULL,
		[fc_wasAttended] [bit] NOT NULL,
		[fc_TrainingNoticeOutput] [bit] NOT NULL,
		[fc_certificateOutput] [bit] NOT NULL,
		[fc_certificate_fl_id] [int] NULL,
		[fc_date_booked] [datetime] NULL,
		[fc_date_noticeSent] [datetime] NULL,
		[fc_date_invoice] [datetime] NULL,
		[fc_invoiceNumber] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_History](
		[ch_id] [int] NOT NULL,
		[ch_crs_id] [int] NOT NULL,
		[ch_usr_id] [int] NOT NULL,
		[ch_HistoryItem] [varchar](50) NULL,
		[ch_ChangedFrom] [varchar](8000) NULL,
		[ch_ChangedTo] [varchar](8000) NULL,
		[ch_wasChange] [bit] NOT NULL,
		[ch_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_InstructorRole](
		[cir_ID] [int] NOT NULL,
		[cir_crs_ID] [int] NOT NULL,
		[cir_ir_id] [int] NULL,
		[cir_Reference] [varchar](50) NULL,
		[cir_Payment] [money] NULL,
		[cir_Day1_Ses1] [bit] NOT NULL,
		[cir_Day1_Ses2] [bit] NOT NULL,
		[cir_Day1_Ses3] [bit] NOT NULL,
		[cir_Day2_Ses1] [bit] NOT NULL,
		[cir_Day2_Ses2] [bit] NOT NULL,
		[cir_Day2_Ses3] [bit] NOT NULL,
		[cir_isClassroom] [bit] NOT NULL,
		[cir_updateAttendance] [bit] NOT NULL,
		[cir_confirmAttendance] [bit] NOT NULL,
		[cir_dateNotifySent] [datetime] NULL,
		[cir_dateTrainingNoticeSent] [datetime] NULL,
		[cir_note] [varchar](2000) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_LetterFields](
		[clf_id] [int] NOT NULL,
		[clf_crs_id] [int] NOT NULL,
		[clf_tag] [varchar](50) NOT NULL,
		[clf_value] [varchar](200) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Course_Resource](
		[crsr_id] [int] NOT NULL,
		[crsr_fullName] [varchar](100) NOT NULL,
		[crsr_crsrt_id] [int] NOT NULL,
		[crsr_crs_id] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CourseInstructorLetters](
		[cil_id] [int] NOT NULL,
		[cil_ins_id] [int] NOT NULL,
		[cil_crs_id] [int] NOT NULL,
		[cil_usr_id] [int] NOT NULL,
		[cil_datesent] [datetime] NULL,
		[cil_name] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CourseInstructorNotes](
		[cin_id] [int] NOT NULL,
		[cin_crs_id] [int] NOT NULL,
		[cin_cir_id] [int] NOT NULL,
		[cin_usr_id] [int] NOT NULL,
		[cin_notes] [varchar](8000) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CourseRegisterFields](
		[crf_id] [int] NOT NULL,
		[crf_caption] [varchar](50) NULL,
		[crf_field] [varchar](50) NULL,
		[crf_format] [varchar](50) NULL,
		[crf_nullvalue] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CourseSignInFields](
		[csf_id] [int] NOT NULL,
		[csf_caption] [varchar](50) NULL,
		[csf_field] [varchar](50) NULL,
		[csf_format] [varchar](50) NULL,
		[csf_nullvalue] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CourseSignInFields_Custom](
		[ccsif_id] [int] NOT NULL,
		[ccsif_rct_id] [int] NOT NULL,
		[ccsif_caption] [varchar](50) NOT NULL,
		[ccsif_order] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_CustomUserFields](
		[cuf_id] [int] NOT NULL,
		[cuf_usr_id] [int] NOT NULL,
		[cuf_fieldNumber] [int] NOT NULL,
		[cuf_value] [varchar](100) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DeletedClients](
		[dc_id] [int] NOT NULL,
		[dc_dr_id] [int] NULL,
		[dc_title] [varchar](50) NULL,
		[dc_firstname] [varchar](50) NULL,
		[dc_lastname] [varchar](50) NULL,
		[dc_policeReference] [varchar](50) NULL,
		[dc_referrer_org_id] [int] NULL,
		[dc_usr_id] [int] NULL,
		[dc_date] [datetime] NULL,
		[dc_totalPaid] [money] NULL,
		[dc_referrer_rgn_id] [int] NULL,
		[dc_provider_rgn_id] [int] NULL,
		[dc_ct_id] [int] NULL,
		[dc_date_driverCreated] [datetime] NULL,
		[dc_date_driverCritical] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DirectoryStructure](
		[ds_id] [int] NOT NULL,
		[ds_Name] [varchar](50) NULL,
		[ds_Parent_ds_id] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_AttendanceStatuses](
		[as_id] [int] NOT NULL,
		[as_status] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_CreateDriverHistory](
		[dcdh_id] [int] NOT NULL,
		[dcdh_date] [datetime] NOT NULL,
		[dcdh_driverId] [int] NULL,
		[dcdh_licenceNo] [varchar](50) NULL,
		[dcdh_attendanceId] [int] NULL,
		[dcdh_schemeId] [int] NULL,
		[dcdh_forceId] [int] NULL,
		[dcdh_expiryDate] [datetime] NULL,
		[dcdh_referrerOrgId] [int] NULL,
		[dcdh_referrerRgnId] [int] NULL,
		[dcdh_courseTypeId] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_Forces](
		[for_id] [int] NOT NULL,
		[for_name] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_LicenceLookups](
		[dl_id] [int] NOT NULL,
		[dl_sessionId] [uniqueidentifier] NOT NULL,
		[dl_licenceNumber] [varchar](50) NOT NULL,
		[dl_dr_id] [int] NULL,
		[dl_dorsAttendanceID] [int] NULL,
		[dl_dorsAttendanceStatusId] [int] NULL,
		[dl_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_Log](
		[log_id] [int] NOT NULL,
		[log_lg_id] [int] NOT NULL,
		[log_description] [varchar](200) NOT NULL,
		[log_attendanceId] [int] NOT NULL,
		[log_attendanceStatusId] [int] NULL,
		[log_courseId] [int] NULL,
		[log_relevantdate] [datetime] NULL,
		[log_result] [bit] NULL,
		[log_errorText] [varchar](8000) NULL,
		[log_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_Logins](
		[lg_id] [int] NOT NULL,
		[lg_username] [varchar](50) NOT NULL,
		[lg_password] [varchar](50) NOT NULL,
		[lg_notificationAddress] [varchar](500) NOT NULL,
		[lg_owner_org_id] [int] NOT NULL,
		[lg_lastDateChanged] [datetime] NOT NULL,
		[lg_isGeneralPurposeLogin] [bit] NOT NULL,
		[lg_sendNotificationEmailOnExpiry] [bit] NOT NULL,
		[lg_disable_dors] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_Schemes](
		[sch_id] [int] NOT NULL,
		[sch_name] [varchar](50) NOT NULL,
		[sch_ct_id] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_UpdateFailures_Courses](
		[ufc_id] [int] NOT NULL,
		[ufc_crs_id] [int] NULL,
		[ufc_dors_courseId] [int] NULL,
		[ufc_action] [varchar](200) NOT NULL,
		[ufc_date] [datetime] NOT NULL,
		[ufc_date_first] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_DORS_UpdateFailures_Drivers](
		[ufd_id] [int] NOT NULL,
		[ufd_dr_id] [int] NOT NULL,
		[ufd_action] [varchar](200) NOT NULL,
		[ufd_date] [datetime] NOT NULL,
		[ufd_date_first] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver](
		[dr_ID] [int] NOT NULL,
		[dr_title] [varchar](50) NULL,
		[dr_firstname] [varchar](50) NULL,
		[dr_lastname] [varchar](50) NULL,
		[dr_postcode] [varchar](50) NULL,
		[dr_vt_ID] [int] NULL,
		[dr_addedBy_usr_id] [int] NULL,
		[dr_date_recordCreated] [datetime] NOT NULL,
		[dr_date_invited] [datetime] NULL,
		[dr_date_firstOfferLetter] [datetime] NULL,
		[dr_date_latestBooking] [datetime] NULL,
		[dr_date_critical] [datetime] NULL,
		[dr_date_Completed] [datetime] NULL,
		[dr_policeRefNo] [varchar](50) NULL,
		[dr_allowAttendance] [tinyint] NOT NULL,
		[dr_referrer_org_ID] [int] NULL,
		[dr_crs_ID] [int] NULL,
		[dr_isAcceptanceConfirmed] [bit] NOT NULL,
		[dr_opt_noCourseBooked] [bit] NOT NULL,
		[dr_opt_externalCourseBooked] [bit] NOT NULL,
		[dr_opt_externalCourseCompleted] [bit] NOT NULL,
		[dr_opt_courseRejected] [bit] NOT NULL,
		[dr_opt_courseRejectedOnline] [bit] NOT NULL,
		[dr_opt_pending] [bit] NOT NULL,
		[dr_external_org_id] [int] NULL,
		[dr_rr_id] [int] NULL,
		[dr_date_pending] [datetime] NULL,
		[dr_didAttend] [bit] NOT NULL,
		[dr_hasPaid] [bit] NOT NULL,
		[dr_payCashOnDay] [bit] NOT NULL,
		[dr_lct_ID] [int] NULL,
		[dr_licenceNo] [varchar](40) NULL,
		[dr_referrer_rgn_ID] [int] NULL,
		[dr_provider_rgn_id] [int] NULL,
		[dr_ct_id] [int] NULL,
		[dr_homepageStatus] [bigint] NOT NULL,
		[dr_hasBeenTransferred] [bit] NOT NULL,
		[dr_confirmedByEmail] [bit] NOT NULL,
		[dr_isAnonymous] [bit] NOT NULL,
		[dr_specialRqt_Actioned] [bit] NOT NULL,
		[dr_locked] [bit] NOT NULL,
		[dr_useDors] [bit] NOT NULL,
		[dr_anonymised] [bit] NOT NULL,
		[dr_addedSelf] [bit] NOT NULL,
		[dr_lastDorsCheck] [datetime] NULL,
		[dr_DisableDorsCheck] [bit] NOT NULL,
		[dr_accessLockedUser] [int] NULL,
		[dr_accessLockedFrom] [datetime] NULL,
		[dr_accessLockRevoked] [bit] NOT NULL,
		[dr_accessLockRevokedUser] [int] NULL,
		[dr_ghost_ID] [int] NULL,
		[dr_oldLicenceNo] [varchar](40) NULL,
		[dr_wfl_id] [int] NULL,
		[dr_old_crs_id] [int] NULL,
		[dr_date_courseChanged] [datetime] NULL,
		[dr_smsOptOut] [bit] NOT NULL,
		[dr_callMeBack] [bit] NOT NULL,
		[dr_emailCourseReminder] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_driver_archive](
		[dr_ID] [int] NOT NULL,
		[dr_title] [varchar](50) NULL,
		[dr_firstname] [varchar](50) NULL,
		[dr_lastname] [varchar](50) NULL,
		[dr_postcode] [varchar](50) NULL,
		[dr_vt_ID] [int] NULL,
		[dr_addedBy_usr_id] [int] NULL,
		[dr_date_recordCreated] [datetime] NOT NULL,
		[dr_date_invited] [datetime] NULL,
		[dr_date_firstOfferLetter] [datetime] NULL,
		[dr_date_latestBooking] [datetime] NULL,
		[dr_date_critical] [datetime] NULL,
		[dr_date_Completed] [datetime] NULL,
		[dr_policeRefNo] [varchar](50) NULL,
		[dr_allowAttendance] [tinyint] NOT NULL,
		[dr_referrer_org_ID] [int] NULL,
		[dr_crs_ID] [int] NULL,
		[dr_isAcceptanceConfirmed] [bit] NOT NULL,
		[dr_opt_noCourseBooked] [bit] NOT NULL,
		[dr_opt_externalCourseBooked] [bit] NOT NULL,
		[dr_opt_externalCourseCompleted] [bit] NOT NULL,
		[dr_opt_courseRejected] [bit] NOT NULL,
		[dr_opt_courseRejectedOnline] [bit] NOT NULL,
		[dr_opt_pending] [bit] NOT NULL,
		[dr_external_org_id] [int] NULL,
		[dr_rr_id] [int] NULL,
		[dr_date_pending] [datetime] NULL,
		[dr_didAttend] [bit] NOT NULL,
		[dr_hasPaid] [bit] NOT NULL,
		[dr_payCashOnDay] [bit] NOT NULL,
		[dr_lct_ID] [int] NULL,
		[dr_licenceNo] [varchar](40) NULL,
		[dr_referrer_rgn_ID] [int] NULL,
		[dr_provider_rgn_id] [int] NULL,
		[dr_ct_id] [int] NULL,
		[dr_homepageStatus] [bigint] NOT NULL,
		[dr_hasBeenTransferred] [bit] NOT NULL,
		[dr_confirmedByEmail] [bit] NOT NULL,
		[dr_isAnonymous] [bit] NOT NULL,
		[dr_specialRqt_Actioned] [bit] NOT NULL,
		[dr_locked] [bit] NOT NULL,
		[dr_useDors] [bit] NOT NULL,
		[dr_anonymised] [bit] NOT NULL,
		[dr_addedSelf] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_Data](
		[drd_ID] [int] NOT NULL,
		[drd_dr_ID] [int] NOT NULL,
		[drd_address] [varchar](8000) NULL,
		[drd_telHome] [varchar](50) NULL,
		[drd_telWork] [varchar](50) NULL,
		[drd_telMobile] [varchar](50) NULL,
		[drd_telFax] [varchar](50) NULL,
		[drd_emailAddress] [varchar](64) NULL,
		[drd_online_contactNumber] [varchar](50) NULL,
		[drd_dvt_id] [int] NULL,
		[drd_vehicleMake] [varchar](50) NULL,
		[drd_vehicleModel] [varchar](50) NULL,
		[drd_notes] [varchar](8000) NULL,
		[drd_PrivateNotes] [varchar](8000) NULL,
		[drd_ReferrerNotes] [varchar](8000) NULL,
		[drd_notesOther] [varchar](250) NULL,
		[drd_notes_rejection] [varchar](8000) NULL,
		[drd_notes_general] [varchar](8000) NULL,
		[drd_notes_courseRegister] [varchar](8000) NULL,
		[drd_date_birth] [datetime] NULL,
		[drd_date_incident] [datetime] NULL,
		[drd_date_referral] [datetime] NULL,
		[drd_date_firstLoggedIn] [datetime] NULL,
		[drd_date_letterSent] [datetime] NULL,
		[drd_date_rejected] [datetime] NULL,
		[drd_date_externalCourse] [datetime] NULL,
		[drd_date_finalStatus] [datetime] NULL,
		[drd_incidentType] [char](1) NULL,
		[drd_location] [varchar](50) NULL,
		[drd_DVLAreference] [varchar](50) NULL,
		[drd_courseRef] [varchar](50) NULL,
		[drd_notes_pending] [varchar](8000) NULL,
		[drd_pending_usr_id] [int] NULL,
		[drd_opt_didnotRespond] [bit] NOT NULL,
		[drd_opt_licenceSurrendered] [bit] NOT NULL,
		[drd_opt_declineConditional] [bit] NOT NULL,
		[drd_opt_declineCourt] [bit] NOT NULL,
		[drd_opt_formNotReturned] [bit] NOT NULL,
		[drd_opt_otherOption] [bit] NOT NULL,
		[drd_adminCharge] [money] NOT NULL,
		[drd_amountPaid] [money] NOT NULL,
		[drd_paymentNotes] [varchar](8000) NULL,
		[drd_COD_ReceiptNo] [varchar](50) NULL,
		[drd_COD_Payment] [money] NOT NULL,
		[drd_isLicenceIntl] [bit] NOT NULL,
		[drd_licenceValidFrom] [varchar](12) NULL,
		[drd_licenceValidTo] [varchar](12) NULL,
		[drd_licenceGroups] [varchar](12) NULL,
		[drd_datePassedTest] [varchar](12) NULL,
		[drd_useOwnVehicle] [bit] NOT NULL,
		[drd_specialRequirements] [varchar](8000) NULL,
		[drd_hasDifficultyReadingWriting] [bit] NOT NULL,
		[drd_isDeaf] [bit] NOT NULL,
		[drd_OtherProblems] [varchar](8000) NULL,
		[drd_adminListStatus] [int] NOT NULL,
		[drd_zn_ID] [int] NULL,
		[drd_Speed] [varchar](3) NULL,
		[drd_mod_id] [int] NULL,
		[drd_fleet_logo_fl_id] [int] NULL,
		[drd_miscData] [varchar](8000) NULL,
		[drd_rejectionEmailSent] [bit] NOT NULL,
		[drd_cjsCode] [varchar](50) NULL,
		[drd_safetyAwarenessType] [char](1) NULL,
		[drd_fleet_cli_id] [int] NULL,
		[drd_fleet_department] [varchar](50) NULL,
		[drd_fleet_useCompanyAddress] [bit] NOT NULL,
		[drd_fleet_telFax] [varchar](50) NULL,
		[drd_gd_keystone] [bit] NULL,
		[drd_gd_highwayCode] [int] NULL,
		[drd_gd_cognitive] [varchar](50) NULL,
		[drd_gd_brakeReaction] [varchar](50) NULL,
		[drd_gd_drivingAssessment] [int] NULL,
		[drd_criticalDate_notificationSent] [bit] NOT NULL,
		[drd_yds_cs_id] [int] NULL,
		[drd_yds_vot_id] [int] NULL,
		[drd_yds_voucherNumber] [varchar](50) NULL,
		[drd_it_id] [int] NULL,
		[drd_d4c_contraryTo] [varchar](50) NULL,
		[drd_netcallpayment_enabled] [bit] NOT NULL,
		[drd_netcallpayment_amount] [varchar](50) NULL,
		[drd_wfl_id] [int] NULL,
		[drd_agreedToTerms] [bit] NOT NULL,
		[drd_wheelchairUser] [bit] NOT NULL,
		[drd_accompaniedByTranslator] [bit] NOT NULL,
		[drd_accompaniedByCarer] [bit] NOT NULL,
		[drd_netcallLetterByEmail] [bit] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_Documents](
		[drdoc_id] [int] NOT NULL,
		[drdoc_original_drdoc_id] [int] NULL,
		[drdoc_dr_id] [int] NOT NULL,
		[drdoc_usr_id] [int] NOT NULL,
		[drdoc_originalFilename] [varchar](150) NOT NULL,
		[drdoc_documentName] [varchar](150) NOT NULL,
		[drdoc_uploadDate] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_DuplicateData](
		[dup_dr_id] [int] NOT NULL,
		[dup_data_1] [varchar](200) NOT NULL,
		[dup_data_2] [varchar](200) NULL,
		[dup_isDors] [bit] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_History](
		[dh_id] [int] NOT NULL,
		[dh_dr_id] [int] NOT NULL,
		[dh_usr_id] [int] NULL,
		[dh_wasWebService] [bit] NOT NULL,
		[dh_wasAutomatedProcess] [bit] NOT NULL,
		[dh_HistoryItem] [varchar](50) NULL,
		[dh_ChangedFrom] [varchar](250) NULL,
		[dh_ChangedTo] [varchar](250) NULL,
		[dh_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_Letters](
		[dl_id] [int] NOT NULL,
		[dl_dr_ID] [int] NOT NULL,
		[dl_usr_id] [int] NULL,
		[dl_datesent] [datetime] NOT NULL,
		[dl_name] [varchar](50) NULL,
		[dl_isWordFile] [bit] NOT NULL,
		[dl_sentByEmail] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_Notes](
		[dn_id] [int] NOT NULL,
		[dn_dr_id] [int] NOT NULL,
		[dn_note] [varchar](8000) NOT NULL,
		[dn_usr_id] [int] NULL,
		[dn_org_id] [int] NULL,
		[dn_date] [datetime] NOT NULL,
		[dn_wasReferrer] [bit] NOT NULL,
		[dn_wasProvider] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Driver_ThirdParties](
		[tp_id] [int] NOT NULL,
		[tp_dr_id] [int] NOT NULL,
		[tp_name] [varchar](50) NOT NULL,
		[tp_address] [varchar](2000) NOT NULL,
		[tp_telephone] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_External_Duplicates](
		[dup_id] [int] NOT NULL,
		[dup_forename] [varchar](100) NULL,
		[dup_surname] [varchar](100) NULL,
		[dup_policeRefNo] [varchar](100) NULL,
		[dup_postcode] [varchar](100) NULL,
		[dup_originalRecord] [varchar](1000) NULL,
		[dup_ct_id] [int] NULL,
		[dup_matched_dr_id] [int] NULL,
		[dup_import_usr_id] [int] NULL,
		[dup_import_datetime] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_External_Serco](
		[ser_id] [int] NOT NULL,
		[ser_dr_id] [int] NOT NULL,
		[ser_ErosID] [varchar](50) NOT NULL,
		[ser_date_added] [datetime] NOT NULL,
		[ser_date_clientResponse] [datetime] NULL,
		[ser_date_providerResponse] [datetime] NULL,
		[ser_clientResponseSuccess] [bit] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_External_StarTraq](
		[st_id] [int] NOT NULL,
		[st_dr_id] [int] NOT NULL,
		[st_StarTraqID] [varchar](50) NOT NULL,
		[st_DateAdded] [datetime] NOT NULL,
		[st_date_Invited] [datetime] NULL,
		[st_date_Booked] [datetime] NULL,
		[st_date_Completed] [datetime] NULL,
		[st_date_Revert] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_External_VPFPO](
		[vp_id] [int] NOT NULL,
		[vp_dr_id] [int] NOT NULL,
		[vp_NorthgateID] [varchar](100) NOT NULL,
		[vp_DateAdded] [datetime] NOT NULL,
		[vp_date_impsarep] [datetime] NULL,
		[vp_date_xmlresponse] [datetime] NULL,
		[vp_date_xmlfinal] [datetime] NULL,
		[vp_status_impsarep] [varchar](50) NULL,
		[vp_hasSpecialRequirements] [bit] NOT NULL,
		[vp_dors_scheme] [varchar](50) NULL,
		[vp_timeIntoRed] [varchar](50) NULL,
		[vp_processType] [varchar](50) NULL,
		[vp_reactivate] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Files](
		[fl_id] [int] NOT NULL,
		[fl_name] [varchar](50) NULL,
		[fl_size] [int] NULL,
		[fl_dateUpload] [datetime] NULL,
		[fl_usr_id] [int] NULL,
		[fl_ds_id] [int] NULL,
		[fl_supercedes_fl_id] [int] NULL,
		[fl_original_fl_id] [int] NULL,
		[fl_locked_usr_id] [int] NULL,
		[fl_dateLocked] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Fora](
		[frm_id] [int] NOT NULL,
		[frm_usr_id] [int] NULL,
		[frm_name] [varchar](50) NULL,
		[frm_CreationDate] [datetime] NULL,
		[frm_ViewCount] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Groups](
		[grp_id] [int] NOT NULL,
		[grp_Name] [varchar](50) NULL,
		[grp_ViewCount] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Instructor](
		[ins_ID] [int] NOT NULL,
		[ins_org_id] [int] NULL,
		[ins_iln_id] [int] NULL,
		[ins_name] [varchar](50) NOT NULL,
		[ins_address] [varchar](8000) NULL,
		[ins_postcode] [varchar](50) NULL,
		[ins_tel_Home] [varchar](50) NULL,
		[ins_tel_Mobile] [varchar](50) NULL,
		[ins_isClassroom] [bit] NOT NULL,
		[ins_isPractical] [bit] NOT NULL,
		[ins_rgn_id] [int] NOT NULL,
		[ins_emailAddress] [varchar](100) NULL,
		[ins_date_Birth] [datetime] NULL,
		[ins_date_Insurance] [datetime] NULL,
		[ins_date_lastCheck] [datetime] NULL,
		[ins_date_adiFleetRenewal] [datetime] NULL,
		[ins_adi_grade] [varchar](1) NULL,
		[ins_adi_number] [varchar](50) NULL,
		[ins_fleet_number] [varchar](50) NULL,
		[ins_carDetails] [varchar](200) NULL,
		[ins_notes] [varchar](1000) NULL,
		[ins_maxBookingsPerMonth] [int] NULL,
		[ins_useCalendar] [bit] NOT NULL,
		[ins_licence_number] [varchar](50) NULL,
		[ins_licence_checkDue] [datetime] NULL,
		[ins_teachQual_details] [varchar](200) NULL,
		[ins_teachQual_date] [datetime] NULL,
		[ins_isCurrent] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Instructor_Documents](
		[ind_id] [int] NOT NULL,
		[ind_original_ind_id] [int] NULL,
		[ind_ins_id] [int] NOT NULL,
		[ind_usr_id] [int] NOT NULL,
		[ind_originalFilename] [varchar](150) NOT NULL,
		[ind_documentName] [varchar](150) NOT NULL,
		[ind_uploadDate] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Instructor_LicenceNumbers](
		[iln_id] [int] NOT NULL,
		[iln_licenceNo] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Instructor_MonitoringDates](
		[imd_id] [int] NOT NULL,
		[imd_ins_id] [int] NOT NULL,
		[imd_isPractical] [bit] NOT NULL,
		[imd_isExternal] [bit] NOT NULL,
		[imd_number] [int] NOT NULL,
		[imd_date] [datetime] NULL,
		[imd_value] [varchar](1) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LetterFields](
		[lf_id] [int] NOT NULL,
		[lf_rct_id] [int] NOT NULL,
		[lf_tag] [varchar](50) NOT NULL,
		[lf_description] [varchar](200) NOT NULL,
		[lf_isDate] [bit] NOT NULL,
		[lf_order] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Area](
		[area_id] [int] NOT NULL,
		[area_name] [varchar](50) NULL,
		[area_CourseFee] [money] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Area_Languages](
		[al_id] [int] NOT NULL,
		[al_area_id] [int] NOT NULL,
		[al_lng_id] [int] NOT NULL,
		[al_name] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_ChargeType](
		[chgt_ID] [int] NOT NULL,
		[chgt_Description] [varchar](50) NOT NULL,
		[chgt_LongDescription] [varchar](200) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_CjsCodes](
		[cjs_id] [int] NOT NULL,
		[cjs_code] [varchar](50) NOT NULL,
		[cjs_description] [varchar](250) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_ContactSources](
		[cs_id] [int] NOT NULL,
		[cs_rgn_id] [int] NOT NULL,
		[cs_value] [varchar](200) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Course_ResourceType](
		[crsrt_id] [int] NOT NULL,
		[crsrt_shortDescription] [varchar](10) NOT NULL,
		[crsrt_longDescription] [varchar](50) NOT NULL,
		[crsrt_rgn_id] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_CourseType](
		[ct_ID] [int] NOT NULL,
		[ct_Description] [varchar](50) NULL,
		[ct_LongDescription] [varchar](200) NULL,
		[ct_default_mod_id] [int] NULL,
		[ct_TakeCourseOnExpiryDate] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_CourseType_Languages](
		[ctl_id] [int] NOT NULL,
		[ctl_ct_id] [int] NOT NULL,
		[ctl_lng_id] [int] NOT NULL,
		[ctl_ClientSideName] [varchar](200) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_CourseType_RegionalNames](
		[ctr_id] [int] NOT NULL,
		[ctr_ct_id] [int] NOT NULL,
		[ctr_rgn_id] [int] NOT NULL,
		[ctr_longdescription] [varchar](100) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_DriverVehicleType](
		[dvt_id] [int] NOT NULL,
		[dvt_Description] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_FleetClients](
		[cli_id] [int] NOT NULL,
		[cli_rgn_id] [int] NOT NULL,
		[cli_name] [varchar](50) NOT NULL,
		[cli_logo_fl_id] [int] NULL,
		[cli_invoiceAddress] [varchar](8000) NULL,
		[cli_contact] [varchar](100) NULL,
		[cli_telephone] [varchar](50) NULL,
		[cli_fax] [varchar](50) NULL,
		[cli_deleted] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_FleetVehicleType](
		[fvt_id] [int] NOT NULL,
		[fvt_typeName] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_IncidentTypes](
		[it_id] [int] NOT NULL,
		[it_rgn_id] [int] NOT NULL,
		[it_ct_id] [int] NOT NULL,
		[it_description] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Languages](
		[lng_id] [int] NOT NULL,
		[lng_name] [varchar](50) NOT NULL,
		[lng_culture] [varchar](50) NULL,
		[lng_default] [bit] NOT NULL,
		[lng_system] [bit] NOT NULL,
		[lng_deleted] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_LicenceType](
		[lct_ID] [int] NOT NULL,
		[lct_TypeName] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_LicenceType_Languages](
		[ltl_id] [int] NOT NULL,
		[ltl_lct_id] [int] NOT NULL,
		[ltl_lng_id] [int] NOT NULL,
		[ltl_typeName] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Module](
		[mod_id] [int] NOT NULL,
		[mod_description] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Organisation](
		[org_id] [int] NOT NULL,
		[org_name] [varchar](50) NULL,
		[org_inactivityLockout] [int] NOT NULL,
		[org_forceId] [varchar](50) NULL,
		[org_passwordWarning] [int] NULL,
		[org_passwordExpiry] [int] NULL,
		[org_dors_for_id] [int] NULL,
		[org_old_contactSalutation] [varchar](50) NULL,
		[org_old_contactName] [varchar](50) NULL,
		[org_old_address] [varchar](200) NULL,
		[org_old_postcode] [varchar](50) NULL,
		[org_old_telephone] [varchar](50) NULL,
		[org_old_fax] [varchar](50) NULL,
		[org_old_emailAddress] [varchar](200) NULL,
		[org_old_onlineRejectionEmailAddress] [varchar](200) NULL,
		[org_old_isReferrer] [bit] NOT NULL,
		[org_old_isServiceProvider] [bit] NOT NULL,
		[org_active] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Organisation_Languages](
		[ol_id] [int] NOT NULL,
		[ol_org_id] [int] NOT NULL,
		[ol_lng_id] [int] NOT NULL,
		[ol_name] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_PaymentMethod](
		[pmm_id] [int] NOT NULL,
		[pmm_description] [varchar](50) NULL,
		[pmm_code] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_PaymentProvider](
		[pp_id] [int] NOT NULL,
		[pp_name] [varchar](50) NULL,
		[pp_shortCode] [varchar](30) NULL,
		[pp_providerCode] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Region](
		[rgn_id] [int] NOT NULL,
		[rgn_area_id] [int] NULL,
		[rgn_description] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Region_Languages](
		[rl_id] [int] NOT NULL,
		[rl_rgn_id] [int] NOT NULL,
		[rl_lng_id] [int] NOT NULL,
		[rl_description] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_RejectionReasons](
		[rr_id] [int] NOT NULL,
		[rr_Description] [varchar](50) NOT NULL,
		[rr_ForProvider] [bit] NOT NULL,
		[rr_ForReferrer] [bit] NOT NULL,
		[rr_AllowManualSetting] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Role](
		[rol_id] [int] NOT NULL,
		[rol_original_rol_id] [int] NULL,
		[rol_rgn_id] [int] NULL,
		[rol_description] [varchar](50) NULL,
		[rol_abbrev] [varchar](4) NOT NULL,
		[rol_fee_group1] [money] NULL,
		[rol_fee_group2] [money] NULL,
		[rol_isTheory] [bit] NOT NULL,
		[rol_isPractical] [bit] NOT NULL,
		[rol_isAutomatic] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Systems](
		[sys_id] [int] NOT NULL,
		[sys_name] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_TrainingType](
		[trn_id] [int] NOT NULL,
		[trn_typeName] [varchar](50) NULL,
		[trn_shortCode] [varchar](5) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_VehicleType](
		[vt_id] [int] NOT NULL,
		[vt_shortDescription] [varchar](50) NULL,
		[vt_Description] [varchar](50) NULL,
		[vt_abbreviation] [varchar](5) NULL,
		[vt_abbreviationOrder] [int] NULL,
		[vt_requiresAutomaticInstructor] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_VehicleType_Languages](
		[vtl_id] [int] NOT NULL,
		[vtl_vt_id] [int] NOT NULL,
		[vtl_lng_id] [int] NOT NULL,
		[vtl_description] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Venue](
		[vnu_ID] [int] NOT NULL,
		[vnu_description] [varchar](64) NOT NULL,
		[vnu_address] [varchar](500) NULL,
		[vnu_postcode] [varchar](10) NULL,
		[vnu_prefix] [varchar](50) NULL,
		[vnu_rgn_ID] [int] NULL,
		[vnu_map_fl_id] [int] NULL,
		[vnu_mapInsertion_fl_id] [int] NULL,
		[vnu_emailAddress] [varchar](50) NULL,
		[vnu_cost_weekday] [money] NULL,
		[vnu_cost_weekend] [money] NULL,
		[vnu_dors_id] [int] NULL,
		[vnu_directions] [varchar](8000) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Venue_Languages](
		[vl_id] [int] NOT NULL,
		[vl_vnu_id] [int] NOT NULL,
		[vl_lng_id] [int] NOT NULL,
		[vl_description] [varchar](100) NOT NULL,
		[vl_address] [varchar](500) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_VoucherTypes](
		[vot_id] [int] NOT NULL,
		[vot_rgn_id] [int] NOT NULL,
		[vot_value] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_LU_Zone](
		[zn_ID] [int] NOT NULL,
		[zn_Speed] [varchar](3) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Messages](
		[msg_id] [int] NOT NULL,
		[msg_usr_id] [int] NULL,
		[msg_tpc_id] [int] NULL,
		[msg_creationDate] [datetime] NULL,
		[msg_fullname] [varchar](50) NULL,
		[msg_EmailAddress] [varchar](50) NULL,
		[msg_CompanyName] [varchar](50) NULL,
		[msg_Content] [varchar](8000) NULL,
		[msg_Signature] [varchar](50) NULL,
		[msg_Rating] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Netcall_Request](
		[ncr_id] [int] NOT NULL,
		[ncr_date] [datetime] NOT NULL,
		[ncr_Method] [varchar](255) NULL,
		[ncr_in_SessionID] [varchar](255) NULL,
		[ncr_in_RequestID] [varchar](255) NULL,
		[ncr_in_RequestTime] [varchar](255) NULL,
		[ncr_in_CallingNumber] [varchar](255) NULL,
		[ncr_in_AppContext] [varchar](255) NULL,
		[ncr_in_ClientID] [varchar](255) NULL,
		[ncr_in_DOB] [varchar](255) NULL,
		[ncr_in_PaymentResult] [varchar](255) NULL,
		[ncr_in_AuthReference] [varchar](255) NULL,
		[ncr_out_ResponseDate] [datetime] NULL,
		[ncr_out_Result] [varchar](255) NULL,
		[ncr_out_ResultDescription] [varchar](255) NULL,
		[ncr_out_ClientID] [varchar](255) NULL,
		[ncr_out_AmountToPay] [int] NULL,
		[ncr_out_CourseDateTime] [datetime] NULL,
		[ncr_out_CourseVenue] [varchar](255) NULL,
		[ncr_out_ShopperReference] [varchar](255) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_NotePriorities](
		[ntp_id] [int] NOT NULL,
		[ntp_name] [varchar](50) NOT NULL,
		[ntp_colour] [varchar](50) NOT NULL,
		[ntp_order] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Notes](
		[nt_id] [int] NOT NULL,
		[nt_date] [datetime] NOT NULL,
		[nt_subject] [varchar](200) NOT NULL,
		[nt_note] [varchar](8000) NOT NULL,
		[nt_usr_id] [int] NOT NULL,
		[nt_ntp_id] [int] NOT NULL,
		[nt_isOrganisation] [bit] NOT NULL,
		[nt_to_usr_id] [int] NULL,
		[nt_validDate] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Organisation_CourseTypes](
		[orct_id] [int] NOT NULL,
		[orct_org_id] [int] NOT NULL,
		[orct_ct_id] [int] NOT NULL,
		[orct_old_isActive] [bit] NOT NULL,
		[orct_isExternalCourseProvider] [bit] NOT NULL,
		[orct_contactSalutation] [varchar](50) NULL,
		[orct_contactName] [varchar](50) NULL,
		[orct_address] [varchar](200) NULL,
		[orct_postcode] [varchar](50) NULL,
		[orct_telephone] [varchar](50) NULL,
		[orct_fax] [varchar](50) NULL,
		[orct_emailAddress] [varchar](200) NULL,
		[orct_onlineRejectionEmailAddress] [varchar](200) NULL,
		[orct_isReferrer] [bit] NOT NULL,
		[orct_isServiceProvider] [bit] NOT NULL,
		[orct_hiddenPods] [bigint] NOT NULL,
		[orct_surrogateReferrer_org_id] [int] NULL,
		[orct_ccOnNotifications] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Organisation_CourseTypes_Languages](
		[octl_id] [int] NOT NULL,
		[octl_orct_id] [int] NOT NULL,
		[octl_lng_id] [int] NOT NULL,
		[octl_address] [varchar](200) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_OrgOption_Groups](
		[ogr_id] [int] NOT NULL,
		[ogr_name] [varchar](50) NOT NULL,
		[ogr_order] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_OrgOptions](
		[opt_id] [int] NOT NULL,
		[opt_ogr_id] [int] NULL,
		[opt_name] [varchar](50) NULL,
		[opt_description] [varchar](200) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Payment](
		[pm_id] [int] NOT NULL,
		[pm_dr_id] [int] NULL,
		[pm_crs_id] [int] NULL,
		[pm_pmm_id] [int] NULL,
		[pm_amount] [money] NULL,
		[pm_date] [datetime] NULL,
		[pm_receiptNumber] [varchar](50) NULL,
		[pm_authCode] [varchar](50) NULL,
		[pm_usr_id] [int] NULL,
		[pm_isnetcall] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Payment_Archive](
		[pa_id] [int] NOT NULL,
		[pa_dr_id] [int] NOT NULL,
		[pa_title] [varchar](50) NULL,
		[pa_firstname] [varchar](50) NULL,
		[pa_lastname] [varchar](50) NULL,
		[pa_ct_id] [int] NULL,
		[pa_referrer_rgn_id] [int] NOT NULL,
		[pa_pmm_id] [int] NULL,
		[pa_amount] [money] NOT NULL,
		[pa_receiptNumber] [varchar](50) NOT NULL,
		[pa_date] [datetime] NOT NULL,
		[pa_date_archived] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Payment_Pending](
		[pp_ID] [int] NOT NULL,
		[pp_dr_ID] [int] NOT NULL,
		[pp_session_ID] [int] NOT NULL,
		[pp_request_ID] [varchar](50) NOT NULL,
		[pp_requestDate] [datetime] NOT NULL,
		[pp_amountToPay] [money] NOT NULL,
		[pp_created] [datetime] NOT NULL,
		[pp_updated] [datetime] NOT NULL,
		[pp_status] [tinyint] NOT NULL,
		[pp_agentpayment] [bit] NOT NULL,
		[pp_letterSent] [bit] NOT NULL,
		[pp_pm_id] [int] NOT NULL,
		[pp_letterByEmail] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Payment_Reconciliation](
		[pr_id] [int] NOT NULL,
		[pr_guid] [uniqueidentifier] NOT NULL,
		[pr_dr_id] [int] NULL,
		[pr_transRef] [varchar](200) NOT NULL,
		[pr_authCode] [varchar](200) NOT NULL,
		[pr_orderRef] [varchar](200) NOT NULL,
		[pr_orderInfo] [varchar](200) NOT NULL,
		[pr_date_payment] [datetime] NOT NULL,
		[pr_date_added] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_PrintQueue](
		[q_id] [int] NOT NULL,
		[q_org_id] [int] NOT NULL,
		[q_usr_id] [int] NULL,
		[q_headed] [bit] NOT NULL,
		[q_isWordFile] [bit] NOT NULL,
		[q_DocumentName] [varchar](150) NOT NULL,
		[q_DocumentSubject] [varchar](150) NOT NULL,
		[q_FleetFlag] [varchar](50) NULL,
		[q_dr_id] [int] NULL,
		[q_crs_id] [int] NULL,
		[q_ins_id] [int] NULL,
		[q_TemporaryFilename] [varchar](150) NOT NULL,
		[q_DateAdded] [datetime] NOT NULL,
		[q_isReprint] [bit] NOT NULL,
		[q_triggersInvitationDate] [bit] NOT NULL,
		[q_triggersFirstOfferDate] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_PrintQueue_Delayed](
		[qd_id] [int] NOT NULL,
		[qd_data] [varchar](500) NOT NULL,
		[qd_deleted] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_PrintQueueBAK](
		[q_id] [int] NOT NULL,
		[q_org_id] [int] NOT NULL,
		[q_usr_id] [int] NULL,
		[q_headed] [bit] NOT NULL,
		[q_DocumentName] [varchar](150) NOT NULL,
		[q_DocumentSubject] [varchar](150) NOT NULL,
		[q_FleetFlag] [varchar](50) NULL,
		[q_dr_id] [int] NULL,
		[q_crs_id] [int] NULL,
		[q_ins_id] [int] NULL,
		[q_TemporaryFilename] [varchar](150) NOT NULL,
		[q_DateAdded] [datetime] NOT NULL,
		[q_isReprint] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Queries](
		[qu_id] [int] NOT NULL,
		[qu_queryText] [varchar](8000) NULL,
		[qu_date] [datetime] NOT NULL,
		[qu_runTime] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Region_CourseType](
		[rct_id] [int] NOT NULL,
		[rct_rgn_id] [int] NOT NULL,
		[rct_ct_id] [int] NOT NULL,
		[rct_pp_id] [int] NULL,
		[rct_telephone_pp_id] [int] NULL,
		[rct_telephone_allowAmountAlteration] [bit] NOT NULL,
		[rct_default_mod_id] [int] NULL,
		[rct_default_vt_id] [int] NULL,
		[rct_courseFee] [money] NULL,
		[rct_bookingSupplement] [money] NULL,
		[rct_logo_fl_id] [int] NULL,
		[rct_terms_fl_id] [int] NULL,
		[rct_criticalDate_wtr_id] [int] NULL,
		[rct_finalBookingDate_wtr_id] [int] NULL,
		[rct_root_ds_id] [int] NULL,
		[rct_daysUntilAmber] [int] NULL,
		[rct_daysUntilRed] [int] NULL,
		[rct_daysUntilAmber_AfterInvitation] [int] NULL,
		[rct_daysUntilAmber_AfterFirstOffer] [int] NULL,
		[rct_daysUntilRed_AfterInvitation] [int] NULL,
		[rct_daysUntilRed_AfterFirstOffer] [int] NULL,
		[rct_paymentDays] [int] NULL,
		[rct_paymentDaysAfterOffer] [int] NULL,
		[rct_followup_daysAfterCompletion] [int] NOT NULL,
		[rct_deletion_daysPastExpiry] [int] NULL,
		[rct_deletion_daysPastCreation] [int] NULL,
		[rct_deletion_daysAfterCompletion] [int] NULL,
		[rct_anon_daysAfterCompletion] [int] NULL,
		[rct_anonymisation_daysPastCourseCompletion] [int] NULL,
		[rct_completion_fl_id] [int] NULL,
		[rct_instructorNotice_fl_id] [int] NULL,
		[rct_orderConfirmation_fl_id] [int] NULL,
		[rct_invoiceLetter_fl_id] [int] NULL,
		[rct_followup_fl_id] [int] NULL,
		[rct_certificates_ds_id] [int] NULL,
		[rct_certificateLogos_ds_id] [int] NULL,
		[rct_email_instructorsNotice] [varchar](8000) NULL,
		[rct_email_instructorsBooked] [varchar](8000) NULL,
		[rct_email_instructorsRemoved] [varchar](8000) NULL,
		[rct_email_ClientsNotice] [varchar](8000) NULL,
		[rct_email_ReferrersNoticeSubject] [varchar](100) NULL,
		[rct_email_ReferrersNotice] [varchar](8000) NULL,
		[rct_course_AllowToCritical] [bit] NOT NULL,
		[rct_course_DisallowAfterCritical] [bit] NOT NULL,
		[rct_email_InstructorFrom] [varchar](100) NULL,
		[rct_email_InstructorBcc] [varchar](100) NULL,
		[rct_email_DriverFrom] [varchar](100) NULL,
		[rct_email_DriverBcc] [varchar](100) NULL,
		[rct_email_DriverSubject] [varchar](200) NULL,
		[rct_email_DriverContent] [varchar](8000) NULL,
		[rct_email_VenueContent] [varchar](8000) NULL,
		[rct_email_ClientRejectionCc] [varchar](100) NULL,
		[rct_email_ClientRejectionContent] [varchar](8000) NULL,
		[rct_email_ClientCourseFrom] [varchar](100) NULL,
		[rct_email_ClientCourseBcc] [varchar](100) NULL,
		[rct_email_ClientCourseSubject] [varchar](200) NULL,
		[rct_email_ClientCourseContent] [varchar](8000) NULL,
		[rct_daysStayingYellow] [int] NOT NULL,
		[rct_defaultAttendStatus] [int] NOT NULL,
		[rct_disableIncomingTransfers] [bit] NOT NULL,
		[rct_requireOnlineLicenceNo] [bit] NOT NULL,
		[rct_requireAdminLicenceNo] [bit] NOT NULL,
		[rct_allowOnlineClientTransfer] [bit] NOT NULL,
		[rct_coursenotesfields] [varchar](8000) NULL,
		[rct_anon_daysAfterRejection] [int] NOT NULL,
		[rct_anon_yearsAfterReferral] [float] NOT NULL,
		[rct_dors_allow] [bit] NOT NULL,
		[rct_alertOnHomepageIfReferrerAdded] [bit] NOT NULL,
		[rct_allowBookingsWhenDORSUnavailable] [bit] NOT NULL,
		[rct_allowBookingsWhenDORSUnavailableUserId] [int] NULL,
		[rct_allowBookingsWhenDORSUnavailableDateSet] [datetime] NULL,
		[rct_courseRegisterFields] [varchar](2000) NULL,
		[rct_overduePaymentText] [varchar](100) NULL,
		[rct_sendAutoCourseUpdateEmail] [bit] NOT NULL,
		[rct_frontEnd_requireContactNumber] [bit] NOT NULL,
		[rct_frontEnd_requireEmailAddress] [bit] NOT NULL,
		[rct_frontEnd_requireEmailAddressConfirm] [bit] NOT NULL,
		[rct_register_showRegNumber] [bit] NOT NULL,
		[rct_instructors_updateAttendance] [bit] NOT NULL,
		[rct_useCustomSignIn] [bit] NOT NULL,
		[rct_register_showFreeText] [bit] NOT NULL,
		[rct_register_freeText] [varchar](8000) NOT NULL,
		[rct_smsCourseReminder] [bit] NOT NULL,
		[rct_smsCourseReminderDays] [tinyint] NOT NULL,
		[rct_smsCourseReminderFrom] [varchar](11) NULL,
		[rct_smsCourseReminderText] [varchar](8000) NULL,
		[rct_smsCourseConfirmation] [bit] NOT NULL,
		[rct_smsCourseConfirmationFrom] [varchar](11) NULL,
		[rct_smsCourseConfirmationText] [varchar](8000) NULL,
		[rct_lettersByEmail] [bit] NOT NULL,
		[rct_lettersByEmailFrom] [varchar](100) NULL,
		[rct_lettersByEmailBcc] [varchar](100) NULL,
		[rct_lettersByEmailSubject] [varchar](200) NULL,
		[rct_lettersByEmailBody] [varchar](8000) NULL,
		[rct_emailCourseReminder] [bit] NOT NULL,
		[rct_emailCourseReminderDays] [tinyint] NOT NULL,
		[rct_emailCourseReminderText] [varchar](8000) NULL,
		[rct_emailCourseReminderSubject] [varchar](200) NULL,
		[rct_emailCourseReminderFrom] [varchar](100) NULL,
		[rct_emailCourseReminderBcc] [varchar](100) NULL,
		[rct_confirmEmailAddress] [bit] NOT NULL,
		[rct_active] [bit] NOT NULL,
		[rct_allowRebookOnline] [bit] NOT NULL,
		[rct_courseRegisterPDF] [bit] NOT NULL,
		[rct_courseRegisterLandscape] [bit] NOT NULL,
		[rct_signInSheetLandscape] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_RegionCourseType_Languages](
		[rctl_id] [int] NOT NULL,
		[rctl_rct_id] [int] NOT NULL,
		[rctl_lng_id] [int] NOT NULL,
		[rctl_stage6text] [varchar](8000) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_RegionCourseType_Locking](
		[rctl_id] [int] NOT NULL,
		[rctl_rct_id] [int] NOT NULL,
		[rctl_atlasCourseAttended] [bit] NOT NULL,
		[rctl_atlasCourseFailed] [bit] NOT NULL,
		[rctl_nonAtlasCourseAttended] [bit] NOT NULL,
		[rctl_old_courseRejectedProvider] [bit] NOT NULL,
		[rctl_old_courseRejectedReferrer] [bit] NOT NULL,
		[rctl_courseRejected] [bit] NOT NULL,
		[rctl_courseRejectedOnline] [bit] NOT NULL,
		[rctl_inviteDateExpired] [bit] NOT NULL,
		[rctl_criticalDateExpired] [bit] NOT NULL,
		[rctl_leaveAtNoCourseBooked] [bit] NOT NULL,
		[rctl_noResponseText] [varchar](2000) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Report_Financials](
		[rf_id] [int] NOT NULL,
		[rf_dr_id] [int] NOT NULL,
		[rf_crs_id] [int] NOT NULL,
		[rf_crs_date] [datetime] NOT NULL,
		[rf_crs_reference] [varchar](50) NULL,
		[rf_provider_rgn_id] [int] NOT NULL,
		[rf_referrer_rgn_id] [int] NOT NULL,
		[rf_ct_id] [int] NOT NULL,
		[rf_startOfMonthDate] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_RetainLockHistory](
		[rl_id] [int] NOT NULL,
		[rl_clientIds] [varchar](8000) NULL,
		[rl_date] [datetime] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Security_FailedValidations](
		[fv_id] [int] NOT NULL,
		[fv_username] [varchar](200) NULL,
		[fv_password] [varchar](200) NULL,
		[fv_passwordHash] [varchar](200) NULL,
		[fv_reuseExistingSession] [bit] NULL,
		[fv_ipAddress] [varchar](50) NULL,
		[fv_hostname] [varchar](200) NULL,
		[fv_result] [int] NULL,
		[fv_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_SecurityItems](
		[si_id] [int] NOT NULL,
		[si_code] [varchar](50) NULL,
		[si_description] [varchar](100) NULL,
		[si_restrictive] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_SessionTransfers](
		[trans_guid] [uniqueidentifier] NOT NULL,
		[trans_sessionGuid] [uniqueidentifier] NOT NULL,
		[trans_destSystem] [varchar](50) NOT NULL,
		[trans_dateAdded] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_SMSMessage](
		[sms_id] [int] NOT NULL,
		[sms_dr_id] [int] NOT NULL,
		[sms_crs_id] [int] NOT NULL,
		[sms_date] [datetime] NOT NULL,
		[sms_smst_id] [tinyint] NOT NULL,
		[sms_message] [varchar](8000) NOT NULL,
		[sms_mobileTelNo] [varchar](20) NOT NULL,
		[sms_messageId] [uniqueidentifier] NOT NULL,
		[sms_status] [tinyint] NOT NULL,
		[sms_dh_id] [int] NOT NULL,
		[sms_charge] [money] NOT NULL,
		[sms_originator] [varchar](50) NOT NULL,
		[sms_parts] [tinyint] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_SMSMessageType](
		[smst_id] [tinyint] NOT NULL,
		[smst_description] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_SMSStatus](
		[sms_status] [int] NOT NULL,
		[sms_statusDescription] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_StoredProcedures](
		[sp_id] [int] NOT NULL,
		[sp_name] [varchar](50) NOT NULL,
		[sp_source] [int] NOT NULL,
		[sp_called] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Topics](
		[tpc_id] [int] NOT NULL,
		[tpc_usr_id] [int] NULL,
		[tpc_frm_id] [int] NULL,
		[tpc_name] [varchar](50) NULL,
		[tpc_CreationDate] [datetime] NULL,
		[tpc_ViewCount] [char](10) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_User_PasswordResetRequests](
		[prr_ID] [int] NOT NULL,
		[prr_usr_ID] [int] NOT NULL,
		[prr_requestCode] [varchar](50) NOT NULL,
		[prr_requestDate] [datetime] NOT NULL,
		[prr_attempts] [int] NOT NULL,
		[prr_complete] [bit] NOT NULL,
		[prr_unlock] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Users](
		[usr_ID] [int] NOT NULL,
		[usr_adm_id] [int] NULL,
		[usr_Username] [varchar](50) NULL,
		[usr_PasswordPlain] [varchar](50) NULL,
		[usr_PasswordHash] [varchar](50) NULL,
		[usr_Fullname] [varchar](50) NULL,
		[usr_lastLoginDate] [datetime] NULL,
		[usr_org_id] [int] NULL,
		[usr_root_ds_id] [int] NULL,
		[usr_lockOutCount] [int] NULL,
		[usr_lockOutTime] [datetime] NULL,
		[usr_printToQueue] [bit] NOT NULL,
		[usr_ins_id] [int] NULL,
		[usr_date_passwordChanged] [datetime] NOT NULL,
		[usr_deleted] [bit] NOT NULL,
		[usr_email] [varchar](100) NULL,
		[usr_password_reset_code] [varchar](50) NULL,
		[usr_password_reset_date] [datetime] NULL,
		[usr_agent_ext] [varchar](50) NULL,
		[usr_resetPassword] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Users_PreviousPasswords](
		[upp_id] [int] NOT NULL,
		[upp_usr_id] [int] NOT NULL,
		[upp_passwordHash] [varchar](50) NOT NULL,
		[upp_date] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WebServiceDownloads_Drivers](
		[wsdr_id] [int] NOT NULL,
		[wsdr_wsd_id] [int] NOT NULL,
		[wsdr_dr_id] [int] NOT NULL,
		[wsdr_additional] [varchar](50) NULL,
		[wsdr_additional_int] [int] NULL,
		[wsdr_additional_date] [datetime] NULL,
		[wsdr_bitmask] [int] NOT NULL,
		[wsdr_forExport] [bit] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WebServiceDownloadsArchive](
		[wsda_id] [int] NOT NULL,
		[wsda_usr_id] [int] NOT NULL,
		[wsda_filename] [varchar](100) NOT NULL,
		[wsda_fileIdentifier] [varchar](100) NOT NULL,
		[wsda_confirmed] [bit] NOT NULL,
		[wsda_dateDownloaded] [datetime] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WebServiceUsers](
		[web_id] [int] NOT NULL,
		[web_rct_id] [int] NOT NULL,
		[web_shared_main_rct_id] [int] NULL,
		[web_postcodeRegExp] [varchar](500) NULL,
		[web_type] [varchar](3) NOT NULL,
		[web_useFormscape] [bit] NOT NULL,
		[web_username] [varchar](50) NOT NULL,
		[web_password] [varchar](50) NOT NULL,
		[web_autoUploadDownload] [bit] NOT NULL,
		[web_autoEmailAddresses] [varchar](500) NULL,
		[web_autoEmailAddresses_Upload] [varchar](500) NULL,
		[web_autoEmailAddress_Download] [varchar](500) NULL,
		[web_autoConfirm] [bit] NOT NULL,
		[web_autoDownloadText] [varchar](2000) NULL,
		[web_setInviteOnUpload] [bit] NOT NULL,
		[web_wfl_id] [int] NULL,
		[web_forceId] [varchar](50) NULL,
		[web_dors_fc_id] [int] NULL,
		[web_dors_lg_id] [int] NULL,
		[web_dors_requireConfirmationForInvitePods] [bit] NOT NULL,
		[web_AcceptedPodValue] [int] NOT NULL,
		[web_DeclinedPodValue] [int] NOT NULL,
		[web_BookedPodValue] [int] NOT NULL,
		[web_RefusedPodValue] [int] NOT NULL,
		[web_CompletedPodValue] [int] NOT NULL,
		[web_NonCompletedPodValue] [int] NOT NULL,
		[web_suppressOfferResponse] [bit] NOT NULL,
		[web_SuppressDeclineResponse] [bit] NOT NULL,
		[web_pgp_usePgpEncryption] [bit] NOT NULL,
		[web_pgp_publicKey] [varchar](8000) NULL,
		[web_critical_overrideFile] [bit] NOT NULL,
		[web_critical_daysAfterUpload] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WebServiceUsers_Pods](
		[wsup_id] [int] NOT NULL,
		[wsup_web_id] [int] NOT NULL,
		[wsup_typeName] [varchar](50) NOT NULL,
		[wsup_podValue] [int] NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_Workflow_Type](
		[wft_id] [int] NOT NULL,
		[wft_code] [varchar](50) NOT NULL,
		[wft_displayName] [varchar](50) NOT NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WorkflowRule](
		[wfl_id] [int] NOT NULL,
		[wfl_wft_id] [int] NULL,
		[wfl_name] [varchar](50) NULL,
		[wfl_orc_id] [int] NOT NULL,
		[wfl_fl_id] [int] NULL,
		[wfl_wtr_id] [int] NULL,
		[wfl_csvFilename] [varchar](50) NULL,
		[wfl_csvDestinationPath] [varchar](250) NULL,
		[wfl_outsideProcess] [bit] NOT NULL,
		[wfl_setsInvite] [bit] NOT NULL,
		[wfl_removeFromAmberFinalOfferPod] [bit] NOT NULL,
		[wfl_removeFromAddedByReferrerPod] [bit] NOT NULL,
		[wfl_removeFromOverduePaymentPod] [bit] NOT NULL,
		[wfl_setsFirstOffer] [bit] NOT NULL,
		[wfl_attachMap] [bit] NOT NULL,
		[wfl_podallocation_id] [int] NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;
	/************/

	CREATE EXTERNAL TABLE [migration].[tbl_WorkflowTimeRule](
		[wtr_id] [int] NOT NULL,
		[wtr_numberOfDays] [int] NOT NULL,
		[wtr_isBefore] [bit] NOT NULL,
		[wtr_relativeTo] [varchar](50) NULL)
	 WITH ( DATA_SOURCE = IAM_Elastic_Old_Atlas ) ;


END
GO

DECLARE @ScriptName VARCHAR(100) = 'SP023_22.01_Update_uspCreateMigrationExternalTables.sql';
EXEC dbo.uspScriptCompleted @ScriptName; 
GO

