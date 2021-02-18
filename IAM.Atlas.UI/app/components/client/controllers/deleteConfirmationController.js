(function () {
    'use strict';

    angular
        .module('app')
        .controller('deleteClientConfirmationCtrl', deleteClientConfirmationCtrl);

    deleteClientConfirmationCtrl.$inject = ["$scope", "ClientService", "activeUserProfile"];

    function deleteClientConfirmationCtrl($scope, ClientService, activeUserProfile) {

        $scope.clientDelete = {};
        $scope.clientDelete.deleteNotes = "";
        $scope.clientDelete.id = 0;
        $scope.clientDelete.userId = 0;

        if (angular.isDefined($scope.$parent.clientDeleteDetail))
        {
            $scope.clientName = $scope.$parent.clientDeleteDetail.clientName;
            $scope.clientDelete.id = $scope.$parent.clientDeleteDetail.clientId;
        }
        else if (angular.isDefined($scope.$parent.client))
        {
            $scope.clientName = $scope.$parent.client.DisplayName;
            $scope.clientDelete.id = $scope.$parent.clientId;
        }
        
        $scope.clientService = ClientService;
        $scope.hideSuccessMessage = true;
        $scope.hideErrorMessage = true;

        $scope.closeModal = function () {
            $('button.close').last().trigger('click');
        }


        $scope.confirmDelete = function () {
            $scope.clientDelete.userId = activeUserProfile.UserId;
            //$scope.clientDelete.id = $scope.$parent.client.Id;
            $scope.clientService.deleteClient($scope.clientDelete).then
            (
                function successFunction(response) {
                    if (response.data) {
                        if (response.data == "success") {
                            $scope.completedMessage = "Delete Successful";
                            $scope.hideSuccessMessage = false;
                            $scope.closeModal();
                            if (angular.isDefined($scope.$parent.loadClientDetails)) {
                                $scope.$parent.loadClientDetails($scope.clientDelete.id);
                            }
                            $scope.$parent.successMessage = "Client successfully marked for deletion";
                            if (angular.isDefined($scope.$parent.loadClientDetails)) {
                                $scope.$parent.loadClientDetails($scope.clientDelete.id);
                            }
                            $scope.$parent.client.showDeletionRow = true;
                        }
                        else {
                            $scope.errorMessage = "Delete Failed";
                            $scope.hideErrorMessage = false;
                        }
                    }
                }
                ,
                function failedFunction() {
                    $scope.errorMessage = "Delete Failed";
                    $scope.hideErrorMessage = false;
                }
            );
        }
    }
})();