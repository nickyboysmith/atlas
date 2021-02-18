(function () {

    'use strict';

    angular
        .module("app")
        .controller("AddTaskSelectUserCtrl", AddTaskSelectUserCtrl);

    AddTaskSelectUserCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "DateFactory", "TaskService", "UserService"];

    function AddTaskSelectUserCtrl($scope, $filter, activeUserProfile, DateFactory, TaskService, UserService) {

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

        $scope.assignTaskToUser = function (userId) {
            if ($scope.setUserId) {
                var selectedUsers = $filter('filter')($scope.taskUsers, { Id: userId });
                if (selectedUsers.length > 0) {
                    $scope.setUserId(userId, selectedUsers[0].Name);
                    // close this modal
                    $('button.close').last().trigger('click');
                }
                else {
                    $scope.validationMessage = "Error: Couldn't assign Task to user.";
                }
            }
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