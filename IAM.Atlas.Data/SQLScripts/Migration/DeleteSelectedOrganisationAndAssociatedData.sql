
IF OBJECT_ID('tempdb..#DeleteOrg', 'U') IS NOT NULL
BEGIN
	DROP TABLE #DeleteOrg;
END
		

SELECT O.Id AS OrganisationId, [Name] As OrganisationName
INTO #DeleteOrg
FROM Organisation O
WHERE 
O.[Name] LIKE '% School'
OR O.[Name] LIKE '% College'
OR O.[Name] LIKE '% Primary'
OR O.[Name] LIKE '% Jnr'
OR O.[Name] LIKE 'St.%'
OR O.[Name] LIKE 'Sp. %'
OR O.[Name] LIKE 'L. %'
OR O.[Name] LIKE 'S. %'
OR O.[Name] LIKE 'St %'
OR O.[Name] LIKE 'All Saint%'
OR O.[Name] LIKE 'Christ %'
OR O.[Name] LIKE ' Church%'
OR O.[Name] LIKE 'Little %'
OR O.[Name] LIKE 'Sacred %'
OR O.[Name] LIKE 'Manor%'
OR O.[Name] LIKE 'No Location%'
OR O.[Name] = 'Nutley'
OR O.[Name] = 'Shinewater'
OR O.[Name] = 'To Be Confirmed'
OR O.[Name] = 'Neither'
OR O.[Name] = 'Media'
OR O.[Name] = 'Five Ashes'
OR O.[Name] = 'Ditchling'
;

PRINT CAST(GETDATE() AS VARCHAR) + ': TrainerOrganisation'
DELETE TrainerOrganisation
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationSystemTaskMessaging'
DELETE OrganisationSystemTaskMessaging
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationSelfConfiguration'
DELETE OrganisationSelfConfiguration
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationSystemConfiguration'
DELETE OrganisationSystemConfiguration
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationLanguage'
DELETE OrganisationLanguage
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationSMSTemplateMessage'
DELETE OrganisationSMSTemplateMessage
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationEmailTemplateMessage'
DELETE OrganisationEmailTemplateMessage
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseTypeCategory'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN CourseTypeCategory TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseTypeTolerance'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN CourseTypeTolerance TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseTypeFee'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN CourseTypeFee TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseTypeRebookingFee'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN CourseTypeRebookingFee TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': VenueCourseType'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN VenueCourseType TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseClientPayment'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN CourseClientPayment TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseClient'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN CourseClient TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseVenue'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN CourseVenue TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseDate'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN CourseDate TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': ClientOnlineBookingState'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN ClientOnlineBookingState TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DORSCourse'
DELETE TOrg3
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
INNER JOIN DORSCourse TOrg3 ON TOrg3.CourseId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': Course'
DELETE TOrg2
FROM CourseType TOrg
INNER JOIN Course TOrg2 ON TOrg2.CourseTypeId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': CourseType'
DELETE CourseType
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': AdministrationMenuItemOrganisation'
DELETE AdministrationMenuItemOrganisation
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationDisplay'
DELETE OrganisationDisplay
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationDashboardMeter'
DELETE OrganisationDashboardMeter
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DashboardMeterExposure'
DELETE DashboardMeterExposure
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationPaymentType'
DELETE OrganisationPaymentType
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationRegion'
DELETE OrganisationRegion
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationReport'
DELETE OrganisationReport
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': SystemStateSummaryHistory'
DELETE TOrg2
FROM SystemStateSummary TOrg
INNER JOIN SystemStateSummaryHistory TOrg2 ON TOrg2.SystemStateSummaryId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': SystemStateSummary'
DELETE SystemStateSummary
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationContact'
DELETE OrganisationContact
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationCourseStencil'
DELETE OrganisationCourseStencil
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': PaymentMethod'
DELETE PaymentMethod
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': SearchHistoryItem'
DELETE TOrg4
FROM OrganisationUser TOrg
INNER JOIN [User] TOrg2 ON TOrg2.Id = TOrg.UserId
INNER JOIN SearchHistoryUser TOrg3 ON TOrg3.UserId = TOrg2.Id
INNER JOIN SearchHistoryItem TOrg4 ON TOrg4.SearchHistoryUserId = Torg3.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': SearchHistoryUser'
DELETE TOrg3
FROM OrganisationUser TOrg
INNER JOIN [User] TOrg2 ON TOrg2.Id = TOrg.UserId
INNER JOIN SearchHistoryUser TOrg3 ON TOrg3.UserId = TOrg2.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': [User]'
DELETE TOrg2
FROM OrganisationUser TOrg
INNER JOIN [User] TOrg2 ON TOrg2.Id = TOrg.UserId
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationUser'
DELETE OrganisationUser
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationDORSForceContract'
DELETE OrganisationDORSForceContract
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DORSSiteVenue'
DELETE TOrg2
FROM Venue TOrg
INNER JOIN DORSSiteVenue TOrg2 ON TOrg2.VenueId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': VenueAddress'
DELETE TOrg2
FROM Venue TOrg
INNER JOIN VenueAddress TOrg2 ON TOrg2.VenueId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': VenueLocale'
DELETE TOrg2
FROM Venue TOrg
INNER JOIN VenueLocale TOrg2 ON TOrg2.VenueId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': VenueDirections'
DELETE TOrg2
FROM Venue TOrg
INNER JOIN VenueDirections TOrg2 ON TOrg2.VenueId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': TrainerVenue'
DELETE TOrg2
FROM Venue TOrg
INNER JOIN TrainerVenue TOrg2 ON TOrg2.VenueId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': Venue'
DELETE Venue
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DORSConnectionHistory'
DELETE TOrg2
FROM DORSConnection TOrg
INNER JOIN DORSConnectionHistory TOrg2 ON TOrg2.DORSConnectionId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DORSOffersWithdrawnLog'
DELETE TOrg2
FROM DORSConnection TOrg
INNER JOIN DORSOffersWithdrawnLog TOrg2 ON TOrg2.DORSConnectionId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': DORSConnection'
DELETE DORSConnection
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationEmailCount'
DELETE OrganisationEmailCount
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': EmailServiceEmailsSent'
DELETE EmailServiceEmailsSent
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': TrainerOrganisation'
DELETE SystemSupportUser
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationAdminUser'
DELETE OrganisationAdminUser
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': ScheduledSMSTo'
DELETE TOrg2
FROM ScheduledSMS TOrg
INNER JOIN ScheduledSMSTo TOrg2 ON TOrg2.ScheduledSMSId = TOrg.Id
WHERE TOrg.OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': ScheduledSMS'
DELETE ScheduledSMS
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': ClientQuickSearch'
DELETE ClientQuickSearch
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': ClientOrganisation'
DELETE ClientOrganisation
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': OrganisationScheduledEmail'
DELETE OrganisationScheduledEmail
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': SystemStateSummaryHistory'
DELETE SystemStateSummaryHistory
WHERE OrganisationId IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);

PRINT CAST(GETDATE() AS VARCHAR) + ': Organisation'
DELETE Organisation
WHERE Id IN (SELECT DISTINCT OrganisationId FROM #DeleteOrg);



