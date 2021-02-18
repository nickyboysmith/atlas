(function () {

    'use strict';

    angular
        .module("app")
        .service("DorsService", DorsService);

    DorsService.$inject = ["$http"];

    function DorsService($http) {

        var dorsService = this;

        /**
         * 
         */
        dorsService.getClientStatuses = function (driversLicence, organisationId) {
            var parameters = { driversLicence: driversLicence, organisationId: organisationId };
            return $http.post(apiServer + "/dorswebserviceinterface/getClientStatus/", parameters);
        };

        /**
         *  Add a Course to DORS
         */
        dorsService.addCourse = function (courseId) {
            return $http.get(apiServer + "/dorswebserviceinterface/AddCourseToDORS/" + courseId);
        };

        /**
         *  Update a Course in DORS
         */
        dorsService.updateCourse = function (courseId) {
            return $http.get(apiServer + "/dorswebserviceinterface/UpdateCourseInDORS/" + courseId);
        };

        dorsService.getAvailableCourses = function (schemeId, organisationId) {
            return $http.get(apiServer + "/dorswebserviceinterface/getAvailableCourses/" + schemeId + "/" + organisationId);
        }

        dorsService.bookClientOnCourse = function (attendanceId, courseId) {
            return $http.get(apiServer + "/dorswebserviceinterface/bookClientOnCourse/" + attendanceId + "/" + courseId);
        }

        dorsService.performDORSCheck = function (clientId, licenceNumber) {
            var params = { clientId: clientId, licenceNumber: licenceNumber };
            return $http.post(apiServer + "/dorswebserviceinterface/PerformDORSCheck/", params);
        }

        dorsService.clearDORSData = function (clientId, organisationId, userId) {
            return $http.get(apiServer + "/dorswebserviceinterface/ClearDORSData/" + clientId + "/" + organisationId + "/" + userId);
        }

        dorsService.retryContactingDORS = function (clientId) {
            return $http.get(apiServer + "/dorswebserviceinterface/retryContactingDORS/" + clientId);
        }

        dorsService.removeFromDORSQue = function (clientId) {
            return $http.get(apiServer + "/dorswebserviceinterface/removeFromDORSQue/" + clientId);
        }
    }

})();