(function () {

    'use strict';

    angular
        .module("app")
        .controller("MeterUsersCtrl", MeterUsersCtrl);

    MeterUsersCtrl.$inject = ["$scope", "activeUserProfile", "DashBoardMeterService", "UserDashBoardMeterFactory"];

    function MeterUsersCtrl($scope, activeUserProfile, DashBoardMeterService, UserDashBoardMeterFactory) {


        /**
         * Selected Users
         */
        $scope.selected = [];

        /**
         * Available Users
         */
        $scope.available = [];

        /**
         * Set the user id
         */
        if ($scope.$parent.selectedMeter.Id !== undefined) {
            $scope.meterId = $scope.$parent.selectedMeter.Id;
        }

        /**
         * Set the organisation Id
         */
        if ($scope.$parent.replaceOrganisationId !== undefined) {
            $scope.organisationId = $scope.$parent.replaceOrganisationId;
        } else {
            $scope.organisationId = activeUserProfile.selectedOrganisation.Id;
        }

        /**
         * Set the user Id
         */
        $scope.userId = activeUserProfile.UserId;

        /**
         * Get the selected info
         */
        $scope.getSelected = function () {

            DashBoardMeterService.getSelectedUsers($scope.meterId, $scope.organisationId)
                .then(function (response) {
                    $scope.selected = response;
                }, function(response) {
                    console.log("There has been an error retrieving the list of selected data");
                });

        };

        /**
         * Get the available info
         */
        $scope.getAvailable = function () {

            /**
             * For now set the org id as the first in the array 
             */
            DashBoardMeterService.getAvailableUsers($scope.meterId, $scope.organisationId)
                .then(function (response) {
                    $scope.available = response;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available users data");
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

            var newObject = {};
            var dataOptionObject = {
                userId: $scope.userId
            };
            
            /**
             * Find the index on the object
             * By the option ID
             */
            var objectID = UserDashBoardMeterFactory.find($scope[from], option.Id);

            /**
             * Check to see if the option ID 
             * Exists in the object that it's being moved to
             */
            var existsInObject = UserDashBoardMeterFactory.find($scope[to], option.Id);

            /**
             * Dragging from bthe selected to the available
             */
            if (to === "available" && from === "selected") {
                newObject = angular.extend(dataOptionObject, {
                    action: "remove",
                    userId: option.Id,
                    meterId: $scope.meterId,
                    organisationId: $scope.organisationId
                });
            }

            /**
             * Dragging from the available to the selected
             */
            if (to === "selected" && from === "available") {
                newObject = angular.extend(dataOptionObject, {
                    action: "add",
                    userId: option.Id,
                    meterId: $scope.meterId,
                    organisationId: $scope.organisationId
                });
            }

            /**
             * 
             */
            DashBoardMeterService.updateMeterUsers(newObject)
                .then(function (response) {

                    $scope.getAvailable();
                    $scope.getSelected();

                    /**
                     * Update the $parent users
                     * On the meter availability page
                     */
                    $scope.$parent.getTheAvailableUsers();

                }, function(response) {
                    console.log(response);
                });


        }

    }

})();