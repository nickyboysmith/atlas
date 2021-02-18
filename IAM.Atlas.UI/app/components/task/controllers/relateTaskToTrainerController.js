(function () {

    'use strict';

    angular
        .module("app")
        .controller("RelateTaskToTrainerCtrl", RelateTaskToTrainerCtrl);

    RelateTaskToTrainerCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "DateFactory", "TaskService", "TrainerService"];

    function RelateTaskToTrainerCtrl($scope, $filter, activeUserProfile, DateFactory, TaskService, TrainerService) {

        $scope.taskTrainers = [];
        $scope.taskTrainersTemplate = [];
        $scope.selectedTrainerId = -1;
        $scope.maxResults = 10;
        $scope.selectedTaskId = -1;
        $scope.selectedTaskTitle = "";

        $scope.getTaskTrainers = function () {
            TrainerService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.taskTrainers = response.data;
                        $scope.taskTrainersTemplate = $scope.taskTrainers;
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = "An error occurred, please try again.";
                    }
                );
        }

        $scope.selectTrainer = function (trainerId) {
            $scope.selectedTrainerId = trainerId;
        }

        $scope.linkTaskToTrainer = function (trainerId) {
            if ($scope.setTrainerId) {
                var selectedTrainers = $filter('filter')($scope.taskTrainers, { Id: trainerId });
                if (selectedTrainers.length > 0) {
                    var label = selectedTrainers[0].DisplayName;
                    if (selectedTrainers[0].DateTime) {
                        label = label + " (" + selectedTrainers[0].DateTime + ")"
                    }
                    $scope.setTrainerId(trainerId, selectedTrainers[0].DisplayName);
                    // close this modal
                    $('button.close').last().trigger('click');
                }
                else {
                    $scope.validationMessage = "Error: Couldn't assign Task to Trainer.";
                }
            }
        }

        if ($scope.$parent.selectedTaskTitle) {
            $scope.selectedTaskTitle = $scope.$parent.selectedTaskTitle;
        }

        if ($scope.$parent.selectedTaskId) {
            $scope.selectedTaskId = $scope.$parent.selectedTaskId;
        }

        $scope.getTaskTrainers();
    };


})();