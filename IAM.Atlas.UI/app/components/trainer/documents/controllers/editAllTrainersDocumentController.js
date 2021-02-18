(function () {
    'use strict';

    angular
        .module('app')
        .controller('editAllTrainersDocumentCtrl', editAllTrainersDocumentCtrl);

    editAllTrainersDocumentCtrl.$inject = ["$scope", "$timeout", "TrainerDocumentService", "UserService", "activeUserProfile"];

    function editAllTrainersDocumentCtrl($scope, $timeout, TrainerDocumentService, UserService, activeUserProfile) {
        
        $scope.document = {};

        $scope.saveDocument = function () {
            if($scope.document){
                TrainerDocumentService.updateTitleDescription($scope.document.Id, $scope.document.Title, $scope.document.Description, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if (response.data == true) {
                                $scope.$parent.getDocuments($scope.selectedOrganisationId);
                                $scope.successMessage = "Document saved.";
                            }
                            else {
                                $scope.errorMessage = "An error occured, document may not have been saved.";
                            }
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = "An error occured, document may not have been saved.";
                        }
                    );
            }
        }

        $scope.loadDocument = function () {
            if ($scope.selectedDocumentId) {
                TrainerDocumentService.get($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if (response.data) {
                                $scope.document = response.data;
                            }
                        },
                        function errorCallback(response) { }
                    );
            }
        }

        $scope.loadDocument();
    }
})();