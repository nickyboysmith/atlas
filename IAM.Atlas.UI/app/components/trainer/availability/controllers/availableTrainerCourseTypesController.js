(function () {

    'use strict';

    angular
        .module("app")
        .controller("AvailableTrainerCourseTypesCtrl", AvailableTrainerCourseTypesCtrl);

    AvailableTrainerCourseTypesCtrl.$inject = ["$scope", "activeUserProfile", "TrainerAvailabiltyService", "CourseTrainerFactory"];

    function AvailableTrainerCourseTypesCtrl($scope, activeUserProfile, TrainerAvailabiltyService, CourseTrainerFactory) {


        /**
         * Selected Trainers
         */
        $scope.selected = [];

        /**
         * Available Trainers
         */
        $scope.available = [];

        /**
         * Set the trainer id
         */
        if ($scope.$parent.replaceTrainerId !== undefined) {
            $scope.trainerId = $scope.$parent.replaceTrainerId;
        } else {
            $scope.trainerId = activeUserProfile.TrainerId;
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

            TrainerAvailabiltyService.getCourseTypes($scope.trainerId, $scope.organisationId)
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
            TrainerAvailabiltyService.getAvailableCourseTypes($scope.organisationId, $scope.trainerId)
                .then(function (response) {
                    $scope.available = response;
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

            var newObject = {};
            var dataOptionObject = {
                trainerId: $scope.trainerId,
                courseTypeName: option.Name
            };
            
            /**
             * Find the index on the object
             * By the option ID
             */
            var objectID = CourseTrainerFactory.find($scope[from], option.Id);

            /**
             * Check to see if the option ID 
             * Exists in the object that it's being moved to
             */
            var existsInObject = CourseTrainerFactory.find($scope[to], option.Id);

            /**
             * Dragging from the selected to the available
             */
            if (to === "available" && from === "selected") {
                newObject = angular.extend(dataOptionObject, {
                    action: "remove",
                    courseTypeId: option.Id,
                    userId: $scope.userId
                });
            }

            /**
             * Dragging from the available to the selected
             */
            if (to === "selected" && from === "available") {
                newObject = angular.extend(dataOptionObject, {
                    action: "add",
                    courseTypeId: option.Id
                });
            }

            /**
             * 
             */
            TrainerAvailabiltyService.updateTrainerCourseTypes(newObject)
                .then(function (response) {

                    $scope.getAvailable();
                    $scope.getSelected();

                    /**
                     * Update the $parent coursetypes
                     * On the trainer availability page
                     */
                    $scope.$parent.getTheAvailableCourseTypes();

                }, function(response) {
                    console.log(response);
                });


        }

    }

})();