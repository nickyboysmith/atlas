(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationSelfConfigurationCtrl', OrganisationSelfConfigurationCtrl);

    OrganisationSelfConfigurationCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "ModalService", "OrganisationSelfConfigurationService", "CourseReferenceService"];

    function OrganisationSelfConfigurationCtrl($scope, $location, $window, $http, UserService, activeUserProfile, ModalService, OrganisationSelfConfigurationService, CourseReferenceService) {

        $scope.organisationSelfConfigurationService = OrganisationSelfConfigurationService;
        $scope.courseReferenceService = CourseReferenceService;
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.selfConfiguration = {};
        $scope.courseReferences = {};

        $scope.fromSelfConfiguration = true;

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        if (activeUserProfile.selectedOrganisation) {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;

            }
        }

        //Get Organisations function
        $scope.getOrganisations = function (userID) {

            $scope.userService.getOrganisationIds(userID)
            .then(function (data) {
                $scope.organisations = data;
                $scope.userService.checkSystemAdminUser($scope.userId)
                .then(function (data) {
                    $scope.isAdmin = data;
                });
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;

                }
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }


        //Get CourseReferences
        $scope.getCourseReferences = function () {

            $scope.courseReferenceService.GetAll()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.courseReferences = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Has an Organisation Trainer Setting
        $scope.hasTrainerSettings = function (OrganisationId) {

            $scope.courseReferenceService.HasTrainerSettings(OrganisationId)
                .then(
                    function (data) {
                        $scope.hasTrainerSetting = data;
                    },
                    function (response) {
                        $scope.hasTrainerSetting = false;
                    }
                );
        }

        //Has an Organisation Interpreter Setting
        $scope.hasInterpreterSettings = function (OrganisationId) {

            $scope.courseReferenceService.HasInterpreterSettings(OrganisationId)
                .then(
                    function (data) {
                        $scope.hasInterpreterSetting = data;
                    },
                    function (response) {
                        $scope.hasInterpreterSetting = false;
                    }
                );
        }


        $scope.getSelfConfigurationByOrganisation = function (organisationId) {

            $scope.organisationSelfConfigurationService.GetByOrganisation(organisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.selfConfiguration = response.data;

                        if (response.data == null) {
                            $scope.selectedTemplate = null;
                        }
                        else if (response.data.AutomaticallyGenerateCourseReference) {
                            $scope.selectedTemplate = response.data.CourseReferenceGeneratorId;
                        }

                        $scope.hasTrainerSettings(organisationId);
                        $scope.hasInterpreterSettings(organisationId);

                        $scope.organisationId = organisationId; // set it for the email template

                        $scope.successMessage = "";
                        $scope.validationMessage = "";
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        $scope.saveSettings = function () {
            $scope.successMessage = "";
            if ($scope.isAdmin == true) {

                if ($scope.validateForm()) {

                    $scope.selfConfiguration.UpdatedByUserId = $scope.userId;
                    $scope.selfConfiguration.CourseReferenceGeneratorId = $scope.selectedTemplate;

                    $scope.organisationSelfConfigurationService.saveSettings($scope.selfConfiguration)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);

                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";

                                $scope.hasTrainerSettings($scope.organisationId);
                                $scope.hasInterpreterSettings($scope.organisationId);

                            },
                            function (response) {
                                console.log("Error");
                                console.log(reponse);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );
                }
            }
            else {
                $scope.validationMessage = "User is not an Admin";
            }
        }

        $scope.selectCourseReferenceTemplate = function (selectedTemplate) {
            $scope.selectedTemplate = selectedTemplate;
        }


        $scope.editSMSTemplate = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Reminder SMS Template",
                cssClass: "ReminderSMSModal",
                filePath: "/app/components/course/reminderSMS.html",
                controllerName: "ReminderSMSCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.editEmailTemplate = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Reminder Email Template",
                cssClass: "ReminderEmailModal",
                filePath: "/app/components/course/reminderEmail.html",
                controllerName: "ReminderEmailCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }


        $scope.editTrainerCourseReferenceSettings = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Trainer Reference Generation Settings",
                cssClass: "courseReferenceGeneratorSettings",
                filePath: "/app/components/courseReference/updateTrainerSettings.html",
                controllerName: "CourseReferenceTrainerSettingsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.editInterpreterCourseReferenceSettings = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Course Interpreter Reference Generation Settings",
                cssClass: "courseReferenceGeneratorSettings",
                filePath: "/app/components/courseReference/updateInterpreterSettings.html",
                controllerName: "CourseReferenceInterpreterSettingsCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });
        }

        $scope.showTrainerSettings = function () {

            if ($scope.selfConfiguration.TrainersHaveCourseReference == true && $scope.hasTrainerSetting == true) {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.showInterpreterSettings = function () {

            if ($scope.selfConfiguration.InterpretersHaveCourseReference == true && $scope.hasInterpreterSetting == true) {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.checkSMSFunctionalityStatus = function (organisationId) {
            $scope.organisationSelfConfigurationService.checkSMSFunctionalityStatus(organisationId)
                    .then(function (response) {
                        $scope.isSMSEnabled = response.data
                    });
        }



        $scope.isValidEmail = function (emailaddess) {

            //ref
            //http://stackoverflow.com/questions/46155/validate-email-address-in-javascript

            var emailFormat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

            var validEmail = emailFormat.test(emailaddess);

            return validEmail;
        }

        $scope.toggleSpecialRequirementSettings = function (emailStart) {
            
            if (emailStart == 'AdminOnly') {
                $scope.selfConfiguration.SpecialRequirementsToSupportUsers = false;
                $scope.selfConfiguration.SpecialRequirementsToAllUsers = false;
            }
            else if (emailStart == 'SupportUsersOnly') {
                $scope.selfConfiguration.SpecialRequirementsToAdminsOnly = false;
                $scope.selfConfiguration.SpecialRequirementsToAllUsers = false;
            }
            else if (emailStart == 'AllUsers') {
                $scope.selfConfiguration.SpecialRequirementsToAdminsOnly = false;
                $scope.selfConfiguration.SpecialRequirementsToSupportUsers = false;
            }
        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            var MinHoldOnlineCourseBookings = 5;
            var MinClientsLocking = 10;

            var MinutesToHold = parseInt($scope.selfConfiguration.MinutesToHoldOnlineUnpaidCourseBookings);
            var MaximumLock = parseInt($scope.selfConfiguration.MaximumMinutesToLockClientsFor);

            var OnlineBookingCutOffDaysBeforeCourse = parseInt($scope.selfConfiguration.OnlineBookingCutOffDaysBeforeCourse);

            if (angular.isNumber(MinutesToHold) && !isNaN(MinutesToHold)) {
                if (MinutesToHold < MinHoldOnlineCourseBookings) {
                    $scope.validationMessage = "Minutes To Hold Online Unpaid Course Bookings should be greater than " + MinHoldOnlineCourseBookings;
                }
            }
            else {
                $scope.validationMessage = "Please enter a numeric value for Minutes To Hold Online Unpaid Course Bookings";
            }

            if (angular.isNumber(MaximumLock) && !isNaN(MaximumLock)) {
                if (MaximumLock < MinClientsLocking) {
                    $scope.validationMessage = "Minutes To Clients Locking for a Maximum of should be greater than " + MinClientsLocking;
                }
            }
            else {
                $scope.validationMessage = "Please enter a numeric value for Minutes To Clients Locking for a Maximum of";
            }

            if (angular.isNumber(OnlineBookingCutOffDaysBeforeCourse) && (OnlineBookingCutOffDaysBeforeCourse < 0 || OnlineBookingCutOffDaysBeforeCourse > 99)) {
                $scope.validationMessage = "Please enter a number between 0 and 99 for Online Booking Cut Off Days Before Course.";
            }
            else {
                if (isNaN(OnlineBookingCutOffDaysBeforeCourse)) {
                    $scope.validationMessage = "Please enter a number between 0 and 99 for Online Booking Cut Off Days Before Course.";
                }
            }

            if ($scope.selfConfiguration.VenueReplyEmailAddress) {
                if ($scope.selfConfiguration.VenueReplyEmailAddress.length > 0) {
                    if (!$scope.isValidEmail($scope.selfConfiguration.VenueReplyEmailAddress)) {
                        $scope.validationMessage = "Invalid Venue Reply Email Address";
                    }
                }
            }

            if (/[^a-zA-Z0-9]/.test($scope.selfConfiguration.SMSDisplayName)) {
                $scope.validationMessage = "SMS Display Name can not contain spaces or other special characters."
            }
            
            if ($scope.selfConfiguration.SMSDisplayName && $scope.selfConfiguration.SMSDisplayName.length > 11 ) {
                $scope.validationMessage = "SMS Display Name must be 11 alphanumeric characters or less. "
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getCourseReferences();
        $scope.getSelfConfigurationByOrganisation($scope.organisationId);
        $scope.checkSMSFunctionalityStatus(activeUserProfile.selectedOrganisation.Id);

    }

})();