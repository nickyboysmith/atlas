(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseTypeDocumentService", CourseTypeDocumentService);

    CourseTypeDocumentService.$inject = ["$http"];

    function CourseTypeDocumentService($http) {

        var courseTypeDocumentService = this;

        // Get a list of all the documents for an organisation
        courseTypeDocumentService.getByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getByOrganisation/" + organisationId);
        }

        // Get a list of all the "All CourseType" documents for a course type
        courseTypeDocumentService.getAllCourseTypeDocumentsByCourseType = function (courseTypeId) {
            return $http.get(apiServer + "/document/getAllCourseTypeDocumentsByCourseType/" + courseTypeId);
        }

        // Get a list of all the "All CourseType" documents for an organisation
        courseTypeDocumentService.getNonAllCourseTypeDocumentsByCourseType = function (courseTypeId) {
            return $http.get(apiServer + "/document/getNonAllCourseTypeDocumentsByCourseType/" + courseTypeId);
        }

        /**
         * 
         */
        courseTypeDocumentService.uploadAllCourseTypesDocument = function (document) {
            return $http.post(apiServer + "/document/addAllCourseTypesDocument", document,
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
        courseTypeDocumentService.uploadCourseTypeDocument = function (document) {
            return $http.post(apiServer + "/courseTypedocument", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        };

        courseTypeDocumentService.AddExistingDocumentToAllCourseTypes = function(documentId, userId, organisationId){
            return $http.get(apiServer + "/document/AddExistingDocumentToAllCourseTypes/" + documentId + "/" + userId + "/" + organisationId);
        }

        courseTypeDocumentService.removeAllCourseTypesDocument = function (documentId) {
            return $http.get(apiServer + "/document/removeAllCourseTypesDocument/" + documentId);
        };

        courseTypeDocumentService.deleteAllCourseTypesDocument = function (documentId, userId) {
            return $http.get(apiServer + "/document/deleteAllCourseTypesDocument/" + documentId + "/" + userId);
        };

        courseTypeDocumentService.get = function (DocumentId, UserId) {
            return $http.get(apiServer + "/document/get/" + DocumentId + "/" + UserId);
        };

        courseTypeDocumentService.updateTitleDescription = function (DocumentId, Title, Description, UserId) {

            var documentUpdateDetails = {};
            documentUpdateDetails.DocumentId = DocumentId;
            documentUpdateDetails.Title = Title;
            documentUpdateDetails.Description = Description;
            documentUpdateDetails.UserId = UserId;

            return $http.post(apiServer + "/document/updateTitleDescription/", documentUpdateDetails);
        };
    }
})();