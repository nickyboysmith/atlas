

/*
	Setup Administration Menu Items

		Script Name: SetupAdministrationMenuItems.sql
		Created By: Robert Newnham 19/11/2015
		Updated By: Robert Newnham 19/11/2015
*/

	IF OBJECT_ID('tempdb..#MenuGroup', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #MenuGroup;
	END

	SELECT DISTINCT GroupTitle AS Title, GroupDescription AS Description, GroupSortNumber AS SortNumber
	INTO #MenuGroup
	FROM (
		SELECT
			'Client' AS GroupTitle
			, 'Client Administration' AS GroupDescription
			, '60' AS GroupSortNumber
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Course Administration' AS GroupDescription
			, '50' AS GroupSortNumber
		UNION
		SELECT
			'DORS' AS GroupTitle
			, 'DORS Administration' AS GroupDescription
			, '70' AS GroupSortNumber
		UNION
		SELECT
			'Organisation' AS GroupTitle
			, 'Organisation Administration' AS GroupDescription
			, '10' AS GroupSortNumber
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Payment Administration' AS GroupDescription
			, '40' AS GroupSortNumber
		UNION
		SELECT
			'Security' AS GroupTitle
			, 'System Security Administration' AS GroupDescription
			, '30' AS GroupSortNumber
		UNION
		SELECT
			'User' AS GroupTitle
			, 'User Administration' AS GroupDescription
			, '20' AS GroupSortNumber
		UNION
		SELECT
			'Other' AS GroupTitle
			, 'Other Administration' AS GroupDescription
			, '100' AS GroupSortNumber
		UNION
		SELECT
			'Reporting' AS GroupTitle
			, 'Reporting Administration' AS GroupDescription
			, '200' AS GroupSortNumber
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'System Administration' AS GroupDescription
			, '300' AS GroupSortNumber
		) AS MenuGroup

	INSERT INTO dbo.AdministrationMenuGroup (Title, [Description], SortNumber)
	SELECT Title, [Description], SortNumber
	FROM #MenuGroup MGT
	WHERE NOT EXISTS (SELECT * FROM dbo.AdministrationMenuGroup WHERE Title = MGT.Title)

	UPDATE MG
	SET Description = MGT.Description
	, SortNumber = MGT.SortNumber
	FROM dbo.AdministrationMenuGroup MG
	INNER JOIN #MenuGroup MGT ON MGT.Title = MG.Title;


	IF OBJECT_ID('tempdb..#MenuItem', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #MenuItem;
	END

	SELECT DISTINCT
		GroupTitle
		, ItemTitle
		, ItemDescription
		, ItemUrl
		, ItemModal
		, ItemDisabled
		, ItemController
		, ItemParameters
		, ItemSortNumber
		, ItemClass
		, AssignToAllSystemsAdmins
		, AssignAllOrganisationAdmin
		, AssignWholeOrganisation
		, ExcludeReferringAuthorityOrganisation
	INTO #MenuItem
	FROM (
		--SELECT
		--	'Client' AS GroupTitle
		--	, 'Client Add' AS ItemTitle
		--	, 'Client Add' AS ItemDescription
		--	, 'app/components/client/add' AS ItemUrl
		--	, 'True' AS ItemModal
		--	, 'False' AS ItemDisabled
		--	, 'Client' AS ItemController
		--	, '' AS ItemParameters
		--	, '999' AS ItemSortNumber
		--UNION
		SELECT
			'Course' AS GroupTitle
			, 'Course Type' AS ItemTitle
			, 'Course Type Maintenance' AS ItemDescription
			, '/app/components/coursetype/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'CourseTypeCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'courseTypeModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Course Type Categories' AS ItemTitle
			, 'Course Type Category Maintenance' AS ItemDescription
			, '/app/components/coursetypecategories/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'CourseTypeCategoryCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'courseTypeCategoryModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'DORS' AS GroupTitle
			, 'Connection Details' AS ItemTitle
			, 'Edit Connection Details' AS ItemDescription
			, '/app/components/dors/editConnectionDetails' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'EditConnectionDetailsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'editConnectionDetailsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'DORS' AS GroupTitle
			, 'Connection Settings' AS ItemTitle
			, 'Edit Connection Settings' AS ItemDescription
			, '/app/components/dors/editConnectionSettings' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'EditConnectionSettingsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'editConnectionSettingsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Venue' AS ItemTitle
			, 'Venue Maintenance' AS ItemDescription
			, '/app/components/venue/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'venueCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'venueModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Add Course' AS ItemTitle
			, 'Course Maintenance' AS ItemDescription
			, '/app/components/course/add' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'addCourseCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'courseModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Payment Type' AS ItemTitle
			, 'Payment Type Maintenance' AS ItemDescription
			, '/app/components/payment/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ManagePaymentCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'paymentTypeModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Trainer' AS GroupTitle
			, 'Trainer Search' AS ItemTitle
			, 'Trainer Search' AS ItemDescription
			, '/app/components/trainer/search/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'trainerSearchCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'trainerSearchModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Trainer' AS GroupTitle
			, 'Trainer Settings' AS ItemTitle
			, 'Trainer Settings' AS ItemDescription
			, '/app/components/trainer/settings/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'trainerSettingsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'trainerSettingsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Trainer' AS GroupTitle
			, 'Assign Course Types' AS ItemTitle
			, 'Assign Course Type Categories' AS ItemDescription
			, '/app/components/courseTypeCategories/assignTrainer' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'AssignTrainerCourseTypeCategoriesCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'assignTrainerCourseTypeCategoriesModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Trainer' AS GroupTitle
			, 'Documents for All Trainers' AS ItemTitle
			, 'Documents for all Trainers Administration' AS ItemDescription
			, '/app/components/trainer/documents/allTrainers' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'allTrainersDocumentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'allTrainerDocumentsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Documents for All Courses' AS ItemTitle
			, 'Documents for all Courses Administration' AS ItemDescription
			, '/app/components/course/documents/allCourses' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'allCoursesDocumentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'allCourseDocumentsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Documents for All Course Types' AS ItemTitle
			, 'Documents for all Course Types Administration' AS ItemDescription
			, '/app/components/coursetype/documents/allCourseTypes' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'allCourseTypesDocumentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'allCourseTypeDocumentsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Course Trainers' AS ItemTitle
			, 'Manage Course Trainer Allocations' AS ItemDescription
			, '/app/components/courseTrainer/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'CourseTrainersCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'courseTrainersModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Course' AS GroupTitle
			, 'Create Multi-Course Stencil' AS ItemTitle
			, 'Create Multi-Course Stencil Maintenance' AS ItemDescription
			, '/app/components/courseStencil/add' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'addCourseStencilCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'courseStencilModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'True' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Create Multi-Course Stencils' AS ItemTitle
			, 'This feature will allow the User to view a list of all course stencils edit existing, create courses, remove courses and create new Course Stencils.' AS ItemDescription
			, '/app/components/stencilCourse/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'editStencilCourseCtrl' AS ItemController
			, '' AS ItemParameters
			, '1000' AS ItemSortNumber
			, 'stencilCourseModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'True' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
  		SELECT
			'User' AS GroupTitle
			, 'User Maintenance' AS ItemTitle
			, 'User Maintenance' AS ItemDescription
			, '/app/components/users/userSearch' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'UsersCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'userSearchModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Payment Provider' AS ItemTitle
			, 'Payment Provider Maintenance' AS ItemDescription
			, '/app/components/paymentProvider/Update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'PaymentProviderCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'paymentProviderModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Refund Request' AS ItemTitle
			, 'Refund Request Maintenance' AS ItemDescription
			, '/app/components/refundRequest/find' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'FindRefundRequestCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'refundRequestModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Other' AS GroupTitle
			, 'Public Holiday' AS ItemTitle
			, 'Public Holiday Maintenance' AS ItemDescription
			, '/app/components/publicholiday/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'PublicHolidayCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'publicHolidayModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Reporting' AS GroupTitle
			, 'Report Categories' AS ItemTitle
			, 'Edit Report Categories' AS ItemDescription
			, '/app/components/reportcategory/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ManageReportCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'reportCategoryModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Reporting' AS GroupTitle
			, 'Reports' AS ItemTitle
			, 'Search for Reports' AS ItemDescription
			, '/app/components/report/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'reportSearchCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'reportSearchModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Reporting' AS GroupTitle
			, 'Add Report' AS ItemTitle
			, 'Add a Report' AS ItemDescription
			, '/app/components/report/save' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'reportCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'reportAddModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Reporting' AS GroupTitle
			, 'Data View Maintenance' AS ItemTitle
			, 'Data View Maintenance' AS ItemDescription
			, '/app/components/dataview/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'dataViewCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'dataViewModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Admin Menu Control' AS ItemTitle
			, 'Admin Menu Maintenance' AS ItemDescription
			, '/app/components/adminMenu/add' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'AdminMenuCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'AdminMenuModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Organisation Self Configuration' AS ItemTitle
			, 'Configure Self Organisation' AS ItemDescription
			, '/app/components/organisationSelfConfiguration/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'OrganisationSelfConfigurationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'OrganisationSelfConfigurationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Organisation System Configuration' AS ItemTitle
			, 'Configure System Organisation' AS ItemDescription
			, '/app/components/organisationSystemConfiguration/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'OrganisationSystemConfigurationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'OrganisationSystemConfigurationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Organisation' AS GroupTitle
			, 'Document Management' AS ItemTitle
			, 'Manage an Organisation''s documents' AS ItemDescription
			, '/app/components/organisation/documents' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'OrganisationDocumentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'OrganisationDocumentManagementModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Organisation' AS GroupTitle
			, 'Referring Authority Details' AS ItemTitle
			, 'Manage an Organisations Referring Authority' AS ItemDescription
			, '/app/components/referringAuthority/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'referringAuthorityCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'referringAuthorityModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Scheduler Control Configuration' AS ItemTitle
			, 'Configure Scheduler Control' AS ItemDescription
			, '/app/components/schedulerControl/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SchedulerControlCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SchedulerControlModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Document Statistics' AS ItemTitle
			, 'Document Statistics and Administration' AS ItemDescription
			, '/app/components/documents/statistics' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DocumentStatisticsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DocumentStatisticsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'System Support Users' AS ItemTitle
			, 'System Support Users' AS ItemDescription
			, '/app/components/users/systemsupportusers' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SystemSupportUsersCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SystemSupportUsersModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Blocked Outgoing Email Addresses' AS ItemTitle
			, 'Maintain Blocked Outgoing Email Addresses' AS ItemDescription
			, '/app/components/emailblockedoutgoingaddress/delete' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'EmailBlockedOutgoingAddressCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'EmailBlockedOutgoingAddressModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'DORS Control' AS ItemTitle
			, 'Configure DORS Control Settings' AS ItemDescription
			, '/app/components/dors/editDORSControlSettings' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DORSControlSettingsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DORSControlSettingsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Delete Marked Clients' AS ItemTitle
			, 'Delete Marked Clients' AS ItemDescription
			, '/app/components/client/deleteMarked' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DeleteMarkedClientsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DeleteMarkedClientsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'System Tasks' AS ItemTitle
			, 'System Tasks Maintenance' AS ItemDescription
			, '/app/components/systemtasks/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SystemTaskCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SystemTasksModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Delete Marked Documents' AS ItemTitle
			, 'Delete Marked Documents' AS ItemDescription
			, '/app/components/documents/deleteMarked' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DeleteMarkedDocumentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DeleteMarkedDocumentsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'System Control Configuration' AS ItemTitle
			, 'Configure System Control' AS ItemDescription
			, '/app/components/systemControl/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SystemControlCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SystemControlModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Organisation' AS GroupTitle
			, 'Letter Template Maintenance' AS ItemTitle
			, 'Maintain Letter Templates' AS ItemDescription
			, '/app/components/letters/templates' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'letterTemplatesCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'letterTemplatesModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Additional Requirements' AS ItemTitle
			, 'Client Additional Requirements Maintenance' AS ItemDescription
			, '/app/components/specialrequirements/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SpecialRequirementCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SpecialRequirementsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Meter Availability' AS ItemTitle
			, 'Dashboard Meter Availability' AS ItemDescription
			, '/app/components/dashboardMeter/assignUser' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'AssignMeterUsersCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'assignUserDashBoardMetersModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Dashboard Meter Maintenance & Exposure' AS ItemTitle
			, 'Configure Dashboard Meters' AS ItemDescription
			, '/app/components/dashboardMeter/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DashboardMeterCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DashboardMeterModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'System Feature Configuraton' AS ItemTitle
			, 'Configure System Features' AS ItemDescription
			, '/app/components/systemFeature/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'SystemFeatureCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'SystemFeatureModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Course Reminder Email Template' AS ItemTitle
			, 'Edit Course Reminder Email Template' AS ItemDescription
			, '/app/components/course/reminderEmail' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ReminderEmailCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'ReminderEmailModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Course Reminder SMS Template' AS ItemTitle
			, 'Edit Course Reminder SMS Template' AS ItemDescription
			, '/app/components/course/reminderSMS' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ReminderSMSCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'ReminderSMSModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'DORS Default Connection Rotation' AS ItemTitle
			, 'DORS Default Connection Rotation' AS ItemDescription
			, '/app/components/dors/DORSDefaultConnectionRotation' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'DORSDefaultConnectionRotationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'DORSDefaultConnectionRotationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'User' AS GroupTitle
			, 'Netcall Maintenance' AS ItemTitle
			, 'Add Users as Netcall Agents and set their Netcall Number' AS ItemDescription
			, '/app/components/users/netcallAgents' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'NetcallAgentsCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'NetcallAgentsModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Archive Control' AS ItemTitle
			, 'Amend how often Archiving processes happen' AS ItemDescription
			, '/app/components/archiveControl/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ArchiveControlCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'ArchiveControlModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Course Fee Maintenance' AS ItemTitle
			, 'Manage the amount payable for Course Bookings, based on the Course Type and/or Course Type Category' AS ItemDescription
			, '/app/components/courseFee/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'CourseFeeCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'CourseFeeModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Course Rebooking Fee Maintenance' AS ItemTitle
			, 'Manage the amount payable for Course Re-Bookings, based on the Course Type and/or Course Type Category' AS ItemDescription
			, '/app/components/courseRebookingFee/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'CourseRebookingFeeCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'CourseRebookingFeeModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Administer Blocked IPs' AS ItemTitle
			, 'Manage the Blocked IP Addresses and Unblock them if required' AS ItemDescription
			, '/app/components/blockedIP/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'BlockedIPCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'blockedIPModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Interpreter Administration' AS ItemTitle
			, 'Manage the list of Interpreters and the Language for an Organisation' AS ItemDescription
			, '/app/components/interpreterLanguage/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'InterpreterLanguageCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'InterpreterLanguageModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Task Category' AS ItemTitle
			, 'Manage the list of Task Categories for an Organisation' AS ItemDescription
			, '/app/components/taskCategory/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'TaskCategoryCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'TaskCategoryModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Mystery Shopper Administration' AS ItemTitle
			, 'Manage the list of Mystery Shopper Administrators' AS ItemDescription
			, '/app/components/mysteryShopper/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'MysteryShopperAdministrationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'MysteryShopperAdministrationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'User' AS GroupTitle
			, 'Mystery Shopper Administration' AS ItemTitle
			, 'Manage the list of Mystery Shopper Administrators' AS ItemDescription
			, '/app/components/mysteryShopper/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'MysteryShopperAdministrationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'MysteryShopperAdministrationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Vehicle Type Administration' AS ItemTitle
			, 'Manage vehicle types' AS ItemDescription
			, '/app/components/vehicleType/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'VehicleTypeAdministrationCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'VehicleTypeAdministrationModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'Vehicle Category Administration' AS ItemTitle
			, 'Manage vehicle categories' AS ItemDescription
			, '/app/components/vehicleCategory/manage' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'VehicleCategoryAdminCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'VehicleCategoryAdminModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Trainer' AS GroupTitle
			, 'Trainer Vehicles' AS ItemTitle
			, 'Maintain Trainer Vehicles' AS ItemDescription
			, '/app/components/trainerVehicle/update' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'TrainerVehicleCtrl' AS ItemController
			, '' AS ItemParameters
			, '10000' AS ItemSortNumber
			, 'TrainerVehicleModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'True' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Reconciliation Configuration' AS ItemTitle
			, 'Reconciliation Configuration' AS ItemDescription
			, '/app/components/reconciliationConfiguration/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ReconciliationConfigurationCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'reconciliationConfiguration' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'Payment' AS GroupTitle
			, 'Payment Reconciliation' AS ItemTitle
			, 'Payment Reconciliation' AS ItemDescription
			, '/app/components/paymentReconciliation/view' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'PaymentReconciliationCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'paymentReconciliation' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		UNION
		SELECT
			'System Admin' AS GroupTitle
			, 'UK VAT Rates Maintenance' AS ItemTitle
			, 'UK VAT Rates Maintenance' AS ItemDescription
			, '/app/components/vat/ukVATRates' AS ItemUrl
			, 'True' AS ItemModal
			, 'False' AS ItemDisabled
			, 'ukVATRatesCtrl' AS ItemController
			, '' AS ItemParameters
			, '999' AS ItemSortNumber
			, 'ukVATRatesModal' AS ItemClass
			, 'True' AS AssignToAllSystemsAdmins
			, 'False' AS AssignAllOrganisationAdmin
			, 'False' AS AssignWholeOrganisation
			, 'True' AS ExcludeReferringAuthorityOrganisation
		) AS MenuItem

	/* INSERT New or Missing Group */
	INSERT INTO dbo.AdministrationMenuGroup (Title, Description, SortNumber)
	SELECT DISTINCT GroupTitle AS Title, GroupTitle AS Description, 9999 AS SortNumber
	FROM #MenuItem MIT
	WHERE NOT EXISTS (SELECT * FROM dbo.AdministrationMenuGroup WHERE Title = MIT.GroupTitle)

	/* INSERT Menu Items */
	INSERT INTO dbo.AdministrationMenuItem (Title, Url, Description, Modal, Disabled, Controller, Parameters, Class)
	SELECT DISTINCT
		ItemTitle AS Title
		, ItemUrl AS Url
		, ItemDescription AS Description
		, ItemModal AS Modal
		, ItemDisabled AS Disabled
		, ItemController AS Controller
		, ItemParameters AS Parameters
		, ItemClass AS Class
	FROM #MenuItem MIT
	WHERE NOT EXISTS (SELECT *
						FROM dbo.AdministrationMenuItem
						WHERE Title = MIT.ItemTitle
						AND Controller = MIT.ItemController
						)

	UPDATE MI
	SET MI.Description = MIT.ItemDescription
	, MI.Parameters = MIT.ItemParameters
	, MI.Class = MIT.ItemClass
	, MI.Url = MIT.ItemUrl
	, MI.AssignToAllSystemsAdmins = MIT.AssignToAllSystemsAdmins
	, MI.AssignAllOrganisationAdmin = MIT.AssignAllOrganisationAdmin
	, MI.AssignWholeOrganisation = MIT.AssignWholeOrganisation
	, MI.ExcludeReferringAuthorityOrganisation = MIT.ExcludeReferringAuthorityOrganisation
	FROM dbo.AdministrationMenuItem MI
	INNER JOIN #MenuItem MIT ON MIT.ItemTitle = MI.Title
							AND MIT.ItemController = MI.Controller;

	--SELECT * FROM #MenuItem

	/* Link Groups to Group Items*/
	INSERT INTO dbo.AdministrationMenuGroupItem (AdminMenuGroupId, AdminMenuItemId, SortNumber)
	SELECT MG.Id AS AdminMenuGroupId, MI.Id AS AdminMenuItemId, MIT.ItemSortNumber AS SortNumber
	FROM #MenuItem MIT
	INNER JOIN dbo.AdministrationMenuGroup MG ON MG.Title = MIT.GroupTitle
	INNER JOIN dbo.AdministrationMenuItem MI ON MI.Title = MIT.ItemTitle
											AND MI.Url = MIT.ItemUrl
											AND MI.Controller = MIT.ItemController
	WHERE NOT EXISTS (SELECT * FROM dbo.AdministrationMenuGroupItem WHERE AdminMenuGroupId = MG.Id AND AdminMenuItemId = MI.Id)

	UPDATE MGI
	SET SortNumber = MIT.ItemSortNumber
	FROM dbo.AdministrationMenuGroupItem MGI
	INNER JOIN dbo.AdministrationMenuGroup MG ON MG.Id = MGI.AdminMenuGroupId
	INNER JOIN dbo.AdministrationMenuItem MI ON MI.Id = MGI.AdminMenuItemId
	INNER JOIN #MenuItem MIT ON MIT.GroupTitle = MG.Title
							AND MIT.ItemTitle = MI.Title
							AND MIT.ItemController = MI.Controller;


	--Assign All Menu Items to System Administrators
	INSERT INTO dbo.AdministrationMenuItemUser (AdminMenuItemId, UserId)
	SELECT DISTINCT AMI.Id AS AdminMenuItemId, SAU.UserId AS UserId
	FROM #MenuItem MIT
	INNER JOIN dbo.AdministrationMenuItem AMI ON AMI.Title = MIT.ItemTitle
	, dbo.SystemAdminUser SAU
	WHERE MIT.AssignToAllSystemsAdmins = 'True'
	AND NOT EXISTS (SELECT *
						FROM dbo.AdministrationMenuItemUser AMIU
						WHERE AMIU.AdminMenuItemId = AMI.Id
						AND AMIU.UserId = SAU.UserId)
	;

	--Assign All Menu Items to All in Organisation
	INSERT INTO [dbo].[AdministrationMenuItemOrganisation] (OrganisationId, AdminMenuItemId)
	SELECT DISTINCT O.Id AS OrganisationId, AMI.Id AS AdminMenuItemId
	FROM #MenuItem MIT
	INNER JOIN [dbo].[AdministrationMenuItem] AMI ON AMI.Title = MIT.ItemTitle
	, dbo.Organisation O
	LEFT JOIN dbo.ReferringAuthority RA ON RA.AssociatedOrganisationId = O.Id
	WHERE MIT.AssignWholeOrganisation = 'True'
	AND (
		(AMI.ExcludeReferringAuthorityOrganisation = 'False')
		OR (AMI.ExcludeReferringAuthorityOrganisation = 'True' AND RA.Id IS NULL)
		)
	AND NOT EXISTS ( SELECT *
						FROM [dbo].[AdministrationMenuItemOrganisation] AMIO
						WHERE AMIO.OrganisationId = O.Id
						AND AMIO.AdminMenuItemId = AMI.Id)
	;

	--Assign All Menu Items to Organisation Administrators
	INSERT INTO dbo.AdministrationMenuItemUser (AdminMenuItemId, UserId)
	SELECT DISTINCT AMI.Id AS AdminMenuItemId, OAU.UserId AS UserId
	FROM #MenuItem MIT
	INNER JOIN dbo.AdministrationMenuItem AMI ON AMI.Title = MIT.ItemTitle
	, dbo.OrganisationAdminUser OAU
	LEFT JOIN dbo.ReferringAuthority RA ON RA.AssociatedOrganisationId = OAU.OrganisationId
	WHERE MIT.AssignAllOrganisationAdmin = 'True'
	AND (
		(AMI.ExcludeReferringAuthorityOrganisation = 'False')
		OR (AMI.ExcludeReferringAuthorityOrganisation = 'True' AND RA.Id IS NULL)
		)
	AND NOT EXISTS (SELECT *
						FROM dbo.AdministrationMenuItemUser AMIU
						WHERE AMIU.AdminMenuItemId = AMI.Id
						AND AMIU.UserId = OAU.UserId)
	;

	/* TIDY UP */

	IF OBJECT_ID('tempdb..#MenuItem', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #MenuItem;
	END


	IF OBJECT_ID('tempdb..#MenuGroup', 'U') IS NOT NULL
	BEGIN
		DROP TABLE #MenuGroup;
	END
