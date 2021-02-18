(function () {

    'use strict';

    angular
        .module("app")
        .service("DocumentPrintQueueService", DocumentPrintQueueService);

    DocumentPrintQueueService.$inject = ["$http"];

    function DocumentPrintQueueService($http) {

        var documentPrintQueueService = this;

        documentPrintQueueService.GetSummary = function (OrganisationId) {
            return $http.get(apiServer + "/documentPrintQueue/getSummary/" + OrganisationId);
        };

        documentPrintQueueService.GetDetail = function (OrganisationId) {
            return $http.get(apiServer + "/documentPrintQueue/getDetail/" + OrganisationId );
        }

        documentPrintQueueService.RemoveDocumentFromQueue = function (documentId) {
            return $http.get(apiServer + "/documentPrintQueue/removeDocumentFromQueue/" + documentId);
        }

        documentPrintQueueService.mergeDocsInPrintQueue = function (documentIdString) {
            return $http.get(apiServer + "/documentPrintQueue/mergeDocsInPrintQueue/" + documentIdString);
        }
    }

})();