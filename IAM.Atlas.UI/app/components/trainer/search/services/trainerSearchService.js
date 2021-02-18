(function () {

    'use strict';

    angular
        .module("app")
        .service("trainerSearchService", trainerSearchService);

    trainerSearchService.$inject = ["$http"];

    function trainerSearchService($http) {

        var trainerService = this;        

        /**
         * Get the related Course Types
         */
        trainerService.getRelatedCourseTypes = function (organisationId) {
            return $http.get(apiServer + "/coursetype/" + organisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the related Course Categories
         */
        trainerService.getRelatedCourseCategories = function (courseTypeID, userID) {
            return $http.get(apiServer + "/CourseTypeCategory/GetByCourseType/" + courseTypeID + "/" + userID)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the trainers meeting the organisation, course type and course category criteria
         */
        trainerService.getTrainers = function (CourseTypeId, CategoryId, OrganisationId) {
            return $http.get(apiServer + "/trainer/fororganisation/" + CourseTypeId + "/" + CategoryId + "/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };


        /**
         * Get the trainers meeting the organisation criteria that are allocated to any course type
         */
        trainerService.GetTrainersByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/trainer/gettrainersbyorganisation/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the trainers meeting the organisation criteria that are not allocated to any course type
         */
        trainerService.getUnallocatedTrainersByOrganisation = function (OrganisationId) {
            return $http.get(apiServer + "/trainer/gettrainersunallocatedbyorganisation/" + OrganisationId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };

        /**
         * Get the trainers meeting the organisation, course type and course category criteria
         */
        trainerService.getTrainersByCoursetype = function (CourseTypeId) {
            return $http.get(apiServer + "/trainer/gettrainersbycoursetype/" + CourseTypeId)
                .then(function (response) { return response.data; }, function (response, status) { return response.data; })
        };
    }
})();