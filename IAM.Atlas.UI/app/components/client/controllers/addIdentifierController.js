(function () {
    'use strict';

    angular
        .module('app')
        .controller('addIdentifierCtrl', addIdentifierCtrl);

    addIdentifierCtrl.$inject = ["$scope", "ClientService", "activeUserProfile"];

    function addIdentifierCtrl($scope, ClientService, activeUserProfile) {

        $scope.legacyClient = {};
        $scope.hideSaveButton = false;
        $scope.clientService = ClientService;

        $scope.closeModal = function () {
            $('button.close').last().trigger('click');
        }


        $scope.populateClientData = function () {
            if ($scope.$parent.client) {
                $scope.legacyClient.Id = $scope.$parent.client.Id;
                $scope.legacyClient.DisplayName = $scope.$parent.client.DisplayName;
                if ($scope.$parent.client.ClientPreviousIds.length > 0) {
                    $scope.legacyClient.PreviousSystemId = $scope.$parent.client.ClientPreviousIds[$scope.$parent.client.ClientPreviousIds.length - 1].PreviousClientId;
                }
                if ($scope.$parent.client.ClientUniqueIdentifier.length > 0) {
                    $scope.legacyClient.IdentifierMessage = $scope.$parent.client.ClientUniqueIdentifier[$scope.$parent.client.ClientUniqueIdentifier.length - 1].UniqueIdentifier;
                }
                $scope.legacyClient.Identifier = "";
            }
        }

        $scope.saveIdentifier = function () {
            $scope.legacyClient.UserId = activeUserProfile.UserId;
            $scope.clientService.saveUniqueIdentifier($scope.legacyClient).then
            (
                function successFunction(response) {
                    if (response.data) {
                        if (response.data == "success") {
                            $scope.completedMessage = "Save Successful";
                            $scope.hideSuccessMessage = false;
                            $scope.legacyClient.IdentifierMessage = "Unique Client Identifer Assigned";
                            $scope.$parent.loadClientDetails($scope.legacyClient.Id);
                        }
                        else {
                            if (response.data == "failed-notunique")
                                $scope.errorMessage = "Save Failed: Identifier is already in use";
                            $scope.hideErrorMessage = false;
                        }
                    }
                }
                ,
                function failedFunction() {
                    $scope.errorMessage = "Save Failed";
                    $scope.hideErrorMessage = false;
                }
            );
        }

        $scope.populateClientData();
    }
})();