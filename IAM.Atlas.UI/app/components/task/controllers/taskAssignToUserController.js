(function () {

    'use strict';

    angular
        .module("app")
        .controller("TaskAssignToUserCtrl", TaskAssignToUserCtrl);

    TaskAssignToUserCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "DateFactory", "TaskService", "UserService"];

    function TaskAssignToUserCtrl($scope, $filter, activeUserProfile, DateFactory, TaskService, UserService) {

        $scope.taskUsers = [];
        $scope.taskUsersTemplate = [];
        $scope.selectedUserId = -1;
        $scope.maxResults = 10;
        $scope.selectedTaskId = -1;
        $scope.selectedTaskTitle = "";

        $scope.getTaskUsers = function () {
            UserService.GetOrganisationUsers(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (data) {
                        //$scope.taskUsers = $filter('filter')(data, { Id: '!' + activeUserProfile.UserId });
                        $scope.taskUsers = data;
                        $scope.taskUsersTemplate = $scope.taskUsers;
                    },
                    function (data) {
                        $scope.validationMessage = "An error occurred, please try again.";
                    }
                );
        }

        $scope.selectUser = function (userId) {
            $scope.selectedUserId = userId;
        }

        $scope.assignTaskToUser = function (taskId, userId) {
            TaskService.AssignTaskToUser(taskId, userId, activeUserProfile.UserId)
                .then(
                    function successCallback(response) {
                        if (response.data == true) {
                            $scope.validationMessage = "User assigned task successfully.";
                            if ($scope.$parent.getTasks) {
                                $scope.$parent.getTasks();
                            }
                        }
                        else {
                            $scope.validationMessage = "An error occurred, please try again.";
                        }
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = response.data.ExceptionMessage;
                    }
                );
        }

        if ($scope.$parent.selectedTaskTitle) {
            $scope.selectedTaskTitle = $scope.$parent.selectedTaskTitle;
        }

        if ($scope.$parent.selectedTaskId) {
            $scope.selectedTaskId = $scope.$parent.selectedTaskId;
        }

        $scope.getTaskUsers();
    };


})();