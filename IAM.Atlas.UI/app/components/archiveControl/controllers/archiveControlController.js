(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('ArchiveControlCtrl', ArchiveControlCtrl);

    ArchiveControlCtrl.$inject = ['$scope', '$location', '$window', '$http', '$filter', 'UserService', 'activeUserProfile', 'ArchiveControlService'];

    function ArchiveControlCtrl($scope, $location, $window, $http, $filter, UserService, activeUserProfile, ArchiveControlService) {

        $scope.archiveControlService = ArchiveControlService;
        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.archiveControl = {};
        $scope.organisationArchiveControl = {};

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
        $scope.getOrganisations = function (userId) {

            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get ArchiveControl Settings
        $scope.getArchiveControl = function () {

            $scope.archiveControlService.Get()
                .then(
                    function (data) {

                        $scope.archiveControl = data;
                        $scope.formatArchiveControl();

                    },
                    function (data) {
                        console.log("Error");
                        console.log(data);
                    }
                );
        }

       

        //Get OrganisationArchiveControlSettings
        $scope.getOrganisationArchiveControl = function (OrganisationId) {

            $scope.successMessage = "";
            $scope.validationMessage = "";

            $scope.archiveControlService.GetArchiveSettingsByOrganisation(OrganisationId)
                .then(
                    function (data) {
                      
                        $scope.organisationArchiveControl = data;
                        $scope.formatOrganisationArchiveControl();

                    },
                    function (data) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Save ArchiveControl Settings
        $scope.saveArchiveControl = function () {

            if ($scope.validateArchiveControl()) {

                $scope.archiveControlService.Save($scope.archiveControl)
                    .then(
                        function (data) {
                           
                            $scope.getArchiveControl();

                            $scope.successMessage = "Save Successful";
                            $scope.validationMessage = "";

                            
                        },
                        function (data) {
                           
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred please try again.";
                        }
                    );
            }
        }

        //Save ArchiveControl Settings
        $scope.saveOrganisationArchiveControl = function () {

            if ($scope.validateOrganisationArchiveControl()) {

                $scope.archiveControlService.SaveArchiveSettingsByOrganisation($scope.organisationArchiveControl)
                    .then(
                        function (data) {
                            
                            $scope.getOrganisationArchiveControl($scope.organisationId);

                            $scope.successMessage = "Save Successful";
                            $scope.validationMessage = "";

                            
                        },
                        function (data) {
                            
                            $scope.successMessage = "";
                            $scope.validationMessage = "An error occurred please try again.";
                        }
                    );
            }
        }



        $scope.formatArchiveControl = function () {

            $scope.archiveControl.ArchiveEmailsAfterDaysDefault = $filter('number')($scope.archiveControl.ArchiveEmailsAfterDaysDefault, 0);
            $scope.archiveControl.ArchiveSMSsAfterDaysDefault = $filter('number')($scope.archiveControl.ArchiveSMSsAfterDaysDefault, 0);
            $scope.archiveControl.DeleteEmailsAfterDaysDefault = $filter('number')($scope.archiveControl.DeleteEmailsAfterDaysDefault, 0);
            $scope.archiveControl.DeleteSMSsAfterDaysDefault = $filter('number')($scope.archiveControl.DeleteSMSsAfterDaysDefault, 0);

            return true;
        }

        $scope.formatOrganisationArchiveControl = function () {

            $scope.organisationArchiveControl.ArchiveEmailsAfterDays = $filter('number')($scope.organisationArchiveControl.ArchiveEmailsAfterDays, 0);
            $scope.organisationArchiveControl.ArchiveSMSsAfterDays = $filter('number')($scope.organisationArchiveControl.ArchiveSMSsAfterDays, 0);
            $scope.organisationArchiveControl.DeleteEmailsAfterDays = $filter('number')($scope.organisationArchiveControl.DeleteEmailsAfterDays, 0);
            $scope.organisationArchiveControl.DeleteSMSsAfterDays = $filter('number')($scope.organisationArchiveControl.DeleteSMSsAfterDays, 0);

            return true;
        }

        $scope.validateArchiveControl = function () {

            if ($scope.archiveControl.ArchiveEmailsAfterDaysDefault == "") {
                $scope.archiveControl.ArchiveEmailsAfterDaysDefault = "0";
            }
            else {
                $scope.archiveControl.ArchiveEmailsAfterDaysDefault = $scope.archiveControl.ArchiveEmailsAfterDaysDefault.replace(',', '');
            }

            if ($scope.archiveControl.ArchiveSMSsAfterDaysDefault == "") {
                $scope.archiveControl.ArchiveSMSsAfterDaysDefault = "0";
            }
            else {
                $scope.archiveControl.ArchiveSMSsAfterDaysDefault = $scope.archiveControl.ArchiveSMSsAfterDaysDefault.replace(',', '');
            }

            if ($scope.archiveControl.DeleteEmailsAfterDaysDefault == "") {
                $scope.archiveControl.DeleteEmailsAfterDaysDefault = "0";
            }
            else {
                $scope.archiveControl.DeleteEmailsAfterDaysDefault = $scope.archiveControl.DeleteEmailsAfterDaysDefault.replace(',', '');
            }

            if ($scope.archiveControl.DeleteSMSsAfterDaysDefault == "") {
                $scope.archiveControl.DeleteSMSsAfterDaysDefault = "0";
            }
            else {
                $scope.archiveControl.DeleteSMSsAfterDaysDefault = $scope.archiveControl.DeleteSMSsAfterDaysDefault.replace(',', '');
            }

            return true;
        }

        $scope.validateOrganisationArchiveControl = function () {

            if ($scope.organisationArchiveControl.ArchiveEmailsAfterDays == "") {
                $scope.organisationArchiveControl.ArchiveEmailsAfterDays = "0";
            }
            else {
                $scope.organisationArchiveControl.ArchiveEmailsAfterDays = $scope.organisationArchiveControl.ArchiveEmailsAfterDays.replace(',', '');
            }

            if ($scope.organisationArchiveControl.ArchiveSMSsAfterDays == "") {
                $scope.organisationArchiveControl.ArchiveSMSsAfterDays = "0";
            }
            else {
                $scope.organisationArchiveControl.ArchiveSMSsAfterDays = $scope.organisationArchiveControl.ArchiveSMSsAfterDays.replace(',', '');
            }

            if ($scope.organisationArchiveControl.DeleteEmailsAfterDays == "") {
                $scope.organisationArchiveControl.DeleteEmailsAfterDays = "0";
            }
            else {
                $scope.organisationArchiveControl.DeleteEmailsAfterDays = $scope.organisationArchiveControl.DeleteEmailsAfterDays.replace(',', '');
            }

            if ($scope.organisationArchiveControl.DeleteSMSsAfterDays == "") {
                $scope.organisationArchiveControl.DeleteSMSsAfterDays = "0";
            }
            else {
                $scope.organisationArchiveControl.DeleteSMSsAfterDays = $scope.organisationArchiveControl.DeleteSMSsAfterDays.replace(',', '');
            }

            return true;
        }

        $scope.getOrganisations($scope.userId);
        $scope.getArchiveControl();
        $scope.getOrganisationArchiveControl($scope.organisationId);
        
    }

})();