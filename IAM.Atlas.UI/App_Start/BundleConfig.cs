// --------------------------------------------------------------------------------------------------------------------
// <copyright file="BundleConfig.cs" company="Hewlett-Packard Company">
//   Copyright © 2015 Hewlett-Packard Company
// </copyright>
// --------------------------------------------------------------------------------------------------------------------

namespace IAM.Atlas.UI
{
    using System.Web;
    using System.Web.Optimization;

    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/app_assets/css/app").Include(
                "~/app_assets/css/app.css",
                "~/app_assets/css/main.css",
                "~/app_assets/css/spectrum.css",
                "~/app_assets/css/angular-chart.css"
            ));

            //bundles.Add(new ScriptBundle("~/js/jquery").Include("~/scripts/vendor/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/js/app").Include(
                //"~/scripts/vendor/angular-ui-router.js",

                "~/app/shared/core/controllers/dragDropUpdateController.js",

                /**
                 * The cookie factory leverages the jQuery Cookie Library
                 * https://github.com/carhartl/jquery-cookie
                 "~/app/shared/core/factories/overlaytestFactory.js",
                 */
                "~/app/shared/core/factories/atlasCookieFactory.js",
                "~/app/shared/core/factories/unAuthorizedAccessFactory.js",
                "~/app/shared/core/factories/modalOptionsFactory.js",
                "~/app/shared/core/factories/overlayFactory.js",

                "~/app/shared/core/filters/filters.js",
                "~/app/shared/core/services/services.js",
                "~/app/shared/core/services/ngDraggable.js",
                "~/app/shared/core/services/queryString.js",
                "~/app/shared/core/services/angular-idle.js",
                "~/app/shared/core/directives/directives.js",
                "~/app/shared/core/directives/rightClick.directive.js",
                "~/app/shared/core/directives/featureUnavailable/featureUnavailable.directive.js",
                "~/app/shared/core/directives/systemFeatureInformation/systemFeatureInformation.directive.js",
                "~/app/shared/core/directives/systemFeatureInformation/systemFeatureInformationDirectiveController.js",
                "~/app/shared/core/directives/dragDropUpdate.directive.js",
                "~/app/shared/core/directives/checklist-model.js",
                "~/app/shared/core/directives/textDropDown/textDropDown.js",
                "~/app/shared/core/directives/fadeMessage/fadeMessage.directive.js",
                "~/app/shared/core/directives/ambaSortableList/ambaSortableList.js",
                "~/app/shared/core/directives/documentUpload/documentUploadController.js",
                "~/app/shared/core/directives/documentUpload/documentUpload.directive.js",
                "~/app/shared/core/directives/multiInput/multiInput.js",
                //"~/app/shared/core/directives/signOutMessage/signOutMessage.directive.js",
                "~/app/shared/core/directives/date/date.directive.js",
                "~/app/shared/core/directives/insertText/insertText.directive.js",
                "~/app/shared/core/directives/fileInputChosen/fileInputChosen.directive.js",
                "~/app/shared/core/directives/inputNumberValidation/inputNumberValidation.directive.js",
                "~/app/shared/core/directives/capitalize/capitalize.directive.js",
                "~/app/shared/core/directives/linkEnabled/linkEnabled.directive.js",

                // Event History
                "~/app/shared/core/directives/eventHistory/eventHistory.directive.js",
                "~/app/shared/core/directives/eventHistory/eventHistoryController.js",
                "~/app/shared/core/directives/eventHistory/eventHistoryService.js",
                "~/app/shared/core/directives/eventHistory/viewEventNoteController.js",
                "~/app/shared/core/directives/eventHistory/eventHistoryFactory.js",
                "~/app/shared/core/directives/eventHistory/eventHistoryModalController.js",

                //IAM Date Formatter
                "~/app/shared/core/directives/dateFormatter/iamDate.directive.js",

                //IAM Date validation
                "~/app/shared/core/directives/dateValidation/validDate.directive.js",

                // Navigation Components
                "~/app/shared/navigation/controllers/navigationController.js",
                "~/app/shared/navigation/factories/navigationFactory.js",
                "~/app/shared/navigation/services/navigationService.js",

                // Administration Menu Components
                "~/app/shared/administration/services/adminMenuService.js",

                // Admin Tools
                "~/app/shared/adminTools/controllers/findOutOfSyncDORSLicenceCtrl.js",
                "~/app/shared/adminTools/services/adminToolService.js",

                //"~/app/shared/menu/controllers/add.js",

                // Error Components
                "~/app/shared/error/controllers/errorController.js",

                // Crafty Clicks 
                "~/app/shared/craftyClicks/factories/craftyClicksFactory.js",
                "~/app/shared/craftyClicks/services/craftyClicksService.js",

                // getAddress
                "~/app/shared/getAddress/factories/getAddressFactory.js",
                "~/app/shared/getAddress/services/getAddressService.js",

                // licence data interpretation
                "~/app/shared/licence/services/licenceService.js",

                // Organisation Display Component
                "~/app/shared/organisationDisplay/controllers/organisationDisplayController.js",
                "~/app/shared/organisationDisplay/services/organisationDisplayService.js",
                "~/app/shared/organisationDisplay/services/organisationDisplaySortService.js",

                // Note Components
                "~/app/shared/notes/services/noteTypeService.js",

                // Documents
                "~/app/shared/document/services/documentService.js",


                // Home Components
                "~/app/components/home/controllers/homeController.js",
                "~/app/components/home/controllers/dashboardController.js",
                "~/app/components/home/controllers/dashboardHoverInformationController.js",
                "~/app/components/home/services/dashboardService.js",
                "~/app/components/home/factories/dashboardFactory.js",

                // About Components
                "~/app/components/about/controllers/aboutController.js",

                // DORS Components
                "~/app/components/dors/controllers/editConnectionDetailsController.js",
                "~/app/components/dors/controllers/editConnectionSettingsController.js",
                "~/app/components/dors/controllers/addDORSConnectionNoteController.js",
                "~/app/components/dors/controllers/addDORSConnectionController.js",
                "~/app/components/dors/controllers/DORSDefaultConnectionRotationController.js",
                "~/app/components/dors/services/dorsConnectionDetailsService.js",
                "~/app/components/dors/services/dorsConnectionSettingsService.js",
                "~/app/components/dors/services/dorsConnectionCreationService.js",
                "~/app/components/dors/services/dorsConnectionService.js",

                // Email components
                "~/app/components/email/controllers/sendEmailController.js",
                "~/app/components/email/controllers/previewEmailController.js",
                "~/app/components/email/services/sendEmailService.js",
                "~/app/components/email/services/emailService.js",

                // SMS components
                "~/app/components/SMS/controllers/clientSMSController.js",
                "~/app/components/SMS/controllers/allClientSMSController.js",
                "~/app/components/SMS/controllers/allTrainerSMSController.js",
                "~/app/components/SMS/services/SMSService.js",

                // Login Components
                "~/app/components/login/services/authenticationService.js",
                "~/app/components/login/services/organisationContactService.js",
                "~/app/components/login/services/organisationSelectionService.js",
                "~/app/components/login/services/emailConfirmationService.js",
                "~/app/components/login/services/viewCourseOptionsService.js",
                "~/app/components/login/services/clientRegisterService.js",
                "~/app/components/login/factories/authenticationFactory.js",
                "~/app/components/login/controllers/signOutController.js",
                "~/app/components/login/factories/signOutFactory.js",
                "~/app/components/login/factories/loginFactory.js",
                "~/app/components/login/controllers/loginController.js",
                "~/app/components/login/controllers/loginOrganisationController.js",
                "~/app/components/login/controllers/chooseOrganisationController.js",
                "~/app/components/login/controllers/showCookieController.js",
                "~/app/components/login/controllers/fullyBookedCourseNotificationController.js",
                "~/app/components/login/controllers/loginInvitationController.js",
                "~/app/components/login/controllers/organisationContactsController.js",
                "~/app/components/login/controllers/organisationSelectionController.js",
                "~/app/components/login/controllers/viewOrganisationContactsController.js",
                "~/app/components/login/controllers/viewCourseOptionsController.js",
                "~/app/components/login/controllers/clientRegisterController.js",
                "~/app/components/login/controllers/clientConfirmRegistrationController.js",
                "~/app/components/login/controllers/clientSpecialRequirementsController.js",
                "~/app/components/login/controllers/clientCourseSelectionController.js",
                "~/app/components/login/controllers/clientCourseConfirmationController.js",
                "~/app/components/login/controllers/clientCoursePaymentController.js",
                "~/app/components/login/controllers/clientCoursePaymentVerificationController.js",
                "~/app/components/login/controllers/showTermsController.js",
                "~/app/components/login/services/systemService.js",
                "~/app/components/login/services/signOutService.js",



                // Change Password Components
                "~/app/components/changePassword/services/organisationListService.js",
                "~/app/components/changePassword/services/passwordValidationService.js",
                "~/app/components/changePassword/services/angular-no-captcha.js",
                "~/app/components/changePassword/services/processPasswordChange.js",
                "~/app/components/changePassword/controllers/changePasswordController.js",
                "~/app/components/changePassword/controllers/changePasswordRequestController.js",
                "~/app/components/changePassword/services/changePasswordRequestService.js",

                // ScriptLog Components
                "~/app/components/scriptLog/controllers/scriptLogController.js",

                // Users Components
                "~/app/components/users/controllers/usersController.js",
                "~/app/components/users/controllers/addUserController.js",
                "~/app/components/users/controllers/viewUserController.js",
                "~/app/components/users/controllers/editUserController.js",
                "~/app/components/users/services/userService.js",
                "~/app/components/users/factories/userFactory.js",

                // webApiTest Components
                "~/app/components/webApiTest/controllers/webApiTestController.js",

                // feed back form components
                "~/app/components/feedback/controllers/feedbackcontroller.js",


                // Controller for the client auth home page
                "~/app/components/client/controllers/clientHomeController.js",


                // client components
                "~/app/components/client/controllers/addClientController.js",
                "~/app/components/client/controllers/editClientController.js",
                "~/app/components/client/controllers/deleteConfirmationController.js",
                "~/app/components/client/controllers/clientDetailsController.js",
                "~/app/components/client/controllers/addClientNoteController.js",
                "~/app/components/client/controllers/addClientPaymentController.js",
                "~/app/components/client/controllers/addClientDocumentController.js",
                "~/app/components/client/controllers/clientBookCourseController.js",
                "~/app/components/client/controllers/findSingleClientController.js",
                "~/app/components/client/controllers/clientsController.js",
                "~/app/components/client/controllers/clientDocumentController.js",
                "~/app/components/client/controllers/updateSpecialRequirementsController.js",
                "~/app/components/client/controllers/editCourseBookingController.js",
                "~/app/components/client/controllers/removeFromCourseController.js",
                "~/app/components/client/controllers/transferToNewCourseController.js",
                "~/app/components/client/controllers/clientCourseBookings.js",
                "~/app/components/client/controllers/clientRescheduleCourseDetailsController.js",
                "~/app/components/client/controllers/clientRescheduleCourseConfirmController.js",
                "~/app/components/client/controllers/clientAvailableCoursesController.js",
                "~/app/components/client/controllers/clientPaymentsController.js",
                "~/app/components/client/services/clientService.js",
                "~/app/components/client/controllers/addIdentifierController.js",
                "~/app/components/client/controllers/clientsMarkedForDeletionController.js",

                // Client Site
                "~/app/components/clientSite/controllers/clientSitePaymentController.js",

                //Document Information Components
                "~/app/components/documentInformation/controllers/documentInformationController.js",
                "~/app/components/documentInformation/services/documentInformationService.js",


                //Mystery Shopper components
                "~/app/components/mysteryShopper/controllers/mysteryShopperAdministrationController.js",
                 "~/app/components/mysteryShopper/services/mysteryShopperService.js",

                //Vehicle Type components
                "~/app/components/vehicleType/controllers/vehicleTypeAdministrationController.js",
                "~/app/components/vehicleType/controllers/addVehicleTypeController.js",
                 "~/app/components/vehicleType/services/vehicleTypeService.js",

                //Vehicle Category components
                "~/app/components/vehicleCategory/controllers/vehicleCategoryAdminController.js",
                "~/app/components/vehicleCategory/controllers/addVehicleCategoryController.js",
                 "~/app/components/vehicleCategory/services/vehicleCategoryService.js",

                // Quick search
                "~/app/components/quickSearch/controllers/quickSearchController.js",
                "~/app/components/quickSearch/services/quickSearchService.js",


                // Configure Organisation Components
                "~/app/components/organisation/services/configureOrganisationService.js",
                "~/app/components/organisation/services/systemFontService.js",
                "~/app/components/organisation/services/organisationService.js",
                "~/app/components/organisation/controllers/configureOrganisationController.js",
                "~/app/components/organisation/controllers/OrganisationDocumentsController.js",
                "~/app/components/organisation/controllers/editOrganisationDocumentController.js",

                // Course Components
                "~/app/components/course/controllers/courseController.js",
                "~/app/components/course/controllers/cloneCourseController.js",
                "~/app/components/course/controllers/cloneCourseConfirmationController.js",
                "~/app/components/course/controllers/addCourseController.js",
                "~/app/components/course/factories/courseFactory.js",
                "~/app/components/course/factories/courseInterpreterFactory.js",
                "~/app/components/course/factories/courseTrainerFactory.js",
                "~/app/components/course/services/courseService.js",
                "~/app/components/course/services/courseInterpreterService.js",
                "~/app/components/course/services/courseTrainerService.js",
                "~/app/components/course/services/cancelCourseService.js",
                "~/app/components/course/controllers/editCourseController.js",
                "~/app/components/course/controllers/addCourseNoteController.js",
                "~/app/components/course/controllers/courseTrainerController.js",
                "~/app/components/course/controllers/courseInterpreterController.js",
                "~/app/components/course/controllers/addCourseInterpreterController.js",
                "~/app/components/course/controllers/addCourseTrainerController.js",
                "~/app/components/course/controllers/addCourseDocumentController.js",
                "~/app/components/course/controllers/cancelCourseController.js",
                "~/app/components/course/controllers/courseAttendanceController.js",
                "~/app/components/course/services/courseAttendanceService.js",
                "~/app/components/course/factories/courseAttendanceFactory.js",
                "~/app/components/course/controllers/availableCoursesController.js",
                "~/app/components/course/controllers/addCourseEmailAttachmentController.js",
                "~/app/components/course/controllers/attachCourseEmailAttachmentController.js",
                "~/app/components/course/controllers/trainersWithoutEmailsController.js",
                "~/app/components/course/controllers/clientsWithoutEmailsController.js",


                // Course Stencil Components
                "~/app/components/courseStencil/controllers/addCourseStencilController.js",
                "~/app/components/courseStencil/services/courseStencilService.js",

                //Stencil Course Components
                "~/app/components/stencilCourse/controllers/createStencilCourseController.js",
                "~/app/components/stencilCourse/controllers/editStencilCourseController.js",
                "~/app/components/stencilCourse/controllers/removeStencilCourseController.js",
                "~/app/components/stencilCourse/services/editStencilCourseService.js",

                // Course - Documents
                "~/app/components/course/documents/controllers/allCoursesDocumentsController.js",
                "~/app/components/course/documents/services/courseDocumentService.js",
                "~/app/components/course/documents/controllers/allCoursesDocumentUploadController.js",
                "~/app/components/course/documents/controllers/editAllCoursesDocumentController.js",
                "~/app/components/course/documents/controllers/allCoursesDocumentsAddExistingController.js",


                // Course Category Components
                "~/app/components/courseTypeCategories/controllers/courseTypeCategoryController.js",
                "~/app/components/courseTypeCategories/controllers/assignTrainerCourseTypeCategoryController.js",
                "~/app/components/courseTypeCategories/services/courseTypeCategoryService.js",
                "~/app/components/courseTypeCategories/controllers/addCourseTypeCategoryController.js",

                // Menu Components
                "~/app/shared/menu/services/menuFavouriteService.js",
                "~/app/shared/menu/controllers/menuFavouriteController.js",

                // Notification Components
                //"~/app/shared/notification/factories/notificationFactory.js",
                "~/app/shared/notification/services/notificationService.js",
                "~/app/shared/notification/controllers/notificationMsgController.js",
                "~/app/components/notifications/controllers/NotificationController.js",

                "~/app/components/course/services/courseService.js",

                // Payment 
                "~/app/components/payment/controllers/managePaymentTypesController.js",
                "~/app/components/payment/controllers/recordPaymentController.js",
                "~/app/components/payment/controllers/acceptCardPaymentController.js",
                "~/app/components/payment/controllers/findPaymentController.js",
                "~/app/components/payment/controllers/viewPaymentController.js",
                "~/app/components/payment/controllers/addPaymentNoteController.js",
                "~/app/components/payment/controllers/refundPaymentController.js",
                "~/app/components/payment/controllers/requestRefundPaymentController.js",
                "~/app/components/payment/factories/paymentManagementFactory.js",
                "~/app/components/payment/factories/recordPaymentFactory.js",
                "~/app/components/payment/factories/acceptCardPaymentFactory.js",
                "~/app/components/payment/services/paymentManagementService.js",
                "~/app/components/payment/services/recordPaymentService.js",
                "~/app/components/payment/services/paymentService.js",
                "~/app/components/payment/services/acceptCardPaymentService.js",
                "~/app/components/payment/services/refundService.js",

                //Refund Requests
                "~/app/components/refundRequest/controllers/findRefundRequestController.js",
                "~/app/components/refundRequest/controllers/cancelRefundRequestController.js",
                "~/app/components/refundRequest/services/refundRequestService.js",

                // User Search History Components
                "~/app/components/searchHistory/services/searchHistoryService.js",

                // Configure PaymentProvider Components
                "~/app/components/paymentProvider/services/paymentProviderService.js",
                "~/app/components/paymentProvider/controllers/paymentProviderController.js",

                // Configure VenueCostType Components
                "~/app/components/venueCostType/services/venueCostTypeService.js",
                "~/app/components/venueCostType/controllers/venueCostTypeController.js",

                // Configure VenueCost Components
                "~/app/components/venueCost/services/venueCostService.js",
                "~/app/components/venueCost/controllers/venueCostController.js",

                // Configure VenueCourseType Components
                "~/app/components/venueCourseType/services/venueCourseTypeService.js",
                "~/app/components/venueCourseType/controllers/addVenueCourseTypeController.js",

                // Venue Locale
                "~/app/components/venueLocale/controllers/addVenueLocaleController.js",
                "~/app/components/venueLocale/services/venueLocaleService.js",


                // Change template files - [Temporary to work with the change]
                "~/app/shared/core/controllers/changeTemplateController.js",

                // Toggle Controller
                "~/app/shared/toggle/controllers/toggleController.js",
                "~/app/shared/toggle/factories/toggleFactory.js",
                "~/app/shared/toggle/services/toggleService.js",

                // Area
                "~/app/components/area/controllers/manageAreaController.js",
                "~/app/components/area/factories/areaManagementFactory.js",
                "~/app/components/area/services/areaManagementService.js",

                // Course Type
                "~/app/components/courseType/controllers/courseTypeController.js",
                "~/app/components/courseType/controllers/addCourseTypeController.js",
                "~/app/components/courseType/factories/courseTypeFactory.js",
                "~/app/components/courseType/services/courseTypeService.js",

                // CourseType - Documents
                "~/app/components/courseType/documents/controllers/allCourseTypesDocumentsController.js",
                "~/app/components/courseType/documents/services/courseTypeDocumentService.js",
                "~/app/components/courseType/documents/controllers/allCourseTypesDocumentUploadController.js",
                "~/app/components/courseType/documents/controllers/editAllCourseTypesDocumentController.js",
                "~/app/components/courseType/documents/controllers/allCourseTypesDocumentsAddExistingController.js",

                // Tasks
                "~/app/components/task/services/taskService.js",
                "~/app/components/task/controllers/taskListController.js",
                "~/app/components/task/controllers/taskAssignToUserController.js",
                "~/app/components/task/controllers/addTaskController.js",
                "~/app/components/task/controllers/relateTaskToClientController.js",
                "~/app/components/task/controllers/relateTaskToCourseController.js",
                "~/app/components/task/controllers/relateTaskToTrainerController.js",
                "~/app/components/task/controllers/addTaskSelectUserController.js",

                //DocumentPrintQueue
                "~/app/components/documentPrintQueue/services/documentPrintQueueService.js",
                "~/app/components/documentPrintQueue/controllers/documentPrintQueueController.js",

                // Trainer - Home
                "~/app/components/trainer/home/controllers/TrainerHomeController.js",
                "~/app/components/trainer/home/controllers/trainerDashboardController.js",
                "~/app/components/trainer/home/services/trainerDashboardService.js",
                "~/app/components/trainer/home/services/trainerProfilePictureService.js",
                "~/app/components/trainer/home/factories/trainerProfilePictureFactory.js",

                // Trainer - About 
                "~/app/components/trainer/about/controllers/addTrainerNoteController.js",
                "~/app/components/trainer/about/controllers/addTrainerDocumentController.js",
                "~/app/components/trainer/about/controllers/TrainerAboutController.js",
                "~/app/components/trainer/about/controllers/trainerAddController.js",
                "~/app/components/trainer/about/services/TrainerProfileService.js",
                "~/app/components/trainer/about/factories/TrainerProfileFactory.js",

                // Trainer - Availabilty
                "~/app/components/trainer/availability/controllers/trainerAvailabilityController.js",
                "~/app/components/trainer/availability/controllers/availableTrainerCourseTypesController.js",
                "~/app/components/trainer/availability/controllers/trainerAvailabilityCalendarController.js",
                "~/app/components/trainer/availability/services/trainerAvailabilityService.js",
                "~/app/components/trainer/availability/factories/trainerAvailabilityFactory.js",

                // Trainer - Availability - Unavailability
                "~/app/components/trainer/availability/controllers/addTrainerUnavailabilityController.js",

                // Trainer - Search 
                "~/app/components/trainer/search/controllers/trainerSearchController.js",
                "~/app/components/trainer/search/services/trainerSearchService.js",

                // Trainer - Bookings 
                "~/app/components/trainer/bookings/controllers/trainerBookingsController.js",
                "~/app/components/trainer/bookings/factories/trainerBookingsFactory.js",
                "~/app/components/trainer/bookings/services/trainerBookingsService.js",

                // Trainer - Attendance 
                "~/app/components/trainer/attendance/controllers/trainerAttendanceController.js",
                "~/app/components/trainer/attendance/factories/trainerAttendanceFactory.js",
                "~/app/components/trainer/attendance/services/trainerAttendanceService.js",

                // Trainer - Settings
                "~/app/components/trainer/settings/controllers/trainerSettingsController.js",
                "~/app/components/trainer/settings/services/trainerSettingsService.js",

                // Trainer - Documents
                "~/app/components/trainer/documents/controllers/allTrainersDocumentsController.js",
                "~/app/components/trainer/documents/services/trainerDocumentService.js",
                "~/app/components/trainer/documents/controllers/allTrainersDocumentUploadController.js",
                "~/app/components/trainer/documents/controllers/editAllTrainersDocumentController.js",
                "~/app/components/trainer/documents/controllers/allTrainersDocumentsAddExistingController.js",

                // Trainer - Admin
                "~/app/components/trainer/admin/controllers/trainerAdminCalendarController.js",
                "~/app/components/trainer/admin/services/trainerService.js",

                // Venue Components
                "~/app/components/venue/services/venueService.js",
                "~/app/components/venue/services/showVenueAddressService.js",
                "~/app/components/venue/controllers/venueController.js",
                "~/app/components/venue/controllers/showVenueAddressController.js",
                "~/app/components/venue/controllers/addVenueRegionController.js",
                                
                // Modal Service
                "~/app/shared/modal/services/modalService.js",
                "~/app/components/courseType/services/courseTypesManagementService.js",

                // PublicHoliday
                "~/app/components/publicHoliday/controllers/managePublicHolidayController.js",
                "~/app/components/publicHoliday/services/publicHolidayManagementService.js",
                "~/app/components/publicHoliday/controllers/addPublicHolidayContoller.js",

                // Date methods
                "~/app/shared/date/factories/datefactory.js",

                // String methods
                "~/app/shared/string/services/stringService.js",

                // DataView Components
                "~/app/components/dataView/services/dataViewService.js",
                "~/app/components/dataView/controllers/dataViewController.js",
                "~/app/components/dataView/controllers/addDataViewController.js",

                // Report Category 
                "~/app/components/reportCategory/controllers/reportCategoriesController.js",
                "~/app/components/reportCategory/factories/reportCategoriesFactory.js",
                "~/app/components/reportCategory/services/reportCategoriesService.js",

                // Venue Image Map
                "~/app/components/venue/services/venueImageMapService.js",
                "~/app/components/venue/controllers/venueImageMapController.js",
                "~/app/components/venue/controllers/downloadVenueImageMapController.js",

                // Report Search
                "~/app/components/report/controllers/cloneReportController.js",
                "~/app/components/report/services/cloneReportService.js",
                "~/app/components/report/controllers/reportSearchController.js",
                "~/app/components/report/services/reportSearchService.js",

                // Email Confirmation
                "~/app/components/emailConfirmation/controllers/emailConfirmationController.js",

                // Report Add 
                "~/app/components/report/controllers/reportController.js",
                "~/app/components/report/controllers/reportOwnersController.js",
                "~/app/components/report/services/reportService.js",
                 "~/app/components/report/services/reportParametersService.js",
                 "~/app/components/report/controllers/reportParametersController.js",

                // Administration Menu
                "~/app/components/adminMenu/controllers/addAdminMenuController.js",
                "~/app/components/adminMenu/controllers/addAdminMenuGroupController.js",
                "~/app/components/adminMenu/services/adminMenuService.js",

                // System State
                "~/app/shared/systemState/services/systemStateService.js",

                // DORS Licence Check
                "~/app/components/dors/controllers/DORSLicenceCheckController.js",
                "~/app/components/dors/services/dorsService.js",

                 // Organisation Self Configuration 
                 "~/app/components/organisationSelfConfiguration/controllers/organisationSelfConfigurationController.js",
                 "~/app/components/organisationSelfConfiguration/services/organisationSelfConfigurationService.js",


                // Referring Authority
                "~/app/components/referringAuthority/services/referringAuthorityService.js",
                "~/app/components/referringAuthority/controllers/referringAuthorityController.js",

                 // Organisation System Configuration 
                 "~/app/components/organisationSystemConfiguration/controllers/organisationSystemConfigurationController.js",
                 "~/app/components/organisationSystemConfiguration/services/organisationSystemConfigurationService.js",

                // Genders
                "~/app/components/gender/services/genderService.js",

                // CourseReference
                "~/app/components/courseReference/services/courseReferenceService.js",
                "~/app/components/courseReference/controllers/courseReferenceTrainerSettingsController.js",
                "~/app/components/courseReference/controllers/courseReferenceInterpreterSettingsController.js",

                // Document Statistics
                "~/app/components/documents/controllers/documentStatisticsController.js",

                // SchedulerControl
                "~/app/components/schedulerControl/services/SchedulerControlService.js",
                "~/app/components/schedulerControl/controllers/editSchedulerControlController.js",

                // Create New Organisation
                "~/app/components/organisation/controllers/addOrganisationController.js",

                // system admin support users
                "~/app/components/users/controllers/systemAdminSupportUsersController.js",
                "~/app/components/users/controllers/addSystemAdminSupportUsersController.js",

                // system support users
                "~/app/components/users/controllers/systemsupportuserscontroller.js",
                "~/app/components/users/controllers/addsystemsupportusercontroller.js",
               

                // active system users
                "~/app/components/users/controllers/activeSystemUsersController.js",

                // Blocked Outgoing Email Address
                "~/app/components/emailBlockedOutgoingAddress/services/emailBlockedOutgoingAddressService.js",
                "~/app/components/emailBlockedOutgoingAddress/controllers/emailBlockedOutgoingAddressController.js",

                // DORS Control Settings
                "~/app/components/dors/services/dorsControlSettingsService.js",
                "~/app/components/dors/controllers/DORSControlSettingsController.js",

                // Help and Support
                "~/app/components/help/controllers/helpController.js",

                // Delete Marked Clients
                "~/app/components/client/controllers/deleteMarkedController.js",

                // Delete Marked Documents
                "~/app/components/documents/controllers/deleteMarkedController.js",

                // System Tasks
                "~/app/components/systemTasks/controllers/SystemTaskController.js",
                "~/app/components/systemTasks/services/SystemTaskService.js",

                // Special Requirements
                "~/app/components/specialRequirements/controllers/SpecialRequirementsController.js",
                "~/app/components/specialRequirements/services/SpecialRequirementsService.js",
                "~/app/components/specialRequirements/controllers/AddSpecialRequirementController.js",
                // System Control
                "~/app/components/systemControl/services/SystemControlService.js",
                "~/app/components/systemControl/controllers/editSystemControlController.js",

                // Letters
                "~/app/components/letters/controllers/letterTemplatesController.js",
                "~/app/components/letters/controllers/letterUploadController.js",
                "~/app/components/letters/services/letterService.js",

                // Letter Templates
                "~/app/components/letterTemplate/controllers/letterTemplateController.js",
                "~/app/components/letterTemplate/services/letterTemplateService.js",

                // Dashboard
                "~/app/components/dashboardMeter/controllers/dashboardMeterController.js",
                "~/app/components/dashboardMeter/controllers/organisationDashboardMeterController.js",
                "~/app/components/dashboardMeter/controllers/assignUserDashBoardMeterController.js",
                "~/app/components/dashboardMeter/controllers/dashboardMeterUserController.js",
                "~/app/components/dashboardMeter/services/dashboardMeterService.js",
                "~/app/components/dashboardMeter/factories/userDashBoardMeterFactory.js",
                "~/app/components/dashboardMeter/services/userDashBoardMeterService.js",

                // Document Downloads
                "~/app/components/documents/controllers/documentDownloadController.js",
                "~/app/components/documents/services/downloadDocumentService.js",

                // Internal Messaging
                "~/app/components/messaging/controllers/messagingController.js",
                "~/app/components/messaging/services/messagingService.js",

                // Course Trainer Administration
                "~/app/components/courseTrainer/controllers/courseTrainersController.js",
                "~/app/components/courseTrainer/services/courseTrainersService.js",

                 // System Feature
                "~/app/components/systemFeature/services/SystemFeatureService.js",
                "~/app/components/systemFeature/controllers/systemFeatureInformationController.js",
                "~/app/components/systemFeature/controllers/updateSystemFeatureController.js",
                "~/app/components/systemFeature/controllers/addSystemFeatureGroupController.js",
                "~/app/components/systemFeature/controllers/addSystemFeatureGroupItemController.js",
                "~/app/components/systemFeature/controllers/addExistingSystemFeatureGroupItemController.js",
                "~/app/components/systemFeature/controllers/viewSystemFeatureInformationController.js",
                "~/app/components/systemFeature/controllers/addSystemFeatureInformationNoteController.js",
                "~/app/components/systemFeature/controllers/addSystemFeatureNote.js",

                // Course Reminders - Email and SMS
                "~/app/components/course/controllers/reminderEmailController.js",
                "~/app/components/course/controllers/reminderSMSController.js",

                // Netcall Agents
                "~/app/components/users/controllers/netcallAgentsController.js",
                "~/app/components/users/controllers/addNetcallAgentController.js",
                "~/app/components/users/controllers/editNetcallAgentNumberController.js",

                // Netcall test
                "~/app/components/netcall/controllers/testNetcallController.js",
                "~/app/components/netcall/services/netcallService.js",

                // Archive Control
                "~/app/components/archiveControl/services/archiveControlService.js",
                "~/app/components/archiveControl/controllers/archiveControlController.js",

                // Course Fee
                "~/app/components/courseFee/services/courseFeeService.js",
                "~/app/components/courseFee/controllers/courseFeeController.js",
                "~/app/components/courseFee/controllers/cancelCourseFeeController.js",
                "~/app/components/courseFee/controllers/addCourseFeeController.js",

                // Email All Clients and Trainers on a Course
                "~/app/components/course/controllers/emailAllClientsController.js",
                "~/app/components/course/controllers/emailAllTrainersController.js",
                "~/app/components/course/services/emailAllService.js",

                // Blocked Controller
                "~/app/components/login/controllers/blockedController.js",

                // Administer Blocking IP's
                "~/app/components/blockedIP/controllers/blockedIPController.js",
                "~/app/components/blockedIP/services/blockedIPService.js",

                // Course Rebooking Fee
                "~/app/components/courseRebookingFee/services/courseRebookingFeeService.js",
                "~/app/components/courseRebookingFee/controllers/courseRebookingFeeController.js",
                "~/app/components/courseRebookingFee/controllers/cancelCourseRebookingFeeController.js",
                "~/app/components/courseRebookingFee/controllers/addCourseRebookingFeeController.js",

                // Interpreter Administration
                "~/app/components/interpreterLanguage/services/interpreterLanguageService.js",
                "~/app/components/interpreterLanguage/controllers/interpreterLanguageController.js",
                "~/app/components/interpreterLanguage/controllers/addInterpreterLanguageController.js",
                "~/app/components/interpreterLanguage/controllers/editInterpreterLanguageController.js",
                "~/app/components/interpreterLanguage/controllers/addLanguageController.js",
                "~/app/components/interpreterLanguage/controllers/addNoteController.js",

                // Task Category
                "~/app/components/taskCategory/services/taskCategoryService.js",
                "~/app/components/taskCategory/controllers/taskCategoryController.js",
                "~/app/components/taskCategory/controllers/addTaskCategoryController.js",

                // Trainer Vehicle
                "~/app/components/trainerVehicle/services/trainerVehicleService.js",
                "~/app/components/trainerVehicle/controllers/trainerVehicleController.js",
                "~/app/components/trainerVehicle/controllers/addTrainerVehicleController.js",
                "~/app/components/trainerVehicle/controllers/editTrainerVehicleController.js",
                "~/app/components/trainerVehicle/controllers/trainerVehicleDetailController.js",
                "~/app/components/trainerVehicle/controllers/addNoteController.js",

                // VAT rate
                "~/app/components/vat/services/vatService.js",
                "~/app/components/vat/controllers/ukVATRatesController.js",
                "~/app/components/vat/controllers/addUKVATRateController.js",

                // Reconciliation Configuration
                "~/app/components/reconciliationConfiguration/services/reconciliationConfigurationService.js",
                "~/app/components/reconciliationConfiguration/controllers/reconciliationConfigurationController.js",
                "~/app/components/reconciliationConfiguration/controllers/addReconciliationConfigurationController.js",

                // Payment Reconciliation 
                "~/app/components/paymentReconciliation/services/paymentReconciliationService.js",
                "~/app/components/paymentReconciliation/controllers/paymentReconciliationController.js",
                "~/app/components/paymentReconciliation/controllers/newPaymentReconciliationController.js"

            ));
        }
    }
}
