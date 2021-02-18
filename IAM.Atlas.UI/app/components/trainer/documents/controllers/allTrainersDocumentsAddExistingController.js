(function () {
    'use strict';

    angular
        .module('app')
        .controller('allTrainersDocumentsAddExistingCtrl', allTrainersDocumentsAddExistingCtrl);

    allTrainersDocumentsAddExistingCtrl.$inject = ["$scope", "$timeout", "TrainerDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function allTrainersDocumentsAddExistingCtrl($scope, $timeout, TrainerDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.selectedOrganisationId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getExistingDocuments = function (organisationId) {
            if(organisationId){
                return TrainerDocumentService.getNonAllTrainerDocumentsByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.documents = response.data;
                        $scope.displayDocuments = $scope.documents;
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "Error loading document list: " + response.data.Message;
                    }
                );
            }
        }

        $scope.selectDocument = function (documentId) {
            $scope.selectedExistingDocumentId = documentId;
            $scope.successMessage = "";
        }

        $scope.selectExistingDocument = function () {
            TrainerDocumentService.AddExistingDocumentToAllTrainers($scope.selectedExistingDocumentId, activeUserProfile.UserId, $scope.selectedExistingDocumentOrganisationId)
                .then(
                    function successCallback(response) {
                        if(response.data == false){
                            $scope.errorMessage = "An error occurred, document may not be added to All Trainers.";
                        }
                        $scope.getExistingDocuments($scope.selectedExistingDocumentOrganisationId);
                        $scope.$parent.getDocuments($scope.selectedExistingDocumentOrganisationId);
                        $scope.successMessage = "Document added to all Trainers successfully.";
                    },
                    function errorCallback(response) {
                        $scope.errorMessage = "An error occurred: " + response.data.Message;
                    }
                );
        }

        $scope.getExistingDocuments($scope.selectedExistingDocumentOrganisationId);
    }
})();