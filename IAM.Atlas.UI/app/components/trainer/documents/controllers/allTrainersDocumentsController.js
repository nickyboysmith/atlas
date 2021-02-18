(function () {
    'use strict';

    angular
        .module('app')
        .controller('allTrainersDocumentsCtrl', allTrainersDocumentsCtrl);

    allTrainersDocumentsCtrl.$inject = ["$scope", "$timeout", "TrainerDocumentService", "UserService", "ModalService", "activeUserProfile"];

    function allTrainersDocumentsCtrl($scope, $timeout, TrainerDocumentService, UserService, ModalService, activeUserProfile) {

        $scope.documents = {};
        $scope.displayDocuments = {};
        $scope.selectedOrganisationId = {};
        $scope.userService = UserService;
        $scope.selectedDocumentId = -1;

        $scope.getDocuments = function (organisationId) {
            return TrainerDocumentService.getAllTrainerDocumentsByOrganisation(organisationId)
                .then(
                    function successCallback(response) {
                        $scope.documents = response.data;
                        $scope.displayDocuments = $scope.documents;
                    },
                    function errorCallback(response) {
                    
                    }
                );
        }

        //Get Organisations function
        $scope.getOrganisations = function (userId) {
            $scope.userService.getOrganisationIds(userId)
            .then(function (data) {
                $scope.organisations = data;
                $scope.selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
                $scope.userService.checkSystemAdminUser(userId)
                    .then(function (data) {
                        $scope.isAdmin = data;
                        $scope.getDocuments($scope.selectedOrganisationId);
                    });
            }, function (data) {
                console.log("Can't get Organisations");
            });
        }

        $scope.getSelectedOrganisationId = function () {
            var selectedOrganisationId = '' + activeUserProfile.selectedOrganisation.Id;
            return selectedOrganisationId;
        }

        $scope.addNew = function () {
            
            ModalService.displayModal({
                scope: $scope,
                title: "Upload New All Trainer Document",
                cssClass: "uploadNewAllTrainerDocumentModal",
                filePath: "/app/components/trainer/documents/allTrainersDocumentUpload.html",
                controllerName: "allTrainersDocumentUploadCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.editDetails = function () {

            ModalService.displayModal({
                scope: $scope,
                title: "Document Details",
                cssClass: "editAllTrainerDocumentModal",
                filePath: "/app/components/trainer/documents/editAllTrainersDocument.html",
                controllerName: "editAllTrainersDocumentCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });
        }

        $scope.addExistingDocument = function () {

            $scope.selectedExistingDocumentOrganisationId = $scope.selectedOrganisationId;

            ModalService.displayModal({
                scope: $scope,
                title: "Add Existing Document for all Trainers Administration",
                cssClass: "addExistingAllTrainersDocumentModal",
                filePath: "/app/components/trainer/documents/allTrainersDocumentsAddExisting.html",
                controllerName: "allTrainersDocumentsAddExistingCtrl"
            });
        }

        $scope.removeDocument = function() {
            if ($scope.selectedDocumentId > 0) {
                TrainerDocumentService.removeAllTrainersDocument($scope.selectedDocumentId)
                    .then(
                        function successCallback(response) {
                            if (response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedOrganisationId);
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message;
                        });
            }
        }

        $scope.deleteDocument = function() { 
            if ($scope.selectedDocumentId > 0) {
                TrainerDocumentService.deleteAllTrainersDocument($scope.selectedDocumentId, activeUserProfile.UserId)
                    .then(
                        function successCallback(response) {
                            if(response.data == false) {
                                $scope.errorMessage = 'An error occurred.';
                            }
                            $scope.getDocuments($scope.selectedOrganisationId);
                        },
                        function errorCallback(response) {
                            $scope.errorMessage = 'An error occurred: ' + response.data.Message
                        });
            }
        }

        $scope.selectDocument = function (documentId) {
            $scope.selectedDocumentId = documentId;
        }

        $scope.getOrganisations(activeUserProfile.UserId);
    }
})();