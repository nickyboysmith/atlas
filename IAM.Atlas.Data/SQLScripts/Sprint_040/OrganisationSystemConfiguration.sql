
--INSERT INTO [dbo].[OrganisationSystemConfiguration]
--           ([OrganisationId]
--           ,[MinimumAdministrators]
--           ,[Trainers]
--           ,[Drivers]
--           ,[DORSFeatureEnabled]
--           ,[ShowDORSStatus]
--           ,[AdhocReporting]
--           ,[ReportScheduling]
--           ,[InvoiceManagement]
--           ,[TrainerInvoice]
--           ,[ClientGrouping]
--           ,[DataReconciliation]
--           ,[CourseFeedback]
--           ,[MaximumIndividualFileSize]
--           ,[FileUploadAllowance]
--           ,[FileVersioning]
--           ,[HasSubDomain]
--           ,[SubDomainName]
--           ,[HasFullDomain]
--           ,[FullDomainName]
--           ,[UpdatedByUserId]
--           ,[DateUpdated]
--           ,[FromName]
--           ,[FromEmail]
--           ,[ArchiveSMSAfterDays]
--           ,[DeleteSMSAfterDays]
--           ,[ShowNetcallFeatures]
--           ,[HoursToEmailCourseVenuesAfterCreation]
--           ,[AllowManualEditingOfClientDORSData]
--           ,[YearsOfPaymentData]
--           ,[ShowPaymentCardSupplier]
--           ,[ShowTaskList]
--           ,[ShowCourseLanguage]
--           ,[AllowTaskCreation]
--           ,[DefaultRegionId])
--     SELECT
--             O.Id
--           , NS.MinimumAdministrators
--           , NS.Trainers
--           , NS.Drivers
--           , NS.DORSFeatureEnabled
--           , NS.ShowDORSStatus
--           , NS.AdhocReporting
--           , NS.ReportScheduling
--           , NS.InvoiceManagement
--           , NS.TrainerInvoice
--           , NS.ClientGrouping
--           , NS.DataReconciliation
--           , NS.CourseFeedback
--           , NS.MaximumIndividualFileSize
--           , NS.FileUploadAllowance
--           , NS.FileVersioning
--           , NS.HasSubDomain
--           , NS.SubDomainName
--           , NS.HasFullDomain
--           , NS.FullDomainName
--           , dbo.udfGetSystemUserId()
--           , GetDate()
--           , NS.FromName
--           , NS.FromEmail
--           , NS.ArchiveSMSAfterDays
--           , NS.DeleteSMSAfterDays
--           , NS.ShowNetcallFeatures
--           , NS.HoursToEmailCourseVenuesAfterCreation
--           , NS.AllowManualEditingOfClientDORSData
--           , NS.YearsOfPaymentData
--           , NS.ShowPaymentCardSupplier
--           , NS.ShowTaskList
--           , NS.ShowCourseLanguage
--           , NS.AllowTaskCreation
--           , NS.DefaultRegionId
--	FROM NickOrganisationSystemConfiguration NS
--	INNER JOIN NickOrganisation NON ON NS.OrganisationId = NON.Id 
--	INNER JOIN Organisation O ON NON.Name = O.Name
--	LEFT JOIN OrganisationSystemConfiguration OSC ON OSC.OrganisationId = O.Id
--	WHERE OSC.Id IS NULL


	UPDATE OSC
		SET OSC.MinimumAdministrators = NS.MinimumAdministrators
		, OSC.Trainers = NS.Trainers
		, OSC.Drivers = NS.Drivers
		, OSC.DORSFeatureEnabled = NS.DORSFeatureEnabled
		, OSC.ShowDORSStatus = NS.ShowDORSStatus
		, OSC.AdhocReporting = NS.AdhocReporting
		, OSC.ReportScheduling = NS.ReportScheduling
		, OSC.InvoiceManagement = NS.InvoiceManagement
		, OSC.TrainerInvoice = NS.TrainerInvoice
		, OSC.ClientGrouping = NS.ClientGrouping
		, OSC.DataReconciliation = NS.DataReconciliation
		, OSC.CourseFeedback = NS.CourseFeedback
		, OSC.MaximumIndividualFileSize = NS.MaximumIndividualFileSize
		, OSC.FileUploadAllowance = NS.FileUploadAllowance
		, OSC.FileVersioning = NS.FileVersioning
		, OSC.HasSubDomain = NS.HasSubDomain
		, OSC.SubDomainName = NS.SubDomainName
		, OSC.HasFullDomain = NS.HasFullDomain
		, OSC.FullDomainName = NS.FullDomainName
		, OSC.UpdatedByUserId = dbo.udfGetSystemUserId()
		, OSC.DateUpdated = GetDate()
		, OSC.FromName = NS.FromName
		, OSC.FromEmail = NS.FromEmail
		, OSC.ArchiveSMSAfterDays = NS.ArchiveSMSAfterDays
		, OSC.DeleteSMSAfterDays = NS.DeleteSMSAfterDays
		, OSC.ShowNetcallFeatures = NS.ShowNetcallFeatures
		, OSC.HoursToEmailCourseVenuesAfterCreation = NS.HoursToEmailCourseVenuesAfterCreation
		, OSC.AllowManualEditingOfClientDORSData = NS.AllowManualEditingOfClientDORSData
		, OSC.YearsOfPaymentData = NS.YearsOfPaymentData
		, OSC.ShowPaymentCardSupplier = NS.ShowPaymentCardSupplier
		, OSC.ShowTaskList = NS.ShowTaskList
		, OSC.ShowCourseLanguage = NS.ShowCourseLanguage
		, OSC.AllowTaskCreation = NS.AllowTaskCreation
	FROM NickOrganisationSystemConfiguration NS
	INNER JOIN NickOrganisation NON ON NS.OrganisationId = NON.Id 
	INNER JOIN Organisation O ON NON.Name = O.Name
	INNER JOIN OrganisationSystemConfiguration OSC ON OSC.OrganisationId = O.Id