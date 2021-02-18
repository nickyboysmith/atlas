(function () {

    'use strict';
    
    angular
        .module('app.controllers')
        .controller('DORSControlSettingsCtrl', DORSControlSettingsCtrl);

    DORSControlSettingsCtrl.$inject = ['$scope', '$location', '$window', '$http', 'UserService', 'activeUserProfile', "dorsControlSettingsService", "OrganisationSystemConfigurationService"];

    function DORSControlSettingsCtrl($scope, $location, $window, $http, UserService, activeUserProfile, dorsControlSettingsService, OrganisationSystemConfigurationService) {

        $scope.dorsControlSettingsService = dorsControlSettingsService;
        $scope.organisationSystemConfigurationService = OrganisationSystemConfigurationService;

        $scope.userId = activeUserProfile.UserId;
        $scope.userService = UserService;

        $scope.dorsControl = {};
        $scope.systemConfiguration = {};
        $scope.organisations = {};

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

            $scope.organisationSystemConfigurationService.getMainOrganisations()
            .then(function (response) {
                $scope.organisations = response.data;
                if ($scope.organisations.length < 2) {
                    $scope.organisationId = $scope.organisations[0].id;
                }
            }, function (data) {
               console.log("Can't get Organisations");
           });
        }

        //Get dorsControl Settings
        $scope.getDORSControl = function () {

            $scope.dorsControlSettingsService.Get()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.dorsControl = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Get System Configuration Settings
        $scope.getSystemConfigurationByOrganisation = function (OrganisationId) {

            $scope.organisationSystemConfigurationService.GetByOrganisation(OrganisationId)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.systemConfiguration = response.data;
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );
        }

        //Save dorsControl Settings
        $scope.saveDORSControl = function () {

                if ($scope.isAdmin == true) {

                    if ($scope.dorsControl) {

                        $scope.dorsControlSettingsService.Save($scope.dorsControl)
                            .then(
                                function (response) {
                                    console.log("Success");
                                    console.log(response.data);

                                    $scope.dorssuccessMessage = "Save Successful";
                                    $scope.dorsvalidationMessage = "";
                                    $scope.successMessage = "";
                                    $scope.validationMessage = "";
                                },
                                function (response) {
                                    console.log("Error");
                                    console.log(response);
                                    $scope.dorssuccessMessage = "";
                                    $scope.dorsvalidationMessage = "An error occurred please try again.";
                                    $scope.successMessage = "";
                                    $scope.validationMessage = "";
                                }
                            );
                    }
                    else {
                        $scope.dorssuccessMessage = "";
                        $scope.dorsvalidationMessage = "DORS Control Settings is empty.";
                        $scope.successMessage = "";
                        $scope.validationMessage = "";
                    }
                }
                else {
                    $scope.dorssuccessMessage = "";
                    $scope.dorsvalidationMessage = "User is not an Admin";
                    $scope.successMessage = "";
                    $scope.validationMessage = "";
            }
        }

        $scope.saveSystemConfig = function () {

            if ($scope.isAdmin == true) {

                if ($scope.systemConfiguration)
                {

                    $scope.systemConfiguration.UpdatedByUserId = $scope.userId;

                    $scope.organisationSystemConfigurationService.saveSettings($scope.systemConfiguration)
                        .then(
                            function (response) {
                                console.log("Success");
                                console.log(response.data);

                                $scope.successMessage = "Save Successful";
                                $scope.validationMessage = "";
                                $scope.dorssuccessMessage = "";
                                $scope.dorsvalidationMessage = "";
                            },
                            function (response) {
                                console.log("Error");
                                console.log(response);
                                $scope.successMessage = "";
                                $scope.validationMessage = "An error occurred please try again.";
                                $scope.dorssuccessMessage = "";
                                $scope.dorsvalidationMessage = "";
                            }
                        );
                }
                else
                {
                    $scope.successMessage = "";
                    $scope.validationMessage = "A Configuration does not exist for this Organisation";
                    $scope.dorssuccessMessage = "";
                    $scope.dorsvalidationMessage = "";
                }
            }
            else {
                $scope.successMessage = "";
                $scope.validationMessage = "User is not an Admin";
                $scope.dorssuccessMessage = "";
                $scope.dorsvalidationMessage = "";
            }
        }


        $scope.getDORSControl();
        $scope.getOrganisations($scope.userId);
        $scope.getSystemConfigurationByOrganisation($scope.organisationId);

    }

})();