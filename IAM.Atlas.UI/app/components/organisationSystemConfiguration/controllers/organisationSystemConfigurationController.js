(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('OrganisationSystemConfigurationCtrl', OrganisationSystemConfigurationCtrl);

    OrganisationSystemConfigurationCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', 'ModalService', "PaymentProviderService", "OrganisationSystemConfigurationService", "OrganisationSelfConfigurationService"];

    function OrganisationSystemConfigurationCtrl($scope, $location, $window, $http, UserService, activeUserProfile, ModalService, PaymentProviderService, OrganisationSystemConfigurationService, OrganisationSelfConfigurationService) {

        $scope.organisationSystemConfigurationService = OrganisationSystemConfigurationService;
        $scope.paymentProviderService = PaymentProviderService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;
        $scope.modalService = ModalService;
        
        $scope.systemConfiguration = {};
        $scope.paymentProviders = {};
        $scope.isSMSEnabled = false;
       
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
            $scope.organisationName = activeUserProfile.selectedOrganisation.Name;

        }
        else {
            if (activeUserProfile.OrganisationIds.length > 0) {
                $scope.organisationId = activeUserProfile.OrganisationIds[0].Id;
                $scope.organisationName = activeUserProfile.OrganisationIds[0].Name;

            }
        }

        $scope.getOrganisations = function (userID) {

            $scope.organisationSystemConfigurationService.getMainOrganisations()
            .then(function (data) {
                $scope.organisations = data.data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        $scope.getSystemConfigurationByOrganisation = function (organisationId, organisationName) {

            $scope.selectedOrganisation = organisationId;
            $scope.organisationName = organisationName;
            $scope.successMessage == '';
            $scope.organisationSystemConfigurationService.GetByOrganisation(organisationId)
                .then(
                    function (response) {
                        $scope.systemConfiguration = response.data;
                        if (!response.data.length > 0) {
                            $scope.successMessage == 'No Results Found.';
                        }

                    },
                    function (response) {
                    }
                );

        }

        //Get Organisation Payment Providers
        $scope.getPaymentProvidersByOrganisation = function (organisationId) {

            $scope.paymentProviderService.getPaymentProvidersByOrganisation(organisationId)
                .then(
                    function (data) {
                        $scope.organisationPaymentProviders = data;

                        if ($scope.organisationPaymentProviders.length > 0)
                            $scope.selectedOrganisationPaymentProvider = $scope.organisationPaymentProviders[0].Id;
                            $scope.selectedPaymentProviderId = $scope.organisationPaymentProviders[0].PaymentProviderId;

                    },
                    function (response) {
                    }
                );
        }

        $scope.selectPaymentProvider = function (selectedPaymentProvider) {
            $scope.selectedPaymentProviderId = selectedPaymentProvider;
        }

        //Get Default Payment Providers
        $scope.getPaymentProviders = function () {

            $scope.paymentProviderService.getPaymentProviders()
                .then(
                    function (data) {
                        $scope.paymentProviders = data;
                          
                        angular.forEach($scope.paymentProviders, function (value, key) {
                            if (value.Disabled == true)
                                $scope.paymentProviders[key].Name += " (Currently Disabled)"

                        });

                    },
                    function (response) {
                    }
                );
        }

        $scope.checkSMSFunctionalityStatus = function (organisationId) {
            OrganisationSelfConfigurationService.checkSMSFunctionalityStatus(organisationId)
                    .then(function (response) {
                        $scope.isSMSEnabled = response.data
                    });
        }



        $scope.saveSettings = function () {

            $scope.successMessage = '';
            $scope.validationMessage = '';

            if ($scope.validateForm()) {

                if ($scope.systemConfiguration) {

                    $scope.systemConfiguration.UpdatedByUserId = $scope.userId;

                    $scope.systemConfiguration.OrganisationPaymentProviderId = $scope.selectedOrganisationPaymentProvider;
                    $scope.systemConfiguration.PaymentProviderId = $scope.selectedPaymentProviderId
                    $scope.systemConfiguration.ProviderCode = $scope.organisationPaymentProviders[0].ProviderCode;
                    $scope.systemConfiguration.ShortCode = $scope.organisationPaymentProviders[0].ShortCode;


                    $scope.organisationSystemConfigurationService.saveSettings($scope.systemConfiguration)
                        .then(
                            function (response) {
                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";
                            },
                            function (response) {
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                            }
                        );

                }
                else {
                    $scope.successMessage = "";
                    $scope.validationMessage = "A Configuration does not exist for this Organisation";
                }
            }
           
        }

        $scope.createNewOrganisation = function () {

            $scope.modalService.displayModal({
                scope: $scope,
                title: "Create New Organisation",
                cssClass: "organisationCreateNewModal",
                filePath: "/app/components/organisation/add.html",
                controllerName: "AddOrganisationCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogueItself) {
                        dialogueItself.close();
                    }
                }
            });

        }

        $scope.validateForm = function () {

            $scope.validationMessage = '';

            var MinHoursAfterCourseCreation = 1;
            var MinYearsOfPaymentData = 1;
            var MaxYearsOfPaymentData = 8;

            var MinDaysAfterArchiveClientEmail = 31;
            var MaxDaysAfterArchiveClientEmail = 400;
            
            var HoursAfterCourseCreation = parseInt($scope.systemConfiguration.HoursToEmailCourseVenuesAfterCreation);
            var YearsOfPaymentData = parseInt($scope.systemConfiguration.YearsOfPaymentData);

            var DaysAfterArchiveClientEmail = parseInt($scope.systemConfiguration.ArchiveClientEmailsAfterDays);
            
            if (angular.isNumber(HoursAfterCourseCreation) && !isNaN(HoursAfterCourseCreation)) {
                if (HoursAfterCourseCreation < MinHoursAfterCourseCreation) {
                    $scope.validationMessage = "Hours for Email Venues After Course Creation should be greater than " + MinHoursAfterCourseCreation;
                }
            }
            else {
                $scope.validationMessage = "Please enter a numeric value for Email Venues After Course Creation";
            }

            if (angular.isNumber(YearsOfPaymentData) && !isNaN(YearsOfPaymentData)) {
                if (YearsOfPaymentData < MinYearsOfPaymentData || YearsOfPaymentData > MaxYearsOfPaymentData) {
                    $scope.validationMessage = "Years of Payment Data should be between " + MinYearsOfPaymentData + " and " + MaxYearsOfPaymentData;
                }
            }
            else {
                $scope.validationMessage = "Please enter a numeric value for Years of Payment Data";
            }

            if (angular.isNumber(DaysAfterArchiveClientEmail) && !isNaN(DaysAfterArchiveClientEmail)) {
                if (DaysAfterArchiveClientEmail < MinDaysAfterArchiveClientEmail || DaysAfterArchiveClientEmail > MaxDaysAfterArchiveClientEmail) {
                    $scope.validationMessage = "Days After which Client Emails are Archived should be between " + MinDaysAfterArchiveClientEmail + " and " + MaxDaysAfterArchiveClientEmail;
                }
            }
            else {
                $scope.validationMessage = "Please enter a numeric value for Archive Client Emails After";
            }

            if ($scope.validationMessage == '') {
                return true;
            }
            else {
                return false;
            }
        }

        $scope.getOrganisations($scope.userId);
        $scope.getSystemConfigurationByOrganisation($scope.organisationId, $scope.organisationName);
        $scope.getPaymentProvidersByOrganisation($scope.organisationId)
        $scope.getPaymentProviders();
        $scope.checkSMSFunctionalityStatus($scope.organisationId);

    }

})();