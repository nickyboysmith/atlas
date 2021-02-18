(function () {

    'use strict';

    angular
        .module("app")
        .controller("DocumentPrintQueueCtrl", DocumentPrintQueueCtrl);

    DocumentPrintQueueCtrl.$inject = ["$scope", "$filter", "activeUserProfile", "ModalService", "DateFactory", "DocumentPrintQueueService", "UserService", "DocumentDownloadService"];

    function DocumentPrintQueueCtrl($scope, $filter, activeUserProfile, ModalService, DateFactory, DocumentPrintQueueService, UserService, DocumentDownloadService) {

        // initialise to the current user and organisation
        $scope.selectedOrganisationId = activeUserProfile.selectedOrganisation.Id;
        $scope.selectedUserId = activeUserProfile.UserId;
        $scope.selectedDocuments = {};
        $scope.docPQSummary = {};
        $scope.docPQDetail = {};
        $scope.selectedDocument = {};
        $scope.docPQDetailTemplate = {};
        $scope.maxResults = 10;
        $scope.validationMessage = "";
        $scope.documentIdString = "";

        $scope.getDocumentPrintQueueSummary = function () {
            DocumentPrintQueueService.GetSummary($scope.selectedOrganisationId)
                .then(
                    function successCallback(response) {
                        $scope.docPQSummary = response.data;
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.getDocumentPrintQueueDetail = function () {
            DocumentPrintQueueService.GetDetail($scope.selectedOrganisationId)
                .then(
                    function successCallback(response) {
                        $scope.docPQDetail = response.data;
                        $scope.docPQDetailTemplate = response.data;
                    },
                    function errorCallback(response) {

                    }
                );
        }

        $scope.selectDocument = function (document) {
            document.isSelected ? document.isSelected = false : document.isSelected = true;
            $scope.createSelectedDocumentList();
        };

        $scope.removeDocument = function () {
            for (var i = 0; i < $scope.selectedDocuments.length; i++) {
                $scope.selectedDocument = $scope.selectedDocuments[i];
                DocumentPrintQueueService.RemoveDocumentFromQueue($scope.selectedDocument.DocumentId)
                    .then(
                        function successCallback(response) {
                            if (response.data == true) {
                                $scope.validationMessage = "Document(s) removed from the Print Queue.";
                                $scope.getDocumentPrintQueueDetail();
                                $scope.getDocumentPrintQueueSummary();
                            }
                            else {
                                $scope.validationMessage = "Document(s) may have failed to be removed from the queue. Please contact an administrator.";
                            }
                        },
                        function errorCallback(response) {
                            $scope.validationMessage = "Document(s) failed to be removed from the queue. Please try again.";
                        }
                );
            }
        };

        $scope.downloadDocument = function () {
            for (var i = 0; i < $scope.selectedDocuments.length; i++) {
                $scope.selectedDocument = $scope.selectedDocuments[i];
                DocumentDownloadService.downloadDocument($scope.selectedDocument.DocumentId,
                activeUserProfile.UserId,
                activeUserProfile.selectedOrganisation.Id,
                activeUserProfile.selectedOrganisation.Id,
                "organisation",
                $scope.selectedDocument.Document,
                $scope.selectedDocument.DocumentType);
            }
        };

        $scope.downloadMergedDocuments = function (mergeType) {
            $scope.documentIdString = "";
            //gets all the document ids
            if (mergeType === "MergeAll") {
                for (var i = 0; i < $scope.docPQDetail.length; i++) {
                    if ($scope.documentIdString === "") {
                        $scope.documentIdString = $scope.docPQDetail[i].DocumentId;
                    } else {
                        $scope.documentIdString += "," + $scope.docPQDetail[i].DocumentId;
                    }
                }
            }
                //gets all the selected document ids
            else if (mergeType === "MergeSelected") {
                if ($scope.selectedDocuments.length > 0) {
                    for (var i = 0; i < $scope.selectedDocuments.length; i++) {
                        if ($scope.documentIdString === "") {
                            $scope.documentIdString = $scope.selectedDocuments[i].DocumentId;
                        } else {
                            $scope.documentIdString += "," + $scope.selectedDocuments[i].DocumentId;
                        }
                    }
                }
                else {
                    $scope.validationMessage = "Please select some documents to merge";
                }
            }

            DocumentPrintQueueService.mergeDocsInPrintQueue($scope.documentIdString)
                .then(function successCallback(response) {
                    var fileName = response.data;
                    var extension = fileName.substr(fileName.lastIndexOf('.') + 1);
                    fileName = fileName.replace('.' + extension, '');
                    DocumentDownloadService.downloadLocalDocument(fileName, extension);
                },
                function errorCallback(response) {
                    $scope.validationMessage = "Please try again. If the problem persists, please contact support.";
                });
        }

        $scope.createSelectedDocumentList = function () {
            $scope.selectedDocuments = $scope.docPQDetail.filter(function (doc) {
                return doc.isSelected === true;
            });
        }

        $scope.getDocumentPrintQueueSummary();
        $scope.getDocumentPrintQueueDetail();
    };
})();