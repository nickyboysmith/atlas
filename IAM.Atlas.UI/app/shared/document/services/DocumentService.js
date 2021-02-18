(function () {

    'use strict';

    angular
        .module("app")
        .service("DocumentService", DocumentService);


    DocumentService.$inject = ["$http"];

    function DocumentService($http) {

        var documentService = this;

        documentService.Get = function (Id) {
            return $http.get(apiServer + "/document/" + Id)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        documentService.Get = function (Id, UserId) {
            return $http.get(apiServer + "/document/get/" + Id + "/" + UserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        documentService.Delete = function (Id, UserId) {
            return $http.get(apiServer + "/document/delete/" + Id + "/" + UserId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        documentService.GetDocumentTypes = function () {
            return $http.get(apiServer + "/document/getDocumentTypes/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        documentService.GetOrganisationDocuments = function (organisationId, documentType, showDeletedDocuments, documentCategory) {
            return $http.get(apiServer + "/document/GetOrganisationDocuments/" + organisationId + "/" + documentType + "/" + showDeletedDocuments + "/" + documentCategory)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        documentService.updateTitleDescription = function (DocumentId, Title, Description, UserId) {

            var documentUpdateDetails = {};
            documentUpdateDetails.DocumentId = DocumentId;
            documentUpdateDetails.Title = Title;
            documentUpdateDetails.Description = Description;
            documentUpdateDetails.UserId = UserId;

            return $http.post(apiServer + "/document/updateTitleDescription/", documentUpdateDetails)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        // used for the dashbord
        documentService.getSystemStatistics = function () {
            return $http.get(apiServer + "/dashboard/systemdocuments/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        documentService.getOrganisationStatistics = function (organisationId) {
            return $http.get(apiServer + "/dashboard/documents/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });

        }

        // used under the administration document statistics
        documentService.getDocumentSystemStatistics = function () {
            return $http.get(apiServer + "/document/systemdocuments/")
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        documentService.getDocumentOrganisationStatistics = function (organisationId) {
            return $http.get(apiServer + "/document/documents/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        }

        /**
        * Get documents marked for deletion by Organisation
        */
        documentService.getMarkedDocumentsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/GetMarkedDocumentsByOrganisation/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };

        /**
         * Delete documents marked for deletion
         */
        documentService.deleteMarkedDocuments = function (selectedDocuments) {
            return $http.post(apiServer + "/document/DeleteMarkedDocuments", selectedDocuments)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; });
        };
    }

})();