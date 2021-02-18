(function () {

    'use strict';

    angular
        .module("app")
        .controller("OrganisationDashboardMeterCtrl", OrganisationDashboardMeterCtrl);

    OrganisationDashboardMeterCtrl.$inject = ["$scope", "activeUserProfile", "DashboardMeterService"];

    function OrganisationDashboardMeterCtrl($scope, activeUserProfile, DashboardMeterService) {


        /**
         * Selected Organisations
         */
        $scope.selected = [];

        /**
         * Available Organisations
         */
        $scope.available = [];

        

        /**
         * Get the selected info
         */
        $scope.getSelected = function () {

            DashboardMeterService.GetExposedOrganisations($scope.$parent.selectedMeter)
                .then(function (response) {
                    $scope.selected = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available organisations data");
                });

        };

        /**
         * Get the available info
         */
        $scope.getAvailable = function () {

           
            DashboardMeterService.GetAvailableOrganisations($scope.$parent.selectedMeter)
                .then(function (response) {
                    $scope.available = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available organisations data");
                });
        };

        /**
         * Call the methods to update the object
         */
        $scope.getAvailable();
        $scope.getSelected();

        /**
         * 
         */
        $scope.processDataMove = function (option, event, from, to) {

            var changes = {
                action: '',
                meterId: $scope.$parent.selectedMeter,
                organisationId : option.Id
            };

            ///**
            // * Dragging from the selected to the available
            // */
            if (to === "available" && from === "selected") {

                changes.action = 'remove';
          
            }

            /**
             * Dragging from the available to the selected
             */
            if (to === "selected" && from === "available") {

                changes.action = 'add';

            }

            /**
             * 
             */
            DashboardMeterService.updateDashboardMeterExposure(changes)
                .then(function (response) {

                    $scope.getAvailable();
                    $scope.getSelected();

                    /**
                     * Update the organisations
                     * On the dashboard meter exposure page
                     */
                    $scope.$parent.getExposedOrganisations();

                }, function(response) {
                    console.log(response);
                });


        }

    }

})();