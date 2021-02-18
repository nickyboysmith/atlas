(function () {

    'use strict';

    angular
        .module("app")
        .controller("DocumentInformationCtrl", DocumentInformationCtrl);

    DocumentInformationCtrl.$inject = ["$scope", "activeUserProfile", "ModalService", "DocumentInformationService", "UserService", "DocumentDownloadService", "ClientService"];

    function DocumentInformationCtrl($scope, activeUserProfile, ModalService, DocumentInformationService, UserService, DocumentDownloadService, ClientService) {

        $scope.documentInformation = {};

        $scope.documentPrintErrorSum = 0;

        $scope.selectedDocument = {};

        $scope.selectedDocuments = {};

        $scope.documentOrigin = "";

        $scope.documentPrintQueueValidationMessage = "";

        $scope.systemIsReadOnly = $scope.$parent.systemIsReadOnly;

        $scope.isReferringAuthority = $scope.$parent.isReferringAuthority;

        if ($scope.$parent.documentOrigin) {
            $scope.documentOrigin = $scope.$parent.documentOrigin;
            if ($scope.documentOrigin === "client") {
                $scope.clientId = $scope.$parent.clientId;
            }
        }

        $scope.selectDocument = function (document) {
            $scope.selectedDocument = document;
            document.isSelected ? document.isSelected = false : document.isSelected = true;
            $scope.createSelectedDocumentList();
        };

        $scope.getDocumentInformation = function (type, Id) {

            if (type === "course") {
                DocumentInformationService.getCourseDocumentInformation(Id)
                    .then(function (response) {
                        $scope.documentInformation = response.data;
                    });
            }
            else if (type === "client") {
                DocumentInformationService.getClientDocumentInformation(Id)
                    .then(function (response) {
                        $scope.documentInformation = response.data;
                    });
            }
        }

        $scope.downloadSelectedDocument = function (doc) {
            var owningEntityId = -1;
            if ($scope.documentOrigin === "course") {
                owningEntityId = doc.CourseId
            }
            else if ($scope.documentOrigin === "client") {
                owningEntityId = doc.ClientId;
            }
            if (owningEntityId > 0) {
                return DocumentDownloadService.downloadDocument(
                        doc.DocumentId,
                        activeUserProfile.UserId,
                        owningEntityId,//$scope.downloadDocument.owningEntityId,
                        activeUserProfile.selectedOrganisation.Id,
                        $scope.$parent.documentOrigin,//$scope.downloadDocument.owningEntityPath,
                        doc.DocumentTitle,
                        doc.DocumentType
                );
            }
        };

        $scope.sendDocumentToPrintQueue = function () {
            $scope.documentValidationMessage = "";
            $scope.documentPrintErrorSum = 0;
            for (var i = 0; i < $scope.selectedDocuments.length; i++) {
                ClientService.sendDocToPrintQueue($scope.selectedDocuments[i].DocumentId, $scope.clientID, activeUserProfile.UserId, activeUserProfile.selectedOrganisation.Id)
                    .then(function (response) {
                        if (response != true) {
                            $scope.documentPrintErrorSum += 1;
                            $scope.calculateDocPrintQueueValidationMessage();
                        }
                        else {
                            $scope.calculateDocPrintQueueValidationMessage();
                        }
                    });
            }
        };

        $scope.calculateDocPrintQueueValidationMessage = function () {
            if ($scope.documentPrintErrorSum > 0) {
                $scope.documentValidationMessage = "Unable to send all docs to Print Queue. Please contact support.";
            }
            else {
                $scope.documentValidationMessage = "All docs sent to Print Queue.";
            }
        };




        // Show email modal
        $scope.showEmailClientModal = function () {
            if ($scope.client.Emails.length === 0) {
                return false;
            }
            $scope.allSelectedDocuments = $scope.selectedDocuments;//$filter('filter')($scope.documents, { isSelected: true });;
            $scope.clientEmailAddress = $scope.client.Emails[0].Address;
            $scope.clientEmailName = $scope.client.DisplayName;
            $scope.clientEmailId = $scope.client.Id;

            ModalService.displayModal({
                scope: $scope,
                title: "Send Client Email",
                cssClass: "sendClientEmailModal",
                filePath: "/app/components/email/view.html",
                controllerName: "SendEmailCtrl",
                buttons: {
                    label: 'Close',
                    cssClass: 'closeModalButton',
                    action: function (dialogItself) {
                        dialogItself.close();
                    }
                }
            });

        };

        $scope.createSelectedDocumentList = function () {
            $scope.selectedDocuments = $scope.documentInformation.filter(function (doc) {
                return doc.isSelected === true;
            });
        }

        if ($scope.$parent.documentOrigin === "course") {
            $scope.getDocumentInformation($scope.documentOrigin, $scope.$parent.courseId);
        }
        else if ($scope.$parent.documentOrigin === "client") {
            $scope.getDocumentInformation($scope.documentOrigin, $scope.$parent.clientID);
        }
    }
})();