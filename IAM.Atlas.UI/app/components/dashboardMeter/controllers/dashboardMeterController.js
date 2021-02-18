(function () {
    'use strict';


    angular
       .module('app')
       .controller('DashboardMeterCtrl', DashboardMeterCtrl);

    DashboardMeterCtrl.$inject = ['$scope', '$timeout', '$location', '$window', '$http', 'DashboardMeterService', 'UserService', 'ModalService', 'activeUserProfile']


    function DashboardMeterCtrl($scope, $timeout, $location, $window, $http, DashboardMeterService, UserService, ModalService, activeUserProfile) {

        $scope.dashboardMeterService = DashboardMeterService;
        $scope.userService = UserService;
        
        $scope.dashboardMeters = {}; 
        $scope.dashboardMeterDetails = {};
        $scope.exposedOrganisations = {};
        $scope.selectedMeter = null;

        $scope.userId = activeUserProfile.UserId;

        $scope.userService.checkSystemAdminUser($scope.userId)
                    .then(
                        function (data) {
                            $scope.isAdmin = data;
                        },
                        function (data) {
                            $scope.isAdmin = false;
                        }
                    );

        $scope.getDashboardMeters = function () {

            $scope.dashboardMeterService.Get()
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.dashboardMeters = response.data;

                        if ($scope.dashboardMeters.length > 0) {
                            $scope.selectMeterDetails($scope.dashboardMeters[0].Id)
                        }
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );

        }

        $scope.selectMeterDetails = function (selectedMeter) {

            $scope.selectedMeter = selectedMeter;

            $scope.dashboardMeterService.GetMeterDetails($scope.selectedMeter)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.dashboardMeterDetails = response.data[0];

                        $scope.getExposedOrganisations();

                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                    }
                );


        }


        $scope.save = function () {

            $scope.dashboardMeterService.Save($scope.dashboardMeterDetails)
                .then(
                    function (response) {
                        console.log("Success");
                        console.log(response.data);
                        $scope.successMessage = "Save Sucessful";
                        $scope.validationMessage = "";
                    },
                    function (response) {
                        console.log("Error");
                        console.log(response);
                        $scope.successMessage = "";
                        $scope.validationMessage = "An error occurred please try again.";
                    }
                );
        }

        /**
         * Get the exposed organisations
         */
        $scope.getExposedOrganisations = function () {

            DashboardMeterService.GetExposedOrganisations($scope.selectedMeter)
                .then(function (response) {
                    $scope.exposedOrganisations = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available organisations data");
                });

        };

        /**
         * Open the edit exposed organisations modal
         */
        $scope.openOrganisationExposureModal = function () {
            ModalService.displayModal({
                scope: $scope,
                title: "Meter Organisation Exposure",
                closable: true,
                filePath: "/app/components/dashboardMeter/add.html",
                controllerName: "OrganisationDashboardMeterCtrl",
                cssClass: "OrganisationDashboardMeterModal",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        };

        $scope.getDashboardMeters();
    }
})();


