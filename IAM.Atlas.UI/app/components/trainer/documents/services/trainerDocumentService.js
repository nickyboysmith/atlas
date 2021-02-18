(function () {

    'use strict';

    angular
        .module("app")
        .service("TrainerDocumentService", TrainerDocumentService);

    TrainerDocumentService.$inject = ["$http"];

    function TrainerDocumentService($http) {

        var trainerDocumentService = this;

        // Get a list of all the documents for an organisation
        trainerDocumentService.getByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getByOrganisation/" + organisationId);
        }

        // Get a list of all the "All Trainer" documents for an organisation
        trainerDocumentService.getAllTrainerDocumentsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getAllTrainerDocumentsByOrganisation/" + organisationId);
        }

        // Get a list of all the "All Trainer" documents for an organisation
        trainerDocumentService.getNonAllTrainerDocumentsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getNonAllTrainerDocumentsByOrganisation/" + organisationId);
        }

        /**
         * 
         */
        trainerDocumentService.uploadAllTrainersDocument = function (document) {
            return $http.post(apiServer + "/document/addAllTrainersDocument", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        };

        /**
         * 
         */
        trainerDocumentService.uploadTrainerDocument = function (document) {
            return $http.post(apiServer + "/trainerdocument", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        };

        trainerDocumentService.AddExistingDocumentToAllTrainers = function(documentId, userId, organisationId){
            return $http.get(apiServer + "/document/AddExistingDocumentToAllTrainers/" + documentId + "/" + userId + "/" + organisationId);
        }

        trainerDocumentService.removeAllTrainersDocument = function (documentId) {
            return $http.get(apiServer + "/document/removeAllTrainersDocument/" + documentId);
        };

        trainerDocumentService.deleteAllTrainersDocument = function (documentId, userId) {
            return $http.get(apiServer + "/document/deleteAllTrainersDocument/" + documentId + "/" + userId);
        };

        trainerDocumentService.get = function (DocumentId, UserId) {
            return $http.get(apiServer + "/document/get/" + DocumentId + "/" + UserId);
        };

        trainerDocumentService.updateTitleDescription = function (DocumentId, Title, Description, UserId) {

            var documentUpdateDetails = {};
            documentUpdateDetails.DocumentId = DocumentId;
            documentUpdateDetails.Title = Title;
            documentUpdateDetails.Description = Description;
            documentUpdateDetails.UserId = UserId;

            return $http.post(apiServer + "/document/updateTitleDescription/", documentUpdateDetails);
        };
    }
})();