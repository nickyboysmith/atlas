(function () {

    'use strict';

    angular
        .module("app")
        .service("CourseDocumentService", CourseDocumentService);

    CourseDocumentService.$inject = ["$http"];

    function CourseDocumentService($http) {

        var courseDocumentService = this;

        // Get a list of all the documents for an organisation
        courseDocumentService.getByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getByOrganisation/" + organisationId);
        }

        // Get a list of all the "All Course" documents for an organisation
        courseDocumentService.getAllCourseDocumentsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getAllCourseDocumentsByOrganisation/" + organisationId);
        }

        // Get a list of all the "All Course" documents for an organisation
        courseDocumentService.getNonAllCourseDocumentsByOrganisation = function (organisationId) {
            return $http.get(apiServer + "/document/getNonAllCourseDocumentsByOrganisation/" + organisationId);
        }

        /**
         * 
         */
        courseDocumentService.uploadAllCoursesDocument = function (document) {
            return $http.post(apiServer + "/document/addAllCoursesDocument", document,
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
        courseDocumentService.uploadCourseDocument = function (document) {
            return $http.post(apiServer + "/coursedocument", document,
                {
                    headers: {
                        'Content-Type': undefined
                    },
                    transformRequest: angular.identity
                }
            );
        };

        courseDocumentService.AddExistingDocumentToAllCourses = function(documentId, userId, organisationId){
            return $http.get(apiServer + "/document/AddExistingDocumentToAllCourses/" + documentId + "/" + userId + "/" + organisationId);
        }

        courseDocumentService.removeAllCoursesDocument = function (documentId) {
            return $http.get(apiServer + "/document/removeAllCoursesDocument/" + documentId);
        };

        courseDocumentService.deleteAllCoursesDocument = function (documentId, userId) {
            return $http.get(apiServer + "/document/deleteAllCoursesDocument/" + documentId + "/" + userId);
        };

        courseDocumentService.get = function (DocumentId, UserId) {
            return $http.get(apiServer + "/document/get/" + DocumentId + "/" + UserId);
        };

        courseDocumentService.updateTitleDescription = function (DocumentId, Title, Description, UserId) {

            var documentUpdateDetails = {};
            documentUpdateDetails.DocumentId = DocumentId;
            documentUpdateDetails.Title = Title;
            documentUpdateDetails.Description = Description;
            documentUpdateDetails.UserId = UserId;

            return $http.post(apiServer + "/document/updateTitleDescription/", documentUpdateDetails);
        };
    }
})();