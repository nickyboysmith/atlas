
DECLARE @resetIdentityColumns VARCHAR(MAX) = '';
DECLARE @TheTableeName VARCHAR(200) = '';

DECLARE db_cursor CURSOR FOR 
--SELECT 'DBCC CHECKIDENT (''' + [TABLE_NAME] + ''', RESEED, 1); ' AS ExecStatement
SELECT [TABLE_NAME] AS TableName
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
AND TABLE_NAME NOT IN (
					'AdministrationMenuGroup'
					, 'AdministrationMenuGroupItem'
					, 'AdministrationMenuItem'
					, 'AdministrationMenuItemOrganisation'
					, 'AdministrationMenuItemUser'
					, 'AdministrationMenuUser'
					, 'Area'
					, 'BlockIP'
					, 'Dashboard'
					, 'DashboardColumn'
					, 'DashboardGroup'
					, 'DashboardGroupItem'
					, 'DashboardMeter'
					, 'DashboardMeterCategory'
					, 'DashboardReport'
					, 'DatabaseErrorLog'
					, 'DORSControl'
					, 'DORSConnection'
					, 'DORSState'
					, 'Gender'
					, 'LoginState'
					, 'LetterAction'
					, 'Organisation'
					, 'OrganisationArchiveControl'
					, 'OrganisationDisplay'
					, 'OrganisationInterpreterSetting'
					, 'OrganisationLanguage'
					, 'OrganisationPaymentProvider'
					, 'OrganisationPaymentProviderCredential'
					, 'OrganisationPreferredSMSService'
					, 'OrganisationPrefferedEmailService'
					, 'OrganisationRegion'
					, 'OrganisationSelfConfiguration'
					, 'OrganisationSystemConfiguration'
					, 'OrganisationUser'
					, 'PaymentProvider'
					, 'PeriodicalSPJob'
					, 'PostalDistrict'
					, 'PostCodeInformation'
					, 'PublicHoliday'
					, 'Region'
					, 'ScriptLog'
					, 'SystemControl'
					, 'SystemAdminUser'
					, 'SystemFeatureGroup'
					, 'SystemFeatureGroupItem'
					, 'SystemFeatureItem'
					, 'SystemFeatureUserNote'
					, 'SystemInformation'
					, 'SystemState'
					, 'SystemStateSummary'
					, 'SystemTask'
					, 'SystemTrappedError'
					, 'SchedulerControl'
					, 'ScheduledEmailState'
					, 'FileStoragePath'
					, 'TaskAction'
					, 'TriggerLog'
					, 'User'
					, 'UserChangeLog'
					, 'UserDashboardMeter'
					, 'UserLogin'
					, 'UserPreferences'
					, 'UserPreviousId'
					, '__MigrationHistory'
					, '_MigrationDocumentTransferInformation'
					, '_Migration_CourseOrganisation'
					, '_Migration_DriverClientOrganisation'
					, '_Migration_InstructorOrganisation'
					, '_TempMigration_Document'
					)
					
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @TheTableeName   

WHILE @@FETCH_STATUS = 0   
BEGIN   
    SET @resetIdentityColumns = 'DBCC CHECKIDENT (''' + @TheTableeName + ''', RESEED, 1); '
	SELECT @TheTableeName, @resetIdentityColumns;
	--EXEC @resetIdentityColumns;
	DBCC CHECKIDENT (@TheTableeName, RESEED, 1);

    FETCH NEXT FROM db_cursor INTO @TheTableeName   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

