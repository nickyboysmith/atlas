(function () {

    'use strict';

    angular
        .module("app")
        .controller("RelateTaskToClientCtrl", RelateTaskToClientCtrl);

    RelateTaskToClientCtrl.$inject =["$scope", "$filter", "activeUserProfile", "DateFactory", "TaskService", "ClientService"];

    function RelateTaskToClientCtrl($scope, $filter, activeUserProfile, DateFactory, TaskService, ClientService) {

        $scope.taskClients = [];
        $scope.taskClientsTemplate = [];
        $scope.selectedClientId = -1;
        $scope.maxResults = 10;
        $scope.selectedTaskId = -1;
        $scope.selectedTaskTitle = "";

        $scope.getTaskClients = function () {
            ClientService.GetByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function successCallback(response) {
                        $scope.taskClients = response.data;
                        $scope.taskClientsTemplate = $scope.taskClients;
                    },
                    function errorCallback(response) {
                        $scope.validationMessage = "An error occurred, please try again.";
                    }
                );
        }

        $scope.selectClient = function (clientId) {
            $scope.selectedClientId = clientId;
        }

        $scope.linkTaskToClient = function (clientId) {
            if ($scope.setClientId) {
                var selectedClients = $filter('filter')($scope.taskClients, { Id: clientId});
                if (selectedClients.length > 0) {
                    var label = selectedClients[0].DisplayName;
                    if(selectedClients[0].DateOfBirth){
                        label = label + " (" + DateFactory.formatDateSlashes(new Date(selectedClients[0].DateOfBirth)) + ")";
                    }
                    $scope.setClientId(clientId, label);
                    // close this modal
                    $('button.close').last().trigger('click');
                }
                else {
                    $scope.validationMessage = "Error: Couldn't assign Task to Client.";
                }
            }
        }

        if ($scope.$parent.selectedTaskTitle) {
            $scope.selectedTaskTitle = $scope.$parent.selectedTaskTitle;
        }

        if ($scope.$parent.selectedTaskId) {
            $scope.selectedTaskId = $scope.$parent.selectedTaskId;
        }

        $scope.getTaskClients();
    };


})();