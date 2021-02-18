(function () {

    'use strict';

    angular
        .module('app.controllers')
        .controller('SystemTaskCtrl', SystemTaskCtrl);

    SystemTaskCtrl.$inject = ["$scope", "$http", "$window", "SystemTaskService", "UserService", "activeUserProfile"];

    function SystemTaskCtrl($scope, $http, $window, SystemTaskService, UserService, activeUserProfile) {
        
        $scope.userId = activeUserProfile.UserId;
        $scope.organisations = {};
        $scope.systemTasks = {};
        $scope.systemTaskDetail = {};
        $scope.selectedOrganisationId = -1;
        $scope.selectedSystemTaskId = -1;

        $scope.systemTaskService = SystemTaskService;
        $scope.userService = UserService;
        
        $scope.isAdminUser = false;

        $scope.userService.checkSystemAdminUser($scope.userId).then(function (response) {
            $scope.isAdminUser = JSON.parse(response);
        });  

        $scope.loadOrganisations = function (userId) {
            $scope.userService.getOrganisationIds(userId)
                .then(function (data, status, headers, config) {
                    $scope.organisations = data;

                    if ($scope.organisations.length > 0) {
                        $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
                        $scope.showSystemTasks($scope.selectedOrganisationId);
                    }
                }, function(data, status, headers, config) {
                    alert('Error retrieving client list');
                });
        }

        $scope.showSystemTasks = function (selectedOrganisationId) {

            $scope.errorMessage = "";
            $scope.statusMessage = "";
            
            $scope.selectedOrganisationId = selectedOrganisationId;
            $scope.systemTaskService.showSystemTasks(selectedOrganisationId, $scope.userId)
                .then(function (data) {

                    $scope.systemTasks = data;

                    if ($scope.systemTasks.length > 0) {
                        $scope.loadSystemTaskDetail($scope.systemTasks[0].Id)
                    }
                    else {
                        $scope.selectedSystemTaskId = 0;
                    }
                   

                }, function(data, status, headers, config) {
                    alert('Error retrieving system tasks list');
                });
        }

        $scope.loadOrganisations($scope.userId);
        
        $scope.loadSystemTaskDetail = function (systemTaskId)
        {
            $scope.validationMessage = "";
            $scope.successMessage = "";

            
            $scope.selectedSystemTaskId = systemTaskId;
            // TODO: optimise with a filter
            if ($scope.systemTasks != {})
            {
                for (var i = 0; i < $scope.systemTasks.length; i++)
                {
                    if ($scope.systemTasks[i].Id == systemTaskId)
                    {
                        $scope.systemTaskDetail = $scope.systemTasks[i];
                        break;
                    }
                }
            }
        }

        $scope.saveSystemTask = function () {
            if ($scope.systemTaskDetail.SendMessagesViaEmail == false && $scope.systemTaskDetail.SendMessagesViaInternalMessaging == false) {

                $scope.validationMessage = "Save Failed. Either " + $scope.systemTaskDetail.EmailOptionCaption + " or " + $scope.systemTaskDetail.InternalMessageOptionCaption + " must be enabled.";
                $scope.successMessage = "";

            } else {
                $scope.systemTaskDetail.UserId = $scope.userId;
                $scope.systemTaskService.saveSystemTask($scope.systemTaskDetail)
                        .then(function (data) {
                            $scope.validationMessage = "";
                            $scope.successMessage = "Save Successful.";
                        }, function (data, status, headers, config) {

                            $scope.successMessage = "";
                            $scope.validationMessage = "Save Failed. Please try again. Please contact an administrator if the problem persists.";
                        });                
            }
        }        
    }
})();