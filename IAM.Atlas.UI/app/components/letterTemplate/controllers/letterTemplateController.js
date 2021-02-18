(function () {

    'use strict';

    angular
        .module("app")
        .controller("CreateFromLetterTemplateCtrl", CreateFromLetterTemplateCtrl);

    CreateFromLetterTemplateCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "ModalService", "LetterTemplateService", "UserService", "ClientService"];

    function CreateFromLetterTemplateCtrl($scope, $filter, activeUserProfile, ModalService, LetterTemplateService, UserService, ClientService) {

        $scope.createFromLetterTemplate = {};
        $scope.letterTemplates = [];
        $scope.selectedTemplateDetails = {};
        $scope.letterTemplateId = -1;
        $scope.letterTemplateDocumentId = -1;
        $scope.createdDocumentId - 1;
        $scope.documentQueue = {};
        $scope.documentQueue.addToDocumentQueue = false;

        $scope.showSpinner = false;
        $scope.validationMessage = '';

        if ($scope.$parent.createDocFromTemplateObject) {
            $scope.createDocFromTemplate = $scope.$parent.createDocFromTemplateObject;
        }

        $scope.getletterTemplates = function () {
            LetterTemplateService.getLetterTemplateCategoriesByOrganisation(activeUserProfile.selectedOrganisation.Id)
                .then(
                    function (response) {
                        $scope.letterTemplates = response;
                    },
                    function (response) {
                    }
                );
        }

        $scope.setSelectedTemplate = function (selectedTemplate) {
            if (selectedTemplate > 0 && selectedTemplate != undefined) {
                $scope.selectedTemplateDetails = $filter('filter')($scope.letterTemplates, { LetterTemplateId: selectedTemplate });
                $scope.selectedTemplateDetails = $scope.selectedTemplateDetails[0];
            }
            else {
                $scope.selectedTemplateDetails = {};
            }
        }

        $scope.convertFormData = function (selectedTemplateDetails) {
            var formData = new FormData();
            formData.append("LetterTemplateId", selectedTemplateDetails.LetterTemplateId);
            formData.append("UserId", activeUserProfile.UserId)
            formData.append("ClientId", $scope.$parent.clientId);
            return formData;
        };

        $scope.createDocument = function (selectedTemplateDetails) {
            if ($scope.selectedTemplateDetails != undefined && !jQuery.isEmptyObject(selectedTemplateDetails)) {
                $scope.showSpinner = true;
                LetterTemplateService.requestDocumentFromLetterDocumentTemplate($scope.convertFormData(selectedTemplateDetails))
                    .then(
                        function (response) {
                            if (response > 0) {
                                $scope.letterTemplateDocumentId = response;
                                LetterTemplateService.createDocumentTemplate($scope.letterTemplateDocumentId)
                                        .then(
                                            function (response) {
                                                if (response > 0) {
                                                    $scope.validationMessage = "Document Created";
                                                    $scope.showSpinner = false;
                                                    $scope.createdDocumentId = response;
                                                    ClientService.getDocuments($scope.$parent.clientId, activeUserProfile.selectedOrganisation.Id)
                                                            .then(function (response) {
                                                                $scope.$parent.documents = response.data;
                                                            })
                                                    if ($scope.documentQueue.addToDocumentQueue) {
                                                        $scope.sendDocumentToPrintQueue()
                                                    }
                                                } else {
                                                    $scope.validationMessage = "Failed, please try again";
                                                    $scope.showSpinner = false;
                                                }
                                            });
                            }
                            else {
                                $scope.validationMessage = "Failed, please try again";
                                $scope.showSpinner = false;
                            }
                        },
                    function (response) { }
                    );
            }
        }



        $scope.closeModal = function () {
            ModalService.closeCurrentModal("createFromLetterTemplateModal");
        }

        $scope.sendDocumentToPrintQueue = function () {
            $scope.validationMessage = "";
            ClientService.sendDocToPrintQueue($scope.createdDocumentId, $scope.$parent.clientID, activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
                .then(function (response) {
                    if (response = true) {
                        $scope.validationMessage = "Document created and added to the Print Queue";
                    }
                    else {
                        $scope.validationMessage = "Document created but not added to the queue.";
                    }
                });
        }


        $scope.getletterTemplates();
    }

})();