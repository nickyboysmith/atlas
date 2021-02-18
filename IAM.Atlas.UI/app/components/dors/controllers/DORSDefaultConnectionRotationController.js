(function () {

    'use strict';

    angular
        .module("app")
        .controller("DORSDefaultConnectionRotationCtrl", DORSDefaultConnectionRotationCtrl);

    DORSDefaultConnectionRotationCtrl.$inject = ["$scope", "DorsConnectionService", "activeUserProfile"];

    function DORSDefaultConnectionRotationCtrl($scope, DorsConnectionService, activeUserProfile) {

        /**
         * 
         */
        $scope.selected = [];

        /**
         * 
         */
        $scope.available = [];


        /**
         * Set the user Id
         */
        $scope.userId = activeUserProfile.UserId;

        /**
         * Get the selected info
         */
        $scope.getSelected = function () {

            DorsConnectionService.GetSelectedForDefaultRotation(activeUserProfile.UserId)
                .then(function (response) {
                    $scope.selected = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of slected data");
                });
        };

        /**
         * Get the available info
         */
        $scope.getAvailable = function () {

            /**
             * For now set the org id as the first in the array 
             */
            DorsConnectionService.GetAvailableForDefaultRotation(activeUserProfile.UserId)
                .then(function (response) {
                    $scope.available = response.data;
                }, function(response) {
                    console.log("There has been an error retrieving the list of available courses data");
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

            /**
             * Dragging from selected to available
             */
            if (to === "available" && from === "selected") {
                DorsConnectionService.DeselectFromDefaultRotation(option.Id, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            $scope.getAvailable();
                            $scope.getSelected();
                        },
                        function errorCallback(response) {

                        }
                    );
            }

            /**
             * Dragging from available to selected
             */
            if (to === "selected" && from === "available") {
                DorsConnectionService.SelectForDefaultRotation(option.Id, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            $scope.getAvailable();
                            $scope.getSelected();
                        },
                        function errorCallback(response) {

                        }
                    );
            }
        }
    }

})();